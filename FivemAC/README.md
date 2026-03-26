# 🛡️ Thinking Anti-Cheat (Thinking AC)

**Thinking AC** is a comprehensive, high-performance Anti-Cheat system for FiveM servers, designed to detect and prevent common cheats while providing a premium real-time Web Dashboard for server administration.

![Thinking AC Dashboard](https://github.com/user-attachments/assets/PLACEHOLDER_IMAGE_URL) *<!-- You can add a screenshot later! -->*

## 🚀 Key Features

### 🔍 Powerful Detections
- **Speed Hack:** Smart vehicle speed limits based on class.
- **NoClip:** Accurately detects air movement without gravity.
- **God Mode:** Monitors invincibility flags and health modifiers.
- **Teleport:** Detects sudden coordinate jumps.
- **Explosion Spam:** Prevents city bombing and massive explosion events.
- **Blacklists:** Built-in weapon and vehicle blacklist system.
- **Resource Protection:** Blocks illegal executors and mod menus (Menyoo, etc).

### 🖥️ Premium Web Dashboard
- **Real-time Monitoring:** View active players and their ping.
- **Alert History:** Log of all recent bans and kicks.
- **Remote Control:** Kick, Ban, and Unban players directly from your browser.
- **Runtime Config:** Adjust AC sensitivity and toggle features without restarting.

### 📊 Integration
- **Discord Logging:** Detailed rich embeds for every detection event.
- **Persistent Bans:** Ban data is saved securely using FiveM's KVP system.

## 🛠️ Installation

1. Download or clone this repository to your `resources/` folder.
2. Rename the folder to `thinking-ac`.
3. Add `ensure thinking-ac` to your `server.cfg`.
4. Configure your Discord Webhook in `shared/config.lua`.
5. Set your Web Panel Token and Port in `shared/config.lua`.

## 🌐 Dashboard Setup

Access your dashboard at:
`http://YOUR_SERVER_IP:3000/?token=YOUR_TOKEN`

*(Default port is 3000, default token is defined in `config.lua`)*

## 📝 Configuration

All settings are managed in `shared/config.lua`. Admins can be added to the `Config.Admins` table to bypass all detections.

---
**Author:** Custom AC  
**License:** MIT
