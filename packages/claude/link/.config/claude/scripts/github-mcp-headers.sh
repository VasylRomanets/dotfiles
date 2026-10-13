#!/bin/sh

# Prints the Authorization header for the GitHub MCP server as JSON, reading the
# token from the macOS Keychain, so it is never kept in a shell variable or a
# file. Used as the server's "headersHelper" (see the Claude Code MCP docs).
#
# Add the token to the Keychain first:
#   security add-generic-password -a "$USER" -s "claude-code-github-mcp-pat" -w "your-token"
token=$(security find-generic-password -a "${USER:-$(whoami)}" -s "claude-code-github-mcp-pat" -w 2>/dev/null)

if [ -z "$token" ]; then
  echo "github-mcp-headers: no 'claude-code-github-mcp-pat' entry in the Keychain." >&2
  exit 1
fi

printf '{"Authorization": "Bearer %s"}\n' "$token"
