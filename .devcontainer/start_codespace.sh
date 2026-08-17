#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -d venv ]]; then
  echo "TachiDUBB is not installed yet. Run: bash .devcontainer/setup_codespace.sh"
  exit 1
fi

source venv/bin/activate

if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  nohup ollama serve >/tmp/tachidubb-ollama.log 2>&1 &
  sleep 3
fi

if ! ollama list 2>/dev/null | grep -q '^qwen3:4b'; then
  ollama pull qwen3:4b
fi

if curl -fsS http://127.0.0.1:8910/ >/dev/null 2>&1; then
  echo "TACHIDUBB_SERVER=ALREADY_RUNNING"
  exit 0
fi

nohup python server.py >/tmp/tachidubb-server.log 2>&1 &
SERVER_PID=$!

echo "$SERVER_PID" > /tmp/tachidubb-server.pid

for _ in $(seq 1 90); do
  if curl -fsS http://127.0.0.1:8910/ >/dev/null 2>&1; then
    echo "TACHIDUBB_SERVER=PASS"
    echo "PORT=8910"
    exit 0
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "TACHIDUBB_SERVER=FAIL"
    tail -n 80 /tmp/tachidubb-server.log || true
    exit 1
  fi
  sleep 2
done

echo "TACHIDUBB_SERVER=TIMEOUT"
tail -n 80 /tmp/tachidubb-server.log || true
exit 1
