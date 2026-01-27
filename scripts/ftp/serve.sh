#!/bin/bash
# Start a local FTP server to share files over the network (e.g., with TV file managers)

set -e

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Start a local FTP server for easy file sharing.

OPTIONS:
    -d, --dir DIR       Directory to serve (default: current directory)
    -p, --port PORT     Port number (default: 2121)
    -w, --write         Allow write access (upload/delete)
    -u, --user USER     Username for authentication (requires --pass)
    -P, --pass PASS     Password for authentication (requires --user)
    -h, --help          Show this help message

EXAMPLES:
    # Serve current directory (read-only)
    $(basename "$0")

    # Serve Downloads folder with write access
    $(basename "$0") -d ~/Downloads -w

    # Serve with authentication
    $(basename "$0") -d ~/Documents -u admin -P secret123

    # Use custom port
    $(basename "$0") -p 3000

CONNECTION INFO:
    After starting, connect using:
    - Host: Your local IP (shown on server start)
    - Port: The port specified (default: 2121)
    - User: anonymous (or specified username)
    - Pass: anonymous (or specified password)

EOF
}

show_ip() {
    echo "Your local IP addresses:"
    echo ""
    ifconfig | grep -E "^[a-z]" | while read -r line; do
        iface=$(echo "$line" | awk '{print $1}' | sed 's/://g')
        ip=$(ifconfig "$iface" 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -1)
        if [ -n "$ip" ]; then
            echo "  $iface: $ip"
        fi
    done
    echo ""
}

# Default values
DIR="$(pwd)"
PORT=2121  # Port 21 is standard FTP but requires root; 2121 doesn't
WRITE_FLAG=""
USER=""
PASS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            DIR="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -w|--write)
            WRITE_FLAG="-w"
            shift
            ;;
        -u|--user)
            USER="$2"
            shift 2
            ;;
        -P|--pass)
            PASS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate directory
if [ ! -d "$DIR" ]; then
    echo "Error: Directory does not exist: $DIR"
    exit 1
fi

# Expand tilde in directory path
DIR=$(eval echo "$DIR")

# Check if pyftpdlib is installed
if ! python3 -c "import pyftpdlib" 2>/dev/null; then
    echo "Error: pyftpdlib is not installed"
    echo "Install it with: pip3 install pyftpdlib"
    exit 1
fi

# Build command
CMD="python3 -m pyftpdlib -p $PORT -d \"$DIR\" $WRITE_FLAG"

# Add authentication if specified
if [ -n "$USER" ] && [ -n "$PASS" ]; then
    CMD="$CMD -u $USER -P $PASS"
elif [ -n "$USER" ] || [ -n "$PASS" ]; then
    echo "Error: Both --user and --pass must be specified together"
    exit 1
fi

# Show connection info
echo "=========================================="
echo "Starting FTP Server"
echo "=========================================="
echo "Directory: $DIR"
echo "Port:      $PORT"
echo "Access:    $([ -n "$WRITE_FLAG" ] && echo "Read-Write" || echo "Read-Only")"
if [ -n "$USER" ]; then
    echo "User:      $USER"
    echo "Pass:      $PASS"
else
    echo "Auth:      Anonymous"
fi
echo ""
show_ip
echo "=========================================="
echo "Press Ctrl+C to stop the server"
echo "=========================================="
echo ""

# Run the server
eval $CMD
