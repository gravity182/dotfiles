#!/usr/bin/env bash

# PNG Compression Tool
# Compresses PNG files using pngquant with customizable quality levels

# Parse command line arguments

COMPRESSION=""
INTERACTIVE=false
INPUT_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--compression)
            COMPRESSION="$2"
            shift 2
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] <input.png>"
            echo ""
            echo "Compresses PNG files using pngquant with customizable quality levels"
            echo ""
            echo "Options:"
            echo "  -c, --compression LEVEL  Compression level (low|normal|high) [default: normal]"
            echo "  -o, --output FILE        Output filename [default: <input_file_basename>-compressed.png]"
            echo "  -i, --interactive        Interactive mode with prompts"
            echo "  -h, --help               Show this help message"
            echo ""
            echo "Compression Levels:"
            echo "  low       90-98% quality (minimal compression, highest quality)"
            echo "  normal    80-95% quality (good balance, recommended)"
            echo "  high      60-80% quality (maximum compression, lower quality)"
            echo ""
            echo "Examples:"
            echo "  $0 image.png                          # Normal compression"
            echo "  $0 -c high image.png                  # High compression"
            echo "  $0 -c low -o small.png large.png     # Low compression with custom output"
            echo "  $0 -i image.png                       # Interactive mode"
            echo ""
            echo "Requirements:"
            echo "  - pngquant (install with: brew install pngquant)"
            echo ""
            echo "Notes:"
            echo "  - Input file must be a PNG image"
            echo "  - Compression is lossless for indexed images"
            echo "  - Significant file size reduction with minimal quality loss"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            else
                echo "Multiple input files not supported" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

COLOR_BOLD_RED='\033[1;31m'
COLOR_BOLD_GREEN='\033[1;32m'
COLOR_RESET='\033[0m'

# Check if input file is provided
if [[ -z "$INPUT_FILE" ]]; then
    echo -e "${COLOR_BOLD_RED}Error: No input file specified!${COLOR_RESET}" >&2
    echo "Use -h or --help for usage information" >&2
    exit 1
fi

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${COLOR_BOLD_RED}Error: Input file '$INPUT_FILE' not found!${COLOR_RESET}" >&2
    exit 1
fi

# Check if input file is a PNG
if [[ "${INPUT_FILE##*.}" != "png" ]]; then
    echo -e "${COLOR_BOLD_RED}Error: Input file must be a PNG image!${COLOR_RESET}" >&2
    exit 1
fi

# Interactive mode
if [[ "$INTERACTIVE" == true ]]; then
    echo "Select compression level [default: normal]"
    echo "1: low    (90-98% quality, minimal compression)"
    echo "2: normal (80-95% quality, recommended)"
    echo "3: high   (60-80% quality, maximum compression)"
    read -p "Choice: " compression_input

    case "$compression_input" in
        1|low)
            COMPRESSION="low"
            ;;
        2|normal|"")
            COMPRESSION="normal"
            ;;
        3|high)
            COMPRESSION="high"
            ;;
        *)
            echo "Invalid choice, using normal compression"
            COMPRESSION="normal"
            ;;
    esac

    if [[ -z "$OUTPUT_FILE" ]]; then
        echo ""
        read -p "Output filename [default: ${INPUT_FILE%.*}-compressed.png]: " output_input
        if [[ -n "$output_input" ]]; then
            OUTPUT_FILE="$output_input"
        fi
    fi
fi

# Set defaults
if [[ -z "$COMPRESSION" ]]; then
    COMPRESSION="normal"
fi

if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="${INPUT_FILE%.*}-compressed.png"
fi

# Validate compression level and set quality range
case "$COMPRESSION" in
    low)
        QUALITY_RANGE="90-98"
        ;;
    normal)
        QUALITY_RANGE="80-95"
        ;;
    high)
        QUALITY_RANGE="60-80"
        ;;
    *)
        echo -e "${COLOR_BOLD_RED}Error: Invalid compression level '$COMPRESSION'!${COLOR_RESET}" >&2
        echo "Valid levels: low, normal, high" >&2
        exit 1
        ;;
esac

# Check if pngquant is available
if ! command -v pngquant >/dev/null 2>&1; then
    echo -e "${COLOR_BOLD_RED}Error: pngquant not found!${COLOR_RESET}" >&2
    echo "Install with: brew install pngquant" >&2
    exit 1
fi

# Get original file size
ORIGINAL_SIZE=$(ls -lh "$INPUT_FILE" | awk '{print $5}')

echo "Compressing '$INPUT_FILE' with $COMPRESSION compression ($QUALITY_RANGE% quality)..."

# Compress the PNG
if pngquant --quality="$QUALITY_RANGE" --force --output "$OUTPUT_FILE" "$INPUT_FILE"; then
    COMPRESSED_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    echo -e "${COLOR_BOLD_GREEN}Success!${COLOR_RESET} Compressed from $ORIGINAL_SIZE to $COMPRESSED_SIZE"
    echo "Output: $OUTPUT_FILE"
else
    echo -e "${COLOR_BOLD_RED}Error: Compression failed!${COLOR_RESET}" >&2
    exit 1
fi
