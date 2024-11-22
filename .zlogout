if [[ -n "$SSH_AGENT_PID" ]]; then
    eval $(ssh-agent -k) &>/dev/null
fi

