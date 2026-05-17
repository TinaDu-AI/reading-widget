#!/bin/bash
# Open widget.html as a frameless Chrome app window.
WIDGET="$HOME/Desktop/reading-widget/widget.html"
if [ ! -f "$WIDGET" ]; then
  echo "widget.html not found at $WIDGET — run update.py first." >&2
  exit 1
fi
if [ -d "/Applications/Google Chrome.app" ]; then
  open -na "Google Chrome" --args --app="file://$WIDGET" --window-size=320,640
else
  echo "Chrome not found, opening in default browser." >&2
  open "$WIDGET"
fi
