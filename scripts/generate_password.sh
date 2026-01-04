#!/usr/bin/env bash

# Password Generator
# Generates secure passwords using OpenSSL or pwgen

# Parse command line arguments
INTERACTIVE=false
PROVIDER=""
LENGTH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -p|--provider)
            PROVIDER="$2"
            shift 2
            ;;
        -l|--length)
            LENGTH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Generates secure passwords using OpenSSL or pwgen"
            echo "By default generates a 16-character password using the best available tool"
            echo ""
            echo "Options:"
            echo "  -i, --interactive     Interactive mode with prompts"
            echo "  -p, --provider TOOL   Use specific provider (openssl|pwgen)"
            echo "  -l, --length NUM      Password length [default: 16]"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Providers:"
            echo "  openssl    Hex-based, cryptographically secure (default if available)"
            echo "  pwgen      Pronounceable, excludes ambiguous characters"
            echo ""
            echo "Examples:"
            echo "  $0                          # Generate 16-char password with best tool"
            echo "  $0 -l 24                    # Generate 24-char password"
            echo "  $0 -p pwgen -l 12           # Use pwgen with 12 characters"
            echo "  $0 -i                       # Interactive mode with prompts"
            echo ""
            echo "Requirements:"
            echo "  - openssl (usually pre-installed)"
            echo "  - pwgen (optional, install with: brew install pwgen / apt install pwgen)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

COLOR_BOLD_RED='\033[1;31m'
COLOR_RESET='\033[0m'

DEFAULT_LENGTH=16
LENGTH_RE='^[1-9][0-9]*$'

# Interactive mode
if [[ "$INTERACTIVE" == true ]]; then
    echo "Select provider [default: best available]"
    echo "1: openssl"
    echo "2: pwgen"
    read provider_input

    if [[ "$provider_input" == "1" || "$provider_input" =~ openssl ]]; then
        PROVIDER="openssl"
    elif [[ "$provider_input" == "2" || "$provider_input" =~ pwgen ]]; then
        PROVIDER="pwgen"
    fi

    echo "Select length [default: $DEFAULT_LENGTH]"
    read length_input
    if [[ -n "$length_input" ]]; then
        LENGTH="$length_input"
    fi
fi

# Set defaults
if [[ -z "$LENGTH" ]]; then
    LENGTH=$DEFAULT_LENGTH
fi

# Validate length
if [[ ! "$LENGTH" =~ $LENGTH_RE ]]; then
    echo -e "${COLOR_BOLD_RED}Error: invalid length!${COLOR_RESET}" >&2
    exit 1
fi

# Auto-select provider if not specified (prefer cryptographically secure openssl)
if [[ -z "$PROVIDER" ]]; then
    if command -v openssl >/dev/null 2>&1; then
        PROVIDER="openssl"
    elif command -v pwgen >/dev/null 2>&1; then
        PROVIDER="pwgen"
    else
        echo -e "${COLOR_BOLD_RED}Error: Neither pwgen nor openssl found!${COLOR_RESET}" >&2
        exit 1
    fi
fi

# Generate password
case "$PROVIDER" in
    openssl)
        if ! command -v openssl >/dev/null 2>&1; then
            echo -e "${COLOR_BOLD_RED}Error: openssl not found!${COLOR_RESET}" >&2
            exit 1
        fi
        NUM_BYTES=$(((LENGTH + 1) / 2))
        openssl rand -hex ${NUM_BYTES} | tr -d '\n' | head -c ${LENGTH}
        ;;
    pwgen)
        if ! command -v pwgen >/dev/null 2>&1; then
            echo -e "${COLOR_BOLD_RED}Error: pwgen not found!${COLOR_RESET}" >&2
            exit 1
        fi
        pwgen -s -B -n $LENGTH 1
        ;;
    *)
        echo -e "${COLOR_BOLD_RED}Error: unknown provider '$PROVIDER'!${COLOR_RESET}" >&2
        exit 1
        ;;
esac

