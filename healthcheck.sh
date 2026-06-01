#!/bin/sh
# Healthy when the app prints its greeting.
/app.sh | grep -q "release-please-rc-flow" && echo "healthy"
