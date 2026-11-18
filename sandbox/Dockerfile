# Blind agent routing test: KiCad 10 + Claude Code, nothing else.
# amd64 only upstream; runs under Rosetta on Apple silicon.
FROM --platform=linux/amd64 kicad/kicad:10.0
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates nodejs npm python3-pip python3-venv python3-numpy ripgrep jq \
    && rm -rf /var/lib/apt/lists/* \
    # No sudo for the agent.
    && gpasswd -d kicad sudo
ARG CLAUDE_CODE_VERSION=2.1.322
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} && npm cache clean --force
USER kicad
# Fresh, empty Claude config: no memory, no CLAUDE.md, no MCP servers, no plugins.
ENV CLAUDE_CONFIG_DIR=/home/kicad/.claude-sandbox \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    DISABLE_AUTOUPDATER=1
WORKDIR /work
