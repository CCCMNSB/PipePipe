# ============================================================================
# PipeDanmakuTranslate — 跟上上游 PipePipe 的合并辅助脚本
#
# 作用：从原作者（InfinityLoop1308）拉取最新改动，并尝试合并到本仓库分支。
#       冲突会列出来（需手动重新应用弹幕翻译的挂钩点），之后重新编译/发布。
#
# 注意：合并要在这个【子模块工作区】做（有上游 git 历史），
#       再同步到扁平仓库 DanmakuTranslate 发布。
#
# 用法：看 "第 2 步" 里的说明。可把脚本放在工作区根目录（D:\Harness\PipePipe）。
# ============================================================================

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Client = Join-Path $Root "PipePipeClient"
$Extractor = Join-Path $Root "PipePipeExtractor"

Write-Host "===== 拉取上游 + 合并 PipePipeClient (upstream/dev) =====" -ForegroundColor Cyan
git -C $Client fetch upstream 2>&1
$c1 = git -C $Client merge upstream/dev 2>&1
$c1 | ForEach-Object { $_ }
if (($c1 -join "`n") -match 'CONFLICT') {
    Write-Host "!! PipePipeClient 有冲突，需要手动处理（见下）" -ForegroundColor Yellow
} else {
    Write-Host "✅ PipePipeClient 合并完成（无冲突）" -ForegroundColor Green
}

Write-Host "===== 拉取上游 + 合并 PipePipeExtractor (upstream/main) =====" -ForegroundColor Cyan
git -C $Extractor fetch upstream 2>&1
$c2 = git -C $Extractor merge upstream/main 2>&1
$c2 | ForEach-Object { $_ }
if (($c2 -join "`n") -match 'CONFLICT') {
    Write-Host "!! PipePipeExtractor 有冲突，需要手动处理（见下）" -ForegroundColor Yellow
} else {
    Write-Host "✅ PipePipeExtractor 合并完成（无冲突）" -ForegroundColor Green
}

Write-Host ""
Write-Host "接下来的步骤（合并后）：" -ForegroundColor Cyan
Write-Host "  1. 若有冲突：在冲突文件里【重新应用弹幕翻译挂钩】"
Write-Host "     - Player.java / MovieBulletCommentsPlayer.java / BulletCommentsView.java"
Write-Host "     - BulletCommentsSettingsFragment.java / player.xml / AndroidManifest.xml / strings.xml / settings XML"
Write-Host "  2. 重新编译 + 测试：cd PipePipeClient && .\gradlew.bat :app:assembleDebug"
Write-Host "  3. 同步到扁平仓库并推送："
Write-Host "     robocopy 变更文件到 D:\Harness\PipePipe\DanmakuTranslate -> git add/commit/push"
Write-Host "  4. 重新打包 release + 发新 Release"
Write-Host ""
Write-Host "提示：解决冲突时如需帮助，可把冲突内容发给我，我帮你重新应用。" -ForegroundColor Yellow
