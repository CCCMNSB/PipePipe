<hr>
<p align="center"><img src="assets/logo.png" width="150"></p> 
<h2 align="center"><b>PipePipe</b></h2>
<h4 align="center">
NewPipe, reimagined: faster, more stable, and packed with more features.</h4>
<p align="center"><a href="https://f-droid.org/packages/InfinityLoop1309.NewPipeEnhanced/"><img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid"  width="207" /></a>
<a href="https://apt.izzysoft.de/fdroid/index/apk/InfinityLoop1309.NewPipeEnhanced"><img src="assets/IzzyOnDroid.png" alt="Get it on IzzyOnDroid" width="207" /></a></p>
<hr>

## ⭐ 本 fork 新增：弹幕（danmaku）自动翻译

> 这是一个 **带弹幕自动翻译功能的 PipePipe fork**（非官方个人 fork）。
> 源码：`github.com/CCCMNSB/PipePipe`（含 PipePipeClient / PipePipeExtractor 子模块）。

- **功能**：下载视频**完整弹幕列表** → 去重翻译（**LLM（推荐）** / ML Kit）→ **缓存** → **按时间轴自动加载**；再次进入自动加载缓存。
- ⚠️ **仅支持「直播回放」**，**不支持正在直播**（全量下载依赖已完成的回放）。
- **翻译引擎**：**推荐 LLM**（DeepSeek 云端或本地 Ollama/llama.cpp；`settings → 弹幕设置 → 翻译引擎 = LLM`，填 base/key/model）。国内手机无 Google 服务也能用。ML Kit（离线）需 Google 服务，不推荐。
- **非官方 / 不维护 / vibe coding（AI 生成）**：仅供个人 fork 自用，可能有 bug。
- **遵循 GPL-3.0**：保留原作者署名（[InfinityLoop1308/PipePipe](https://github.com/InfinityLoop1308/PipePipe) → [NewPipe](https://github.com/TeamNewPipe/NewPipe)），分发时随 APK 提供源码。
- **更新**：App 内"检查更新"指向本仓库 Releases。发布新版时建 Release（名 `v5.x.x` + ABI 文件名 + 同一串签名 APK），用户即可一键更新。

> 以下内容为**上游 PipePipe 的原版说明**（未改动，仅在其上新增了上述弹幕翻译功能）。

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
