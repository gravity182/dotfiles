#!/bin/bash

# Argument Display Utility
# Debugging tool that displays script arguments in a formatted way

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [arguments...]"
    echo ""
    echo "Debugging utility that displays script arguments in a formatted way"
    echo "Helpful for testing how shell expansion, quoting, and parsing work"
    echo ""
    echo "Arguments:"
    echo "  arguments...      Any number of arguments to display"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Output format:"
    echo "  Shows total argument count followed by each argument wrapped in <>"
    echo "  Example: '3 args: <first> <second> <third>'"
    echo ""
    echo "Examples:"
    echo "  $0 hello world                    # 2 args: <hello> <world>"
    echo "  $0 'hello world'                  # 1 args: <hello world>"
    echo "  $0 *.txt                          # Shows expanded filenames"
    echo "  $0 \"file with spaces.txt\"        # 1 args: <file with spaces.txt>"
    echo "  $0                                # 0 args:"
    echo ""
    echo "Use cases:"
    echo "  - Testing shell globbing and expansion"
    echo "  - Debugging quoting issues in scripts"
    echo "  - Understanding how arguments are passed to programs"
    echo "  - Verifying complex command-line constructions"
    exit 0
fi

# Display arguments with count and formatting
printf "%d args:" "$#"
[ "$#" -eq 0 ] || printf " <%s>" "$@"
echo

