# Claude Code and Google Cloud / Vertex AI
[ -f "$HOME/.config/claude-code-vertex/env.sh" ] && . "$HOME/.config/claude-code-vertex/env.sh"

export GOOGLE_CLOUD_PROJECT=${ANTHROPIC_VERTEX_PROJECT_ID}
export GOOGLE_CLOUD_LOCATION=${CLOUD_ML_REGION}
