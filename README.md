
<div align=center>
**[中文](#中文) &nbsp;|&nbsp; [English](#english) &nbsp;|&nbsp; [原版描述](#原版描述)**
</div>

<hr>

## 中文

# PipePipe-DanmakuTranslate

> 一个给 **PipePipe**（NewPipe 的 fork）添加 **弹幕（danmaku）自动翻译** 的**非官方个人 fork**。
> 本项目仅供作者自用 / 学习交流，**不保证维护**。

---

## ⚠️ 重要声明（请先读）

- **原创作者 & 版权**：本项目基于 [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe)，PipePipe 又基于 [NewPipe](https://github.com/TeamNewPipe/NewPipe)。**所有功劳归于原作者**；本仓库只是在其基础上新增了"弹幕翻译"这一项功能，并保留了上游的全部功能。
- **许可证**：本项目沿用上游 **GPL-3.0**（见 [LICENSE](LICENSE)）。遵循 [[GPL-3.0 合规约定]](LICENSE)：保留 LICENSE、保留原作者署名、衍生作品同样以 GPL-3.0 发布、提供对应源码。
- **代码来源**：整个 `code` 部分是 **"vibe coding"**（伴随 AI 即兴生成、快速迭代），**未经充分测试**，可能存在 bug，**不提供任何保证**，不建议用于生产/正式环境。
- **维护状态**：作者**自用为主**，**不承诺持续维护**，不保证跟进上游更新、不保证修复问题。
- **非官方**：这不是 PipePipe / NewPipe 的官方发行版，**请勿将其冒充官方版本**；分发/分享时请注明是"带弹幕翻译功能的个人 fork"。
- **推荐引擎**：不推荐使用默认的翻译引擎。正常使用只建议切换llm并配置api。可以在设置 → 高级 → 弹幕设置里修改相关设定。

---

## 🎯 功能概述

在 PipePipe 的播放器里新增一个 **☁️ 弹幕翻译**按钮，实现：

1. **下载视频的完整弹幕列表**。
2. **逐条（去重后）翻译**。
3. **缓存翻译结果**。
4. **按时间轴加载到弹幕流**，观看时自动显示翻译。
5. 再次进入该视频时**自动加载缓存**（无需重复下载+翻译）。

---

## 🚫 重要限制：**仅适用于"回放"，不适用于"直播"**

> **❗ 该功能的"全量下载"方式**依赖**回放（VOD / 直播回放）已经产生完整的弹幕列表**。
> - ✅ **回放 / VOD / 直播回放**：可以下载全部弹幕 → 翻译 → 按时间轴回放。
> - ❌ **正在进行的直播（Live）**：**无法使用**。直播的弹幕是"实时流"，没有"全量列表"可下载；本项目不做弹幕流式实时翻译。

**原因**：本项目采用 **"先拿全量、再整批翻译、最后加载"** 的批量思路（见下文代码逻辑），这与正在直播的弹幕流（只能实时抓取、无法回放全量）不兼容。

---

## 🧠 代码逻辑说明（批量化）

**核心思路：下载全部弹幕 → 翻译 → 缓存 → 按时间轴加载**（不是流式逐条翻译）。

以 YouTube 直播回放为例（`YouTubeReplayDanmakuFetcher`）：

1. **下载全量弹幕**
   - 从视频页提取直播回放的初始 continuation。
   - 通过 `live_chat/get_live_chat_replay` 逐页翻页（`paginate`），直到取完整个回放。
   - 每条弹幕得到：**文本**（`replayChatItemAction...message.runs[].text`）和**时间戳**（`videoOffsetTimeMsec`，视频内毫秒位置）。
   - 采用"playerOffset 随页码推进"的翻页方式，保证能拿到完整列表（而非只拿到一页/当成直播流）。

2. **去重 + 翻译**
   - 把**文本去重**（相同弹幕只翻译一次，省 token / 时间）。
   - 用所选引擎逐批翻译（每批若干条），并**缓存结果**。

3. **缓存**
   - 每条弹幕以 **`原文 + 译文`** 的形式存入 `files/danmaku/<视频hash>.json`，并维护一个索引，供"缓存管理"界面列出/删除。
   - **原文 与 译文 分开存**，因此"显示原文"开关可以随时切换（加载/下载时总是存完整 `译文\n原文`，渲染时才按开关决定是否显示原文）。

4. **按时间轴加载**
   - 翻译完成后，把完整列表交给弹幕播放器（`MovieBulletCommentsPlayer.loadDownloaded`）。
   - 播放器**边播边按当前播放位置**，取出落在 `[上一帧位置, 当前位置)` 时间窗口内的弹幕画出来——**显示的是翻译后的弹幕，且与视频时间轴对齐**。

5. **自动加载**
   - 下次进入同一个视频时，检测是否存在缓存：**有 → 直接加载缓存**（秒开，不重新下载/翻译）；**无 → 走正常加载**。

> 所以整体是：**全量下载 → 去重翻译 → 持久化缓存 → 按时间轴回放展示**。**不能用于直播**，只能用于**回放**。

---

## ⚙️ 翻译引擎（可切换：设置 → 高级 → 弹幕设置 → 翻译引擎）

| 引擎 | 说明 | 需联网 | 需 Google 服务 | 推荐 |
|---|---|---|---|---|
| **LLM**（**推荐**） | OpenAI 兼容大模型（DeepSeek 云端 / 本地 Ollama/llama.cpp）| 是（本地走局域网） | 否 | ⭐ **强烈推荐** |
| **ML Kit** | Google 端上离线模型 | 否 | ✅ 需要 | ⚠️ 不推荐 |

> **🟢 推荐只使用 LLM。** 理由：LLM 翻译质量最好，且**国内手机无需 Google 服务框架**也能用（联网即可）。
> **🔴 ML Kit 不推荐**：它需要 **Google Play 服务** 才能下载离线模型，国内多数手机没有 → 会失败；且质量一般。仅在你**完全不想联网 / 有 Google 服务**时才作离线兜底。

**LLM 推荐搭配（DeepSeek）**，设置里"LLM source"一键切换：
- **Cloud (online)**：填 OpenAI 兼容地址 + key + 模型（DeepSeek：`https://api.deepseek.com` + `deepseek-chat`）。
- **Local (LAN)**：连接你自己电脑上跑的本地大模型（Ollama / llama.cpp，暴露 OpenAI 兼容 `/v1` 接口），手机通过局域网调用（免 key、离线）。

---

## 🎛️ 其它功能

- **进度提示**：下载/翻译时的 toast 进度，间隔可调（`弹幕设置 → 下载进度提示间隔`，默认每 100 条）。
- **显示原文开关**：`弹幕设置 → 显示原文`。开 = 译文+原文两行；关 = 只显示译文。随时切换，始终生效。
- **缓存管理**：`弹幕设置 → 弹幕缓存 → 管理`，列出已缓存视频（条数/大小），可逐条删除 / 一键清空。
- **顶部弹幕裁剪修复**：两行文本不再被顶出可视区。

---

## 🛠️ 构建 / 打包

依赖：
- JDK（本项目用 JDK 25 编译）
- Android SDK
- Gradle（仓库自带 wrapper）

```bash
cd PipePipeClient
./gradlew :app:assembleDebug      # debug
./gradlew :app:assembleRelease    # release（需正确签名）
```

> release 签名需设置环境变量：`KEY_PATH` / `KEY_STORE_PASSWORD` / `KEY_ALIAS` / `KEY_PASSWORD`。

---

## 📦 分发

- APK 请与**源码（本仓库）一起提供**，以遵循 GPL-3.0《源代码提供》要求。
- 分享时请注明："这是 PipePipe 的**个人 fork**，新增了弹幕翻译，**仅支持回放**；非官方、不维护。"

---

## 🙏 致谢 / 版权

- [InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe) — PipePipe 作者
- [TeamNewPipe/NewPipe](https://github.com/TeamNewPipe/NewPipe) — NewPipe 原作者
- 本项目仅在其上增加"弹幕翻译"功能，**所有上游代码版权归原作者所有**。

**License**: GPL-3.0 · [LICENSE](LICENSE)

---

---

## English

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

---

## 原版描述

<hr>
<p align="center"><img src="assets/logo.png" width="150"></p> 
<h2 align="center"><b>PipePipe</b></h2>
<h4 align="center">
NewPipe, reimagined: faster, more stable, and packed with more features.</h4>
<p align="center"><a href="https://f-droid.org/packages/InfinityLoop1309.NewPipeEnhanced/"><img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid"  width="207" /></a>
<a href="https://apt.izzysoft.de/fdroid/index/apk/InfinityLoop1309.NewPipeEnhanced"><img src="assets/IzzyOnDroid.png" alt="Get it on IzzyOnDroid" width="207" /></a></p>
<hr>

## Beyond NewPipe

#### YouTube Enhancements
* Integrate SponsorBlock for skipping sponsored segments (YouTube & BiliBili) 
* Restore YouTube dislikes with ReturnYouTubeDislike 
* Show original titles on YouTube (non-localized) 
* Log in to access restricted or premium content 

#### Media Features
* Display live chats in danmaku-style overlays
* Support AV1 and VP9 codecs for efficient, high-quality playback 
* Enable music player mode with background playback 

#### Filtering
* Apply advanced search filters for better discovery 
* Filter out unwanted items by keywords or channels 
* Block shorts and paid videos for a cleaner feed 

#### Playback Controls
* Use swipe-to-seek and fullscreen gestures for intuitive navigation 
* Long-press to speed up playback 
* Set a sleep timer for bedtime listening 

#### Enhanced Playlists
* Download full playlists at once 
* Search and sort within local playlists and histories

... and many more improvements!


## Screenshots

[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/00-v2.png" width=640>](fastlane/metadata/android/en-US/images/phoneScreenshots/00-v1.png)

[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/01-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/01-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/02-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/02-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/03-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/03-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/04-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/04-v3.png)
<br/>
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/05-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/05-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/06-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/06-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/07-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/07-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/08-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/08-v3.png)
<br/>
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/09-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/09-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/10-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/10-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/11-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/11-v3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/12-v3.png" width=160>](fastlane/metadata/android/en-US/images/phoneScreenshots/12-v3.png)


## About this fork

Due to differences in development philosophy, I forked NewPipe in early 2022 and began independent development based on it.

This means that PipePipe neither receives updates from NewPipe nor pushes updates to NewPipe. They have become two separate projects. Issues that occur in NewPipe don't necessarily happen in PipePipe, and changes made in NewPipe may not be adopted by PipePipe. In contrast, forks like Tubular track the latest version of NewPipe and develop based on it.

Making a hard fork allows us to effectively address issues with quick fixes and maintain frequent feature updates.

## About sign in

PipePipe will ONLY use the login cookie for the specified scenarios you set. You can configure it in "Cookie Functions."

For YouTube, the cookie will only be used when retrieving playback streams.

## Contribute

Issues and PRs are welcomed. Please note that I will **NOT** accept service requests. 

Anyone interested in creating their own service is encouraged to fork this repository.

## Donation

If you find PipePipe useful, please consider becoming a supporter on Ko-Fi. Your support is important to me and helps me add more exciting new features. Every bit counts! 😇

Liberapay: https://liberapay.com/PipePipe

Ko-fi: https://ko-fi.com/pipepipe

## Community

[PipePipe Wiki](https://priveetee.github.io/Docs-PipePipe) maintained by [@Priveetee](https://github.com/Priveetee)

## Special Thanks

[Priveetee](https://github.com/Priveetee) for [researching SABR](https://priveetee.github.io/Docs-PipePipe/developer-guide/introduction.html) and implementing support for it.

[AioiLight](https://github.com/AioiLight) for providing some code of NicoNico service.