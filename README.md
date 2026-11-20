# Voided Items — J510 black screen patch (unofficial)

An unofficial client-side patch for **Voided Items** (Steam Workshop `3312038195`, mod v1.7)
that fixes the black screen introduced by game update **1.9.7.19 (J510)**.

This repository contains **only the changed files**, not the original mod.

---

## 中文

### 问题

游戏更新到 `1.9.7.19`（J510）后，订阅 Voided Items 的玩家进入游戏会看到：
画面全黑、音乐正常、鼠标光标正常、ESC 无反应，日志里没有任何 Lua 报错。

### 根因

没有 REPENTOGON 时，模组走 `rendering.lua` 路径：

- `content/shaders.xml` 注册了一个与游戏内置同名的 `PauseScreenCompletionMarks` 着色器；
- HUD 图标通过 `MC_GET_SHADER_PARAMS` 回调借这个着色器绘制。

J510 改动原生着色器管线后，这个同名注册会让整个场景渲染输出全黑。

### 补丁改动

1. `content/shaders.xml` 改名为 `content/shaders.xml.disabled`，不再覆盖游戏内置着色器；
2. `rendering.lua`：把 `VoidedItems:RenderItems()` 从 `MC_GET_SHADER_PARAMS` 移到
   `MC_POST_RENDER`，在 HUD 可见时绘制。其余追踪、暂停淡出逻辑未改。

完整差异见 [`docs/patch.diff`](docs/patch.diff)。

### 安装

先确保已通过 Steam 订阅并下载 **Voided Items**。

**方式 A：脚本（推荐）**

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

脚本会自动查找 Steam 库里的模组目录；找不到时手动指定：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -ModPath "D:\Steam\steamapps\common\The Binding of Isaac Rebirth\mods\voided items_3312038195"
```

**方式 B：手动**

1. 打开模组目录 `...\mods\voided items_3312038195`；
2. 用本仓库 `patch/rendering.lua` 覆盖同名文件（建议先备份原文件）；
3. 把 `content\shaders.xml` 改名为 `content\shaders.xml.disabled`。

安装后重启游戏。

### 验证

用阿波罗（Apollyon）拿虚空（Void），吸收一个**主动道具**（需要按空格使用的道具）。
HUD 应正常显示吸收的图标；再吸收一个主动道具，图标应追加显示。
被动道具不会被虚空吸收，也不会显示，这是原模组的设计。

### 卸载

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

或手动：恢复备份的 `rendering.lua`，把 `shaders.xml.disabled` 改回 `shaders.xml`。

### 注意

- Steam 更新 Voided Items 会覆盖本地修改，需要重新打补丁；
- 原作者发布适配 J510 的官方版本后，请优先使用官方版并删除本补丁；
- 本补丁只改了渲染路径，不改变道具记录、存档格式或游戏平衡。

---

## English

### Problem

After game update **1.9.7.19 (J510)**, entering a run with Voided Items shows a fully black
screen: music and the system cursor keep working, ESC does nothing, and the log reports no Lua error.

### Root cause

Without REPENTOGON the mod uses `rendering.lua`:

- `content/shaders.xml` registers a shader named `PauseScreenCompletionMarks`, the same name as a
  vanilla shader;
- the HUD icons are drawn from `MC_GET_SHADER_PARAMS`, borrowing that shader.

On J510 that override makes the entire scene render black.

### What the patch changes

1. `content/shaders.xml` is renamed to `content/shaders.xml.disabled` so the vanilla shader is no
   longer overridden;
2. `rendering.lua`: `VoidedItems:RenderItems()` is moved from `MC_GET_SHADER_PARAMS` to
   `MC_POST_RENDER`, drawing while the HUD is visible. Tracking and pause-fade logic are untouched.

See [`docs/patch.diff`](docs/patch.diff) for the full diff.

### Install

Subscribe to and download **Voided Items** first.

**Option A: script (recommended)**

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The script locates the mod in your Steam library automatically. If it cannot, pass the path:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -ModPath "D:\Steam\steamapps\common\The Binding of Isaac Rebirth\mods\voided items_3312038195"
```

**Option B: manual**

1. Open `...\mods\voided items_3312038195`;
2. replace `rendering.lua` with `patch/rendering.lua` (back up the original first);
3. rename `content\shaders.xml` to `content\shaders.xml.disabled`.

Restart the game afterwards.

### Verify

Play Apollyon, take Void and absorb an **active item** (one used with the space bar).
The HUD should show the absorbed icon; absorb another active item and the icons should stack.
Passive items are not absorbed by Void and are not shown — that is the original mod's behavior.

### Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Or manually: restore the backed-up `rendering.lua` and rename `shaders.xml.disabled` back.

### Notes

- Steam updates to Voided Items overwrite local changes; re-apply the patch afterwards;
- prefer an official J510-compatible release from the original author once it exists, and remove
  this patch;
- this patch only changes the rendering path; it does not alter item tracking, save data or balance.

---

## Credits and licensing

- Original mod: **Voided Items** by **RealexTea**, Steam Workshop
  <https://steamcommunity.com/sharedfiles/filedetails/?id=3312038195>
- This is an **unofficial, non-commercial** compatibility patch. It contains only the modified
  files and is not affiliated with the original author.
- Do not redistribute the full mod from this repository. If the original author objects to this
  patch, it will be removed.
