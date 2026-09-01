
# PipePipe-DanmakuTranslate (English)

> An **unofficial personal fork** of **PipePipe** (a fork of NewPipe) that adds **YouTube danmaku (bullet comment) auto-translation** and **online subtitles**.
> This project is for the author's personal use / learning purposes. **No maintenance is guaranteed**.

**📄 Language / 语言**: [中文](README.md) | [English](README.en.md)

---

## ⚠️ Important Disclaimer (Read First)

- **Original Author & Copyright**: This project is based on [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe), which is itself a fork of [NewPipe](https://github.com/TeamNewPipe/NewPipe). **All credit goes to the original authors**; this repository only adds the "danmaku translation" feature on top of the upstream, preserving all upstream functionality.
- **License**: This project follows the upstream **GPL-3.0** (see [LICENSE](LICENSE)). Following GPL-3.0 compliance: retain LICENSE, retain original author attribution, derivatives are also released under GPL-3.0, provide corresponding source code.
- **Code Origin**: The entire codebase is **"vibe coding"** (AI-assisted improvisation, rapid iteration), **not thoroughly tested**, may contain bugs, **no warranty is provided**, not recommended for production/official use.
- **Maintenance Status**: The author uses this **for personal use primarily**, **no commitment to ongoing maintenance**, no guarantee of following upstream updates or fixing issues.
- **Unofficial**: This is NOT an official release of PipePipe / NewPipe. **Do not pass it off as an official version** when distributing/sharing; please note that this is "a personal fork with danmaku translation functionality".
- **Recommended Engine**: The default translation engine is not recommended. For normal use, only switch to LLM and configure an API. You can modify the related settings in Settings → Advanced → Danmaku Settings.

---

## 🎯 Feature Overview

A new **☁️ Danmaku Translation** button is added to PipePipe's player, which:

1. **Downloads the complete danmaku list** for a video.
2. **Translates** each unique entry (deduplicated).
3. **Caches translation results**.
4. **Loads translations into the danmaku stream** aligned to the video timeline, auto-displaying translated danmaku during playback.
5. **Auto-loads cache** when re-entering the same video (no re-download/translation needed).

---

## 🚫 Important Limitation: **Replay/VOD Only, NOT Live**

> **❗ The "full download" approach** of this feature relies on the **replay (VOD / live replay) already having a complete danmaku list**.
> - ✅ **Replay / VOD / Live Replay**: Can download all danmaku → translate → replay by timeline.
> - ❗ **Currently ongoing Live streams**: **NOT supported**. Live danmaku is a "real-time stream" with no "complete list" to download; this project does not do streaming real-time danmaku translation.

**Reason**: This project uses a **"download all first, then batch translate, then load"** batch approach (see code logic below), which is incompatible with live danmaku streams (which can only be captured in real-time, no full replay available).

---

## 🧠 Code Logic (Batch Approach)

**Core idea: Download all danmaku → Translate → Cache → Load by timeline** (NOT streaming per-item translation).

Taking a YouTube live replay as an example (`YouTubeReplayDanmakuFetcher`):

1. **Download all danmaku**
   - Extract the initial continuation for the live replay from the video page.
   - Paginate through `live_chat/get_live_chat_replay` until the entire replay is fetched.
   - Each danmaku yields: **text** (`replayChatItemAction...message.runs[].text`) and **timestamp** (`videoOffsetTimeMsec`, millisecond position within the video).
   - Uses "playerOffset advances with page number" pagination to ensure the complete list is retrieved (not just one page / treated as a live stream).

2. **Deduplicate + Translate**
   - **Deduplicate by text** (same danmaku text is only translated once, saving tokens/time).
   - Translate in batches using the selected engine, **cache the results**.

3. **Cache**
   - Each danmaku is stored as **`original + translation`** in `files/danmaku/<videoHash>.json`, with an index maintained for the "Cache Management" UI to list/delete.
   - **Original and translation are stored separately**, so the "Show Original" toggle can be switched at any time (on load/download, the full `translation\noriginal` is always stored; rendering decides whether to show original based on the toggle).

4. **Load by Timeline**
   - After translation completes, the full list is handed to the danmaku player (`MovieBulletCommentsPlayer.loadDownloaded`).
   - The player **plays while advancing by current position**, fetching danmaku falling within the `[previous frame position, current position)` time window and rendering them — **displaying translated danmaku aligned to the video timeline**.

5. **Auto-Load**
   - Next time entering the same video, check if cache exists: **yes → load cache directly** (instant, no re-download/translation); **no → normal load**.

> So overall: **Full download → Deduplicated translation → Persistent cache → Timeline-replayed display**. **Cannot be used for Live**, only for **Replay/VOD**.

---

## 🎬 Online Subtitles (External Subtitles)

Besides danmaku translation, this fork also adds **online subtitles**: manually/jump-load ASS/SRT subtitles for a video and overlay them, plus a **"Videos with Subtitles" jump list**.

### 1. Load Online Subtitles (Player)
- A **Subtitle button** is added to the player (next to the danmaku translation button):
  - **First tap** → Fetch the video's subtitles from the subtitle repo online (`<repoBase>/<videoId>.ass`, fallback to `.srt`), parse and overlay.
  - **Tap again** → Show/Hide subtitles (no re-download); auto-clear when switching videos.
  - **Long-press subtitle button** → Cycle subtitle font size: 50% → 80% → 120% → loop (default 80%). Selection is remembered.
- **Load Local Subtitles**: **➕ button** next to the subtitle button → opens system file picker to select `.ass` / `.srt` files on the phone (supports UTF-8 / UTF-16 with BOM / GBK), parsed and overlaid on the currently playing video (same rendering as online subtitles; prompts to start playback if no video is playing).
- **ASS Speaker Separation**: Respects positions fixed in Aegisub within the ASS file, and **automatically assigns different outline colors per speaker**; text uses the bundled **Xiawu Wenkai** font.
- **Position**: Preserves ASS original line positions and `\pos(x,y)` positioning per line (multi-line English+Chinese are centered by per-line width, not skewed left).
- When jumping to a video from the list, **subtitles auto-load after playback starts** (not too early).

### 2. "Videos with Subtitles" Jump List
Below "History" in the left drawer, a new **"Videos with Subtitles"** entry opens:
- Lists videos from the subtitle repo's `index/index.json`: **thumbnail + title** (title from index.json, can be your own translation).
- **Search**: Top search box filters by **title/video ID** in real-time.
- **Newest first**: Sorted by `date` field in index.json **new→old** (when present); otherwise by manifest order.
- **Infinite scroll**: Auto-loads more when reaching the bottom (batches of 50), won't dump everything at once.
- **One-click cache clear**: Delete icon in top-right, clears subtitle cache and re-fetches.
- Tap an item → Jumps to that video and auto-loads subtitles after playback starts.

### 3. Subtitle Repository (How to Add Your Own Subtitles)
- Structure (public example: `github.com/CCCMNSB/subtitles`):
  ```
  danmaku/<videoId>.ass
  subtitles/<videoId>.ass|.srt   ← Subtitle files (named by video ID)
  index/index.json              ← Manifest [{id, title, date}], order = display order
  ```
- For each new video subtitle: put `<videoId>.ass` into `subtitles/`, add an entry `{id, title, date}` to `index.json`. `title` can be your translation — the app displays/searches directly, **no API calls**.
- The jump list **only reads `index.json`**, so videos not in `index.json` won't appear in the list.

### 4. Settings (Settings → Advanced → Danmaku Settings → Online Subtitles)
- **Enable Online Subtitles**: Toggle (default ON).
- **Subtitle Repo Base URL**: Default `https://raw.githubusercontent.com/CCCMNSB/subtitles/main/subtitles`. The list reads `index/index.json` from its `index/`; **changing the repo switches both list and subtitle source** (auto-refreshes when returning to the list page).
- **Subtitle Font**: Xiawu Wenkai / Serif / Sans-serif / Monospace.
- **Subtitle Cache**: Shows cached count/size, can **delete individually / one-click clear** (re-fetch after clearing).

### 5. Caching
- List manifest `index.json`: Cached with **10-minute TTL**, stored **per source repo** (changing repo auto-invalidates, re-fetches).
- Loaded subtitles: Local cache (**cache-first**), instant on re-play.
- Cache management: See "Subtitle Cache" in settings above.

### 6. Notes
- Online subtitles are **manually/jump-triggered**, not auto-scanning all videos; they are **external subtitles** (don't modify the video itself, different from "hard-burned" subtitles).
- The subtitle repo is public and fine for multi-user use: uses **raw CDN / image CDN**, does not depend on rate-limited `api.github.com`.

---

## 🎞️ Player Buttons

Buttons added to the player control bar (left to right):

| Button | Icon | Function |
|---|---|---|
| **Online Danmaku (ASS)** | <img width="108" height="95" alt="bc" src="https://github.com/user-attachments/assets/c2b1ecf7-67d4-49ee-ae79-cc531897be8a" /> | Load online ASS danmaku (`\move` scrolling bullet comments). **First tap**: Check local cache → if cached, load directly (instant); else download `danmaku/<videoId>.ass` from the subtitle repo and cache. **Tap again**: Show/Hide (no re-download). Auto-clears when switching videos. If using the LLM translation engine, it replaces PipePipe's built-in danmaku system — translations are loaded into PipePipe's official danmaku system. |
| **Subtitles** | <img width="87" height="82" alt="sub" src="https://github.com/user-attachments/assets/8614e518-a566-4992-8ca6-e658d4d55dae" /> | Load online subtitles (`.ass` / `.srt`), overlay display. **Tap again**: Show/Hide. **Long-press**: Cycle subtitle font size 50% → 80% → 120% (default 80%, selection remembered). |
| **➕ Local Subtitles** | <img width="77" height="77" alt="+" src="https://github.com/user-attachments/assets/d8ca6111-06ad-4878-ba20-130c4740fb33" /> | Open system file picker, select `.ass` / `.srt` files on the phone, parse and overlay on the current video. |

### Online Danmaku (ASS) Details

- **Source**: Subtitle repo `danmaku/<videoId>.ass` (public repo, loaded via raw CDN).
- **Rendering**: ASS `\move` commands drive bullet comments scrolling right-to-left (canvas auto-clips; bullet comments "push in" from the edge).
- **Font Size**: Independent from subtitle font size, adjustable in settings (default 80%).
- **Original Display**: Toggle "Show original below translation" (ASS `translated\Noriginal` format).
- **Refresh Rate (FPS)**: Selectable 30 / 60 / 90 / 120 fps (default 60). Higher = smoother, but more battery drain.
- **Cache**: Danmaku files cached in app internal storage (`files/subtitles/danmaku/`), **auto-cleared on app uninstall** (`ACTION_DELETE` broadcast receiver).
- **Replay Only**: Same as danmaku translation, **Live is NOT supported** (ASS file must already exist in the repo).

### Settings (Settings → Advanced → Danmaku Settings)

| Setting | Description |
|---|---|
| **Danmaku Font Size** | Font size scale for online danmaku (ASS), independent from subtitle font. 80% = default. |
| **Danmaku Refresh Rate** | Frame rate for danmaku scrolling animation: 30 / 60 / 90 / 120 fps. Higher = smoother, but more battery drain. 60 = default. |
| **Show Original Below Translation** | When ON, original text is shown in smaller font below the translation; when OFF, only translation is shown. |
| **Translation Engine** | Online repo / LLM / ML Kit. |
| **Danmaku Cache** | Manage cached translated danmaku (delete individually / one-click clear). |

---

## ⚙️ Translation Engine (Switchable: Settings → Advanced → Danmaku Settings → Translation Engine)

| Engine | Description | Requires Internet | Requires Google Services | Recommended |
|---|---|---|---|---|
| **LLM** (**Recommended**) | OpenAI-compatible LLM (DeepSeek cloud / local Ollama/llama.cpp) | Yes (local via LAN) | No | ⭐ **Strongly Recommended** |
| **ML Kit** | Google on-device offline model | No | ✅ Required | ⚠️ Not Recommended |

> **🟢 Only LLM is recommended.** Reason: LLM translation quality is best, and **Chinese phones don't need Google Play Services** to use it (just need internet).
> **🔴 ML Kit is NOT recommended**: It requires **Google Play Services** to download offline models; most Chinese phones don't have it → will fail; and quality is mediocre. Only use as an offline fallback when you **don't want to use internet / have Google Services**.

**Recommended LLM Setup (DeepSeek)** — "LLM source" in settings toggles with one tap:
- **Cloud (online)**: Fill in OpenAI-compatible URL + key + model (DeepSeek: `https://api.deepseek.com` + `deepseek-chat`).
- **Local (LAN)**: Connect to a local LLM running on your own computer (Ollama / llama.cpp, exposing an OpenAI-compatible `/v1` endpoint). Phone calls it via LAN (no key needed, offline).

---

## 🎛️ Other Features

- **Progress Toast**: Toast progress during download/translation, interval adjustable (`Danmaku Settings → Download Progress Interval`, default every 100 items).
- **Show Original Toggle**: `Danmaku Settings → Show Original`. ON = translation + original (two lines); OFF = translation only. Toggle anytime, always effective.
- **Cache Management**: `Danmaku Settings → Danmaku Cache → Manage`, lists cached videos (count/size), can delete individually / one-click clear.
- **Top Danmaku Clipping Fix**: Two-line text no longer gets pushed out of the visible area.

---

## 🛠️ Build / Package

Dependencies:
- JDK (this project uses JDK 25)
- Android SDK
- Gradle (wrapper included in repo)

```bash
cd PipePipeClient
./gradlew :app:assembleDebug      # debug
./gradlew :app:assembleRelease    # release (requires proper signing)
```

> Release signing requires environment variables: `KEY_PATH` / `KEY_STORE_PASSWORD` / `KEY_ALIAS` / `KEY_PASSWORD`.

---

## 📦 Distribution

- APK should be provided **together with source code (this repository)** to comply with GPL-3.0's "source provision" requirement.
- When sharing, please note: "This is a **personal fork** of PipePipe with added danmaku translation, **replay/VOD only**; unofficial, unmaintained."

---

## 🙏 Acknowledgments / Copyright

- [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe) — PipePipe author
- [TeamNewPipe/NewPipe](https://github.com/TeamNewPipe/NewPipe) — Original NewPipe author
- This project only adds "danmaku translation" and "subtitle loading" features on top of upstream. **All upstream code belongs to their respective authors**.

**License**: GPL-3.0 · [LICENSE](LICENSE)

---
