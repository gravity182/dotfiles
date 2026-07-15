#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "psutil==7.2.2",
#     "pyftpdlib==2.2.0",
# ]
# ///

"""Start a local FTP server for sharing files on a trusted network."""

from __future__ import annotations

import argparse
import getpass
import ipaddress
import socket
import sys
from collections.abc import Sequence
from dataclasses import dataclass, field
from pathlib import Path

import psutil
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

DEFAULT_PORT = 2121
READ_PERMISSIONS = "elr"
WRITE_PERMISSIONS = "elradfmwMT"
SEPARATOR = "=" * 42


@dataclass(frozen=True, slots=True)
class ServerConfig:
    """Validated FTP server configuration."""

    directory: Path
    port: int
    passive_port_range: tuple[int, int] | None
    allow_write: bool
    username: str | None
    password: str | None = field(repr=False)


def valid_port(value: str) -> int:
    """Parse a valid, non-privileged or privileged TCP port number."""
    try:
        port = int(value)
    except ValueError as error:
        raise argparse.ArgumentTypeError("port must be an integer") from error

    if not 1 <= port <= 65_535:
        raise argparse.ArgumentTypeError("port must be between 1 and 65535")
    return port


def valid_port_range(value: str) -> tuple[int, int]:
    """Parse an inclusive TCP port range in FROM-TO format."""
    parts = value.split("-", maxsplit=1)
    if len(parts) != 2:
        raise argparse.ArgumentTypeError(
            "port range must use FROM-TO format (for example, 50000-50010)"
        )

    try:
        start = valid_port(parts[0])
        end = valid_port(parts[1])
    except argparse.ArgumentTypeError as error:
        raise argparse.ArgumentTypeError(f"invalid port range: {error}") from error

    if start > end:
        raise argparse.ArgumentTypeError(
            "port range start must be less than or equal to its end"
        )
    return start, end


def existing_directory(value: str) -> Path:
    """Expand and resolve a path, requiring it to be an existing directory."""
    candidate = Path(value).expanduser()
    try:
        directory = candidate.resolve(strict=True)
    except (OSError, RuntimeError) as error:
        raise argparse.ArgumentTypeError(
            f"directory does not exist or cannot be resolved: {value}"
        ) from error

    if not directory.is_dir():
        raise argparse.ArgumentTypeError(f"not a directory: {value}")
    return directory


def build_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Start a local FTP server for easy file sharing.",
        epilog="""
examples:
  %(prog)s
  %(prog)s -d ~/Downloads -w
  %(prog)s -d ~/Documents -u admin
  %(prog)s -p 3000
  %(prog)s -p 2121 -r 50000-50010

FTP sends credentials and data without encryption. Use this server only on a
trusted network.
""",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "-d",
        "--dir",
        dest="directory",
        type=existing_directory,
        default=Path.cwd(),
        metavar="DIR",
        help="directory to serve (default: current directory)",
    )
    parser.add_argument(
        "-p",
        "--port",
        type=valid_port,
        default=DEFAULT_PORT,
        metavar="PORT",
        help=f"port number (default: {DEFAULT_PORT})",
    )
    parser.add_argument(
        "-r",
        "--range",
        dest="passive_port_range",
        type=valid_port_range,
        default=None,
        metavar="FROM-TO",
        help="inclusive TCP port range for passive data connections",
    )
    parser.add_argument(
        "-w",
        "--write",
        dest="allow_write",
        action="store_true",
        help="allow uploads, deletion, renaming, and directory creation",
    )
    parser.add_argument(
        "-u",
        "--user",
        dest="username",
        metavar="USER",
        help="username for authentication; prompts for a password if omitted",
    )
    parser.add_argument(
        "-P",
        "--pass",
        dest="password",
        metavar="PASS",
        help="password for authentication (prefer the secure prompt)",
    )
    return parser


def parse_args(argv: Sequence[str] | None = None) -> ServerConfig:
    """Parse and validate command-line arguments."""
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)

    username: str | None = args.username
    password: str | None = args.password

    if username == "":
        parser.error("--user cannot be empty")
    if password is not None and username is None:
        parser.error("--pass requires --user")
    if password == "":
        parser.error("--pass cannot be empty")

    if username is not None and password is None:
        try:
            password = getpass.getpass(f"Password for {username}: ")
        except EOFError:
            parser.error("unable to read a password from the terminal")
        if not password:
            parser.error("password cannot be empty")

    return ServerConfig(
        directory=args.directory,
        port=args.port,
        passive_port_range=args.passive_port_range,
        allow_write=args.allow_write,
        username=username,
        password=password,
    )


def local_ipv4_addresses() -> list[tuple[str, str]]:
    """Return non-loopback IPv4 addresses grouped by interface name."""
    results: list[tuple[str, str]] = []
    seen: set[tuple[str, str]] = set()

    for interface, addresses in sorted(psutil.net_if_addrs().items()):
        for address in addresses:
            if address.family != socket.AF_INET:
                continue

            parsed = ipaddress.ip_address(address.address)
            if parsed.is_loopback or parsed.is_unspecified:
                continue

            entry = (interface, address.address)
            if entry not in seen:
                seen.add(entry)
                results.append(entry)

    return results


def create_server(config: ServerConfig) -> FTPServer:
    """Build and bind an FTP server from validated configuration."""
    authorizer = DummyAuthorizer()
    permissions = WRITE_PERMISSIONS if config.allow_write else READ_PERMISSIONS
    home = str(config.directory)

    if config.username is None:
        authorizer.add_anonymous(home, perm=permissions)
    else:
        if config.password is None:
            raise ValueError("authenticated servers require a password")
        authorizer.add_user(
            config.username,
            config.password,
            home,
            perm=permissions,
        )

    class ConfiguredFTPHandler(FTPHandler):
        """FTP handler scoped to this server's authorizer."""

    ConfiguredFTPHandler.authorizer = authorizer
    if config.passive_port_range is not None:
        start, end = config.passive_port_range
        ConfiguredFTPHandler.passive_ports = range(start, end + 1)
    return FTPServer(("0.0.0.0", config.port), ConfiguredFTPHandler)


def print_startup_summary(config: ServerConfig) -> None:
    """Display server configuration and usable connection addresses."""
    access = "Read-Write" if config.allow_write else "Read-Only"

    print(SEPARATOR)
    print("Starting FTP Server")
    print(SEPARATOR)
    print(f"Directory: {config.directory}")
    print(f"Port:      {config.port}")
    if config.passive_port_range is None:
        print("Passive:   Dynamic ports")
    else:
        start, end = config.passive_port_range
        print(f"Passive:   {start}-{end}")
    print(f"Access:    {access}")
    if config.username is None:
        print("Auth:      Anonymous")
    else:
        print(f"User:      {config.username}")

    print("\nYour local IPv4 addresses:\n")
    addresses = local_ipv4_addresses()
    if addresses:
        for interface, address in addresses:
            print(f"  {interface}: {address}")
    else:
        print("  No non-loopback IPv4 addresses found")

    print(f"\n{SEPARATOR}")
    print("Warning: FTP is unencrypted; use only on a trusted network.")
    print("Press Ctrl+C to stop the server")
    print(SEPARATOR, flush=True)


def run(config: ServerConfig) -> int:
    """Start the configured FTP server and close it on shutdown."""
    server = create_server(config)
    print_startup_summary(config)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping FTP server...", flush=True)
    finally:
        server.close_all()

    return 0


def main(argv: Sequence[str] | None = None) -> int:
    """Run the command-line program."""
    try:
        return run(parse_args(argv))
    except KeyboardInterrupt:
        print("\nCancelled.", file=sys.stderr)
        return 130
    except OSError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
