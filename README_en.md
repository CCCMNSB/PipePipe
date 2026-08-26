
**[中文](README.md) | English | [Original](README_original.md)**

<hr>

# PipePipe-DanmakuTranslate (English)

> An **unofficial personal fork** of **PipePipe** (a NewPipe fork) that adds **danmaku (bullet-comment) auto-translation**.
> For personal use / learning; **not guaranteed to be maintained**.

## ⚠️ Important notices (please read)

- **Authors & copyright**: Based on [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe), which is based on [NewPipe](https://github.com/TeamNewPipe/NewPipe). **All credit goes to the original authors**; this repo only adds the "danmaku translation" feature on top and keeps all upstream functionality.
- **License**: GPL-3.0 (see [LICENSE](LICENSE)). Keep the LICENSE, credit the original authors, publish derivatives under GPL-3.0, and provide the corresponding source.
- **Code origin**: This `code` is **vibe coding** (generated/iterated with AI), **not fully tested**, may have bugs, **no warranty**. Not for production.
- **Maintenance**: **Personal use only**, **not maintained**, no promise to follow upstream updates or fix issues.
- **Non-official**: This is NOT an official PipePipe / NewPipe build. Don't present it as official.

## 🎯 Features

A new **☁️ danmaku-translate** button in the PipePipe player that:
1. Downloads the video's **full danmaku list**.
2. Translates each (deduplicated) text.
3. **Caches** the translations.
4. Loads them onto the timeline as the video plays.
5. **Auto-loads the cache** the next time you open the same video.

## 🚫 Important limitation: **replay only, NOT for live streams**

> The "full download" approach requires the **replay/VOD to already have a complete danmaku list**.
> - ✅ **Replays / VODs**: can download all danmaku → translate → replay by timeline.
> - ❌ **Ongoing live streams**: **not supported**. Live danmaku is a real-time stream with no "full list" to download; this project does not do live streaming translation.

## 🧠 How it works (batch approach)

**Download all danmaku → translate → cache → load by timeline** (not streaming item-by-item). For a YouTube replay (`YouTubeReplayDanmakuFetcher`):
1. **Download full list** — paginate `live_chat/get_live_chat_replay` until the whole replay is pulled, getting text + timestamp (`videoOffsetTimeMsec`).
2. **Deduplicate + translate** — translate each unique text with the selected engine; cache results.
3. **Cache** — store each as `original + translation` in `files/danmaku/<hash>.json`, with an index for the cache-management screen. Original and translation are stored separately, so the "show original" toggle works anytime.
4. **Load by timeline** — hand the full list to `MovieBulletCommentsPlayer.loadDownloaded`, which draws comments in the `[previous position, current position)` time window as the video plays.
5. **Auto-load** — on re-opening the same video, if a cache exists it loads instantly (no download/re-translate).

**So: full download → deduplicate translate → persist cache → replay by timeline. Not for live; replay only.**

## ⚙️ Translation engines (Settings → Bullet comments → Translation engine)

| Engine | Description | Needs network | Needs Google services | Recommended |
|---|---|---|---|---|
| **LLM** (**recommended**) | OpenAI-compatible LLM (DeepSeek cloud / local Ollama/llama.cpp) | Yes (local = LAN) | No | ⭐ **Strongly recommended** |
| **ML Kit** | Google on-device model | No | ✅ Yes | ⚠️ Not recommended |

> **🟢 Only LLM is recommended.** Best quality, and works on Chinese/domestic phones **without Google services** (just needs network).
> **🔴 ML Kit is not recommended**: it needs **Google Play services** to download the offline model, which most domestic phones lack → it fails; also lower quality. Use it only if you can't/won't use network.

**LLM setup** (Settings → "LLM source"):
- **Cloud (online)**: fill OpenAI-compatible base URL + key + model (DeepSeek: `https://api.deepseek.com` + `deepseek-chat`).
- **Local (LAN)**: connect to a local LLM on your own computer (Ollama / llama.cpp exposing an OpenAI-compatible `/v1` API), called over the LAN (no key, offline).

## 🎛️ Other features

- **Progress toasts** with adjustable interval (`Download progress notification interval`, default every 100).
- **Show-original toggle** — on = translation+original (2 lines); off = translation only. Works any time.
- **Cache management** (`Danmaku cache → Manage`) — list cached videos (count/size), delete individually / clear all.
- **Top clip fix** — two-line text no longer overflows the top.

## 🛠️ Build

Requires JDK (built with JDK 25), Android SDK, Gradle wrapper.
```bash
cd PipePipeClient
./gradlew :app:assembleDebug      # debug
./gradlew :app:assembleRelease    # release (needs signing)
```
> Release signing env vars: `KEY_PATH` / `KEY_STORE_PASSWORD` / `KEY_ALIAS` / `KEY_PASSWORD`.

## 📦 Distribution

- Ship the APK **together with this source repo** to comply with GPL-3.0's source-provision requirement.
- When sharing, note: "This is a **personal fork** of PipePipe, adding danmaku translation, **for replay only**; non-official, unmaintained."

## 🙏 Credits / Copyright

- [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe) — PipePipe author
- [TeamNewPipe/NewPipe](https://github.com/TeamNewPipe/NewPipe) — NewPipe original author
- This project only adds "danmaku translation"; **all upstream code copyright belongs to the original authors**.

**License**: GPL-3.0 · [LICENSE](LICENSE)