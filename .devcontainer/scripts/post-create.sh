#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
OPENCODE_DIR="${HOME}/.opencode"

if [ ! -w "${CLAUDE_DIR}" ] || [ ! -w "${OPENCODE_DIR}" ]; then
    sudo chown -R "$(id -u):$(id -g)" "${CLAUDE_DIR}" "${OPENCODE_DIR}"
fi

mkdir -p "${OPENCODE_DIR}/bin"

install_opencode() {
    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
    rm -f "${OPENCODE_DIR}/bin/opencode-bin"
    mv "${OPENCODE_DIR}/bin/opencode" "${OPENCODE_DIR}/bin/opencode-bin"
    cat >"${OPENCODE_DIR}/bin/opencode" <<EOF
#!/bin/sh
export XDG_CONFIG_HOME="${OPENCODE_DIR}/config"
export XDG_DATA_HOME="${OPENCODE_DIR}/data"
export XDG_STATE_HOME="${OPENCODE_DIR}/state"
export XDG_CACHE_HOME="${OPENCODE_DIR}/cache"
exec "${OPENCODE_DIR}/bin/opencode-bin" "\$@"
EOF
    chmod +x "${OPENCODE_DIR}/bin/opencode"
}

pids=()
uv tool install pre-commit & pids+=($!)
curl -fsSL https://claude.ai/install.sh | bash & pids+=($!)
install_opencode & pids+=($!)

status=0
for pid in "${pids[@]}"; do
    wait "${pid}" || status=$?
done
exit "${status}"
