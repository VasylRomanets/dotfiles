export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# a secret loaded from macOS Keychain;
# it's used in $CLAUDE_CONFIG_DIR/.claude.json to avoid hardcoding it as plaintext;
# to add it to the Keychain run:
#   security add-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w "your-token"
export CLAUDE_CODE_GITHUB_MCP_PAT=$(security find-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w 2>/dev/null)
