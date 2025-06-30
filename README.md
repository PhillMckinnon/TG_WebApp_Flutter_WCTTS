# 🤖🧠 Telegram Voice Assistant Bot

[![Docker](https://img.shields.io/badge/docker-compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg?logo=python)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/flutter-ui-blue?logo=flutter)](https://flutter.dev/)
[![Telegram](https://img.shields.io/badge/telegram-bot-blue?logo=telegram)](https://core.telegram.org/bots)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

> A Telegram mini app for transcribing and synthesizing speech messages using Whisper and Coqui TTS, delivered through a clean Flutter web interface.

---

## 🎯 What It Does

* 🎤 **Accepts media files** via a Telegram mini app
* ✍️ **Transcribes speech to text** using [OpenAI Whisper](https://github.com/openai/whisper)
* 🔊 **Generates speech responses** using [Coqui TTS](https://github.com/coqui-ai/TTS)
* 🌍 **Supports multiple languages**
* 💬 **Works directly inside Telegram Web** as a [Mini App](https://core.telegram.org/bots/webapps)
* 📦 Easily deployable using `Docker` + `ngrok`

---

## 🛠️ Tech Stack

* **Backend**: Python, Sanic, Whisper, Coqui TTS
* **Frontend**: Flutter Web
* **Bot API Integration**: Telegram Bot API
* **Hosting**: Docker + Docker Compose + Ngrok
* **Web Server**: Nginx (templated config with CORS)

---

## 🚀 Getting Started

### 🔧 Prerequisites

* Git
* Docker
* Docker Compose
* Ngrok account
* Telegram Account
* Telegram Bot (via [BotFather](https://t.me/botfather))

---

### 🏗️ Setup & Launch

1. **Clone the repo**:

   ```bash
   git clone https://github.com/PhillMckinnon/TG_WebApp_Flutter_WCTTS
   cd TG_WebApp_Flutter_WCTTS
   ```

2. **Configure ngrok** (`ngrok.yml`):

   ```yaml
   tunnels:
     web:
       proto: http
       addr: 8080
       host_header: rewrite
   ```

3. **Set your environment variables** (`.env`):

   ```env
   COQUI_TOS_AGREED=1
   PORT=5000
   TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
   MAX_DAILY_LIMIT=3
   NGROK_ORIGIN=https://<your-subdomain>.ngrok-free.app
   DURATION=360
   MAX_SIZE=20
   ```

4. **Start the services**:

   ```bash
   docker-compose build
   docker-compose up
   ```

5. **Expose the app** via ngrok:

   ```bash
   ngrok http 8080 --host-header=rewrite
   ```

6. **Set up Telegram Mini App** in **BotFather**:

   * Set up the mini app URL
   * Paste your `NGROK_ORIGIN` (e.g. `https://yourname.ngrok-free.app`)
   * Optional: `/setmenubutton` to attach the web app to the bot

---

## 🌐 Access Points

* 🎯 **Frontend Web App**: `http://localhost:8080` or your `ngrok` URL
* 🧠 **Backend API**: `http://localhost:5000`
* 🤖 **Telegram Bot Mini App**: use your bot and tap the web button

---

## ⚙️ Configuration Options

Customize limits and behavior by editing:

| File                  | Purpose                                            |
| --------------------- | -------------------------------------------------- |
| `.env`                | API token, file size/duration limits, ngrok domain |
| `ngrok.yml`           | Public tunnel mapping                              |
| `docker-compose.yml`  | Port exposure and service control                  |
| `nginx.conf.template` | Proxy rules & CORS support                         |
| `entrypoint.sh`       | Dynamic frontend + backend routing                 |

---

## 📐 Default Limits

* 🕒 **Max file duration**: `360s` (set in `.env`)
* 📦 **Max file size**: `20MB` (set in both `.env` and `nginx.conf.template`)
* 🔁 **Daily message limit**: `3` messages per user (example value)

---

## 📫 Contact

Questions or contributions?

* ✉️ Email: [phillipmckinnonwork@proton.me](mailto:phillipmckinnonwork@proton.me)
* 💻 GitHub: [@PhillMckinnon](https://github.com/PhillMckinnon)

---

## 📝 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---
