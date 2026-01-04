#!/bin/bash

# Helper functions for SSH tunnel management

# Get list of active SSH tunnels
# Returns: "PID|PORT|HOST|COMMAND" format, one per line
get_active_tunnels() {
    ps -eo pid,args | rg "autossh.*-L" | rg -v "rg autossh" | while read -r pid args; do
        # Extract port from -L argument (format: -L port:host:port)
        port=$(echo "$args" | rg -o "\-L\s+(\d+):" --replace '$1')
        
        # Extract host (last non-option argument)
        host=$(echo "$args" | rg -o "\s([^-]\S+)\s*$" --replace '$1')
        
        echo "$pid|$port|$host|$args"
    done
}

# Format tunnel info for display
# Input: "PID|PORT|HOST|COMMAND" format
format_tunnel_info() {
    while IFS='|' read -r pid port host cmd; do
        echo "Port $port (PID $pid): $cmd"
    done
}

# Format tunnel info for fzf (tabular format)
# Input: "PID|PORT|HOST|COMMAND" format  
format_tunnel_fzf() {
    while IFS='|' read -r pid port host cmd; do
        printf "%-6s %-6s %-20s %s\n" "$pid" "$port" "$host" "$cmd"
    done
}