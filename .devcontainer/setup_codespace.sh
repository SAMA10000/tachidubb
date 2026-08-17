#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -qq
sudo apt-get install -y -qq ffmpeg curl jq lsof

if [[ ! -f .codespace_install_complete ]]; then
  printf 'n3' | bash install.sh
  touch .codespace_install_complete
fi

cat > config-user.json <<'JSON'
{
  "whisper_model": "medium",
  "auto_denoise": true,
  "vad_enabled": true,
  "vad_threshold": 0.5,
  "translation_model": "qwen3:4b",
  "ollama_url": "http://localhost:11434",
  "tts_engine": "edge-tts",
  "tts_speed": "quality",
  "warmup_on_start": false,
  "open_browser": false,
  "server_port": 8910,
  "hf_token": ""
}
JSON

echo "TACHIDUBB_CODESPACE_SETUP=PASS"
echo "Run: bash .devcontainer/start_codespace.sh"
