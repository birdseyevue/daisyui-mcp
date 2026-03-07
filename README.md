<div align="center">

# 🌼 DaisyUI MCP Server

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![MCP](https://img.shields.io/badge/MCP-Protocol-00D1B2?style=for-the-badge)](https://modelcontextprotocol.io)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**A token‑friendly local MCP server for DaisyUI component documentation**

*Give your AI assistant the power to build beautiful UIs with DaisyUI* 🚀

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Configuration](#configuration) • [FAQ](#frequently-asked-questions)

</div>

## ✨ Features

- **Token‑Efficient** – Only exposes relevant context via MCP tools, saving precious tokens
- **60+ Components** – Full coverage of DaisyUI’s component library
- **Auto‑Updatable** – Fetch the latest docs anytime with one command
- **Customizable** – Edit or add your own component docs to fit your project
- **Fast & Lightweight** – Built with [FastMCP](https://github.com/jlowin/fastmcp) for optimal performance

## 🛠️ MCP Tools

This server exposes two tools that AI assistants can use:

- **`list_components`** – Lists all available DaisyUI components with short descriptions
- **`get_component`** – Gets full documentation for a specific component (classes, syntax, examples)

> 💡 The component docs are pulled from [daisyui.com/llms.txt](https://daisyui.com/llms.txt) and stored locally as markdown files. You can also add your own custom components or edit existing ones to match your project needs.

## 📦 Installation

### 1. Clone the repository

```bash
git clone https://github.com/birdseyevue/daisyui-mcp.git
cd daisyui-mcp
```

### 2. Create a virtual environment (recommended)

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

## 🐳 Alternative Installation as Container

You can also run the server using Docker or Podman.

**Using Docker Run:**

```bash
docker run -d -p 8000:8000 --name daisyui-mcp ghcr.io/birdseyevue/daisyui-mcp:latest
```

**Using Docker Compose:**

Create a `compose.yaml` file (or use the one in the repo):

```yaml
services:
  daisyui-mcp:
    image: ghcr.io/birdseyevue/daisyui-mcp:latest
    ports:
      - "8000:8000"
    environment:
      # Overrides the default internal port (8000) if needed
      - PORT=8000
    restart: unless-stopped
```

Then run:

```bash
docker compose up -d
```

## 🚀 Usage

### First‑time setup

On first run, the MCP server will not have any component docs. Fetch them by running:

```bash
python update_components.py
```

This fetches the latest `llms.txt` from DaisyUI and generates all the markdown files in `/components`.

### Running the server

```bash
python mcp_server.py
```

### Updating component docs

If DaisyUI releases new components or updates their docs, simply run:

```bash
python update_components.py
```

## ⚙️ Configuration

Add the MCP server to your AI assistant’s configuration.

<details>
<summary><b>Generic Configuration (Local Python)</b></summary>

*For VS Code (`.vscode/mcp.json`):*
```json
{
  "mcpServers": {
    "daisyui": {
      "command": "<path-to-repo>/venv/bin/python",
      "args": ["<path-to-repo>/mcp_server.py"]
    }
  }
}
```

*For Zed (`~/.config/zed/settings.json`):*
```json
{
  "context_servers": {
    "daisyui": {
      "command": "<path-to-repo>/venv/bin/python",
      "args": ["<path-to-repo>/mcp_server.py"]
    }
  }
}
```

</details>

<details>
<summary><b>Docker Example</b></summary>

When running via Docker, you can connect using either standard `stdio` or HTTP/SSE. Both VS Code (GitHub Copilot) and Zed support both methods natively.

**Option A: Stdio (Spawned directly by Editor)**
Your editor will spin up the container and manage its lifecycle automatically. 

*For VS Code (`.vscode/mcp.json`):*
```json
{
  "mcpServers": {
    "daisyui": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/birdseyevue/daisyui-mcp:latest", "python", "mcp_server.py"]
    }
  }
}
```

*For Zed (`~/.config/zed/settings.json`):*
```json
{
  "context_servers": {
    "daisyui": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "ghcr.io/birdseyevue/daisyui-mcp:latest", "python", "mcp_server.py"]
    }
  }
}
```

**Option B: HTTP / SSE (Background Service)**
If you are running the container continuously in the background (`docker run -d -p 8000:8000...`), connect via the local network port.

*For VS Code (`.vscode/mcp.json`):*
```json
{
  "mcpServers": {
    "daisyui": {
      "type": "sse",
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

*For Zed (`~/.config/zed/settings.json`):*
```json
{
  "context_servers": {
    "daisyUI": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

</details>

## 📁 Project Structure

```text
fastmcp/
├── mcp_server.py          # The MCP server
├── update_components.py   # Script to fetch/update component docs
├── requirements.txt       # Dependencies (just fastmcp)
└── components/            # Markdown files for each component
    ├── button.md
    ├── card.md
    ├── modal.md
    ├── table.md
    └── ... (60+ components)
```

## ❓ Frequently Asked Questions

### Why are `update_components.py` and `mcp_server.py` separate scripts?

It may seem more efficient to combine them into a single script that automatically fetches docs on startup. However, keeping them separate provides important flexibility:

- **Preserving custom components** – If you add or modify component markdown files in `/components`, running `update_components.py` would overwrite them with the fresh upstream content. By separating the update step, you can decide when to pull the latest DaisyUI docs without losing your customizations.

- **Control over updates** – You might want to run the server with a known‑good set of docs, and only update when you explicitly choose to. This separation lets you keep the server running while you fetch updates independently.

> **If you don’t need custom components and prefer a one‑step launch**, you can create a simple wrapper script (`.bat`, `.sh`, or `.ps1`) that runs both commands sequentially, or modify the server to call the update function on startup. The current design prioritizes flexibility for users who want to keep their own modifications.

### Stdio vs HTTP/SSE: Which one should I use?

The Model Context Protocol supports two modes of communication. **Stdio** (Standard Input/Output) is the most common; your AI editor spawns the server as a local process. It is highly secure and ties the server's lifecycle directly to the editor. **HTTP/SSE** allows the server to run as a standalone web service (e.g., in a background Docker container). This prevents local environment pollution, and modern editors like VS Code (via GitHub Copilot) and Zed support it natively! Use HTTP/SSE if you are using multiple editors or tools that should be able to access the DaisyUI MCP Server, or in case you want to host it somewhere to use for multiple developers.

## ❗ Disclaimer

DaisyUI has an official [Blueprint MCP](https://daisyui.com/blueprint/) ($600 lifetime) with premium features.

This project is **not** that. It’s a free, DIY alternative **using their publicly available documentation**.

- ✅ No competition
- ✅ Just a personal tool I wanted to share

> If you want an official experience with premium features, consider supporting DaisyUI by purchasing their [Blueprint MCP](https://daisyui.com/blueprint/)!

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit pull requests

## 📄 License

<div align="center">

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

*Free to use, modify, and distribute! Have fun!* 🎉

</div>

<div align="center">

Made with ❤️ for the DaisyUI community

⭐ Star this repo if you find it useful!

</div>
