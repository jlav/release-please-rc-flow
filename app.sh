#!/bin/sh
ver=$(tr -d '[:space:]' < /version.txt 2>/dev/null)
echo "hello from release-please-rc-flow v${ver:-unknown}"
echo "Welcome aboard! This container is running happily."
echo "Tip: pass --help to see available options."
