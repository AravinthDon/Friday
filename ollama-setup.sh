#!/bin/bash

echo "🔧 Updating and installing required packages..."
sudo apt update && sudo apt install -y curl docker.io docker-compose git

echo "🐍 Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🚀 Starting Tailscale..."
sudo tailscaled --tun=userspace-networking &
sudo tailscale up

echo "💡 NOTE: Go to the above URL to authenticate this machine with your Tailscale network."

echo "⏳ Waiting for Tailscale authentication to complete..."
while ! tailscale status | grep -q "Logged in as"; do
  sleep 2
done

echo "✅ Tailscale authenticated!"

echo "📦 Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

echo "📥 Setting up friday..."
cat <<'EOF' >Modelfile
FROM llama3

SYSTEM "You are Friday, an expert software engineer and hacker." 
EOF

ollama create friday -f Modelfile

echo "💻 Starting Ollama in background..."
nohup ollama serve >ollama.log 2>&1 &

echo "🌐 Cloning and starting Open WebUI..."
git clone https://github.com/open-webui/open-webui.git
cd open-webui

# Run the Web UI on port 3000
docker compose up -d

echo "✅ Setup complete!"
tailscale_ip=$(tailscale ip -4 | head -n1)
echo ""
echo "🌍 Access the Web UI securely from your Mac at:"
echo "👉 http://$tailscale_ip:3000"
echo ""
echo "🛡️ This address only works within your Tailscale network."
