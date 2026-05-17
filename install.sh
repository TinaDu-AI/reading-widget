#!/bin/bash
set -e

# Reading Widget installer
# 1) Copies runtime files to ~/Desktop/reading-widget/
# 2) Installs Übersicht widget to ~/Library/Application Support/Übersicht/widgets/reading.widget/
# 3) Runs update.py once to generate widget.html

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Desktop/reading-widget"
UBER="$HOME/Library/Application Support/Übersicht/widgets/reading.widget"

echo "→ Installing runtime to $DEST"
mkdir -p "$DEST"
cp "$SRC/update.py" "$SRC/template.html" "$DEST/"
[ -f "$DEST/config.json" ] || cp "$SRC/config.default.json" "$DEST/config.json"

echo "→ Installing Übersicht widget to $UBER"
mkdir -p "$UBER"
cp "$SRC/ubersicht/reading.widget/index.coffee" "$UBER/"

if [ -z "$WEREAD_API_KEY" ] && ! grep -q WEREAD_API_KEY "$HOME/.claude/settings.json" 2>/dev/null; then
  echo ""
  echo "⚠️  WEREAD_API_KEY not set."
  echo "   Apply for one via WeRead Agent Gateway (see SKILL.md)."
  echo "   Then add to ~/.claude/settings.json env, or run:"
  echo "   export WEREAD_API_KEY=wrk-xxxxxxxx"
  echo ""
  exit 0
fi

echo "→ Generating widget.html for the first time"
python3 "$DEST/update.py"

echo ""
echo "✅ Installed."
echo "   Open Übersicht (brew install --cask ubersicht), then menu → Refresh All Widgets."
echo "   Widget will appear at top-left of your desktop."
