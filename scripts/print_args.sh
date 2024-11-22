#!/bin/bash
# this script prints passed arguments, wrapping them for better visualization

printf "%d args:" "$#"
[ "$#" -eq 0 ] || printf " <%s>" "$@"
echo

