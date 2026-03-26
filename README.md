# 🛡️ Thinking AC - FiveM Edition

<div align="center">
  <p align="center">
    <img src="https://img.shields.io/badge/FiveM-Standalone-blue.svg?style=for-the-badge" />
    <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" />
    <img src="https://img.shields.io/badge/Status-Stable-success.svg?style=for-the-badge" />
  </p>
  
  <h3><b>Advanced Anti-Cheat for FiveM GTA V Servers</b></h3>
  
  <p>
    <b>Thinking AC</b> is a high-performance, lightweight <b>Standalone Anti-Cheat</b> for FiveM (GTA V) servers. 
    Designed to protect your server from mod menus, exploitative behaviors, and common script-side attacks with zero performance impact.
  </p>
</div>

---

## 🌟 About This Project
> [!NOTE]
> This is my **first major scripting project** released on GitHub! I developed this to provide a simple yet powerful security solution for the FiveM community.

---

## 🚀 Key Features

| Category | Protection Module | Description |
| :--- | :--- | :--- |
| 🛡️ **General** | **Anti-GodMode** | Detects health manipulation and invincibility. |
| 🚀 **Movement** | **Anti-NoClip** | Advanced position tracking to block teleporting and noclip. |
| 👁️ **Visuals** | **Thermal/Night Vision** | Blocks unauthorized use of advanced vision modes. |
| 🕵️ **Stealth** | **Anti-Spectate** | Detects when a non-admin attempts to spectate players. |
| 💣 **Combat** | **Explosion Filter** | Blocks mass explosion spam and "City Bombing" attacks. |
| 📦 **Entities** | **Spawning Protection** | Limits vehicle and ped spawning to prevent crash attempts. |
| 🔗 **Logging** | **Discord Webhooks** | Real-time, detailed logs of all detections to your staff channel. |

---

## 🛠️ Installation & Setup

1. **Download:** Clone or download the `thinking_ac_fivem` folder.
2. **Resource Placement:** Move the folder to your server's `resources/` directory.
3. **Configuration:** 
   - Open [config.lua](cci:7://file:///d:/project1/ai%20assistant/classRP_anticheat/config.lua:0:0-0:0).
   - Add your **Discord Webhook URL** for logging.
4. **Activation:** Add the following to your `server.cfg`:
   ```xml
   📜 Admin Commands
Keep your server under control with simple, built-in commands:

/ac_status - View current protection module status.
/ac_kick <id> <reason> - Kick a player using the Thinking-AC system.
🚀 Why Use Thinking AC?
Zero Performance Lag: Optimized for high-population servers.
Standalone Compatibility: Works with ESX, QBCore, or custom frameworks.
Modern Standards: Built with the latest Cfx.re manifest and Lua 5.4.
📄 License
Distributed under the MIT License. See 

LICENSE
 file for details.

Developed with ❤️ for the FiveM Community.ensure thinking_ac_fivem
