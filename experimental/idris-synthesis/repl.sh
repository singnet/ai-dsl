#!/usr/bin/env bash
set -euo pipefail

rlwrap idris2 -p contrib -p elab-util $1
