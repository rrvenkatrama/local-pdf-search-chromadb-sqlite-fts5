#!/bin/zsh
# ============================================================================
# Local PDF Search KB — one-shot setup script. Idempotent (safe to re-run).
#
#   1. Creates the Python venv and installs dependencies (if missing)
#   2. Installs the launchd agent that runs the indexer daily at 08:00
#   3. Installs + starts the launchd agent that keeps the search service
#      running (starts at login, auto-restarts on crash)
# ============================================================================
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Project root: $PROJECT_ROOT"

# --- 1. Python environment --------------------------------------------------
if [ ! -x "$PROJECT_ROOT/venv/bin/python" ]; then
    echo "Creating venv and installing dependencies…"
    python3 -m venv "$PROJECT_ROOT/venv"
    "$PROJECT_ROOT/venv/bin/pip" install --quiet --upgrade pip
    "$PROJECT_ROOT/venv/bin/pip" install --quiet -r "$PROJECT_ROOT/requirements.txt"
else
    echo "venv already present — skipping dependency install."
fi

# --- 2 + 3. launchd agents: daily indexer + always-on search service --------
mkdir -p "$HOME/Library/LaunchAgents"
for PLIST_NAME in com.rajesh.pdfkb.indexer com.rajesh.pdfkb.server; do
    PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"
    echo "Installing launchd agent → $PLIST_DEST"
    # Fill in the real project path (plist templates use __PROJECT_ROOT__).
    sed "s|__PROJECT_ROOT__|$PROJECT_ROOT|g" \
        "$PROJECT_ROOT/launchd/$PLIST_NAME.plist" > "$PLIST_DEST"
    # Reload cleanly: unload any previous version first (ignore if not loaded).
    launchctl bootout "gui/$(id -u)/$PLIST_NAME" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
done

echo
echo "Done. Daily index runs at 08:00; search service is starting now"
echo "(and on every login). Verify with:"
echo "  launchctl list | grep pdfkb"
echo "  → http://localhost:8130/"
