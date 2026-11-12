# ALVR 简体中文版（ALVR-CN）

![version](https://img.shields.io/badge/ALVR-v20.14.1-blue)
![platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey)
![lang](https://img.shields.io/badge/UI-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-red)
![license](https://img.shields.io/badge/license-MIT-green)

基于官方 [ALVR](https://github.com/alvr-org/ALVR) **v20.14.1** 源码重新编译的简体中文版，包含串流端面板（ALVR Dashboard）与启动器（ALVR Launcher）。

原版界面全英文，本版把界面文本、全部设置项名称与说明、提示语、统计图表标签、启动器对话框都译成了简体中文，并内置中文字体回退，不会出现方块字。

**只改界面，不动协议。** 串流管线、驱动、编解码与官方 v20.14.1 完全一致，可以和官方客户端 APK、官方 SteamVR 驱动混用。

---

## 下载

到 [Releases](../../releases/latest) 下载 `ALVR-CN-v20.14.1.zip`，解压到**纯英文路径**即可使用：

```
ALVR-CN/
├─ streamer/    ← 串流端，运行 ALVR Dashboard.exe
├─ launcher/    ← 启动器（可选），运行 ALVR Launcher.exe
└─ 使用说明.txt
```

> ⚠️ **路径里不能有中文、日文、俄文等非 ASCII 字符。**
> 例：`C:\ALVR-CN\` ✅ ｜ `D:\我的软件\ALVR\` ❌ ｜ `C:\Users\张三\Desktop\ALVR\` ❌

这不是汉化引入的问题。`driver_alvr_server.dll` 是 C++ 写的，把 `session.json` 路径当**窄字符串**交给 `std::ifstream`，MSVC 会用当前 ANSI 代码页（中文系统 GBK/936）解释，路径含非 ASCII 字符就打不开，于是 SteamVR 直接弹「SteamVR 出现重大错误」。面板启动时会检测并在顶部显示黄色警告条。

---

## 汉化范围

| 模块 | 内容 |
| --- | --- |
| 主界面 | 标签页、按钮、状态文字（已连接 / 串流中 / 未连接…） |
| 设置页 | 6 大类（预设 / 视频 / 音频 / 头显 / 连接 / 额外）+ 全部子项标题、开关、下拉选项、滑块单位、问号悬浮说明、黄色注意事项、⚠ 重启提示、🔵 实时生效提示 |
| 设备页 | 有线连接、新的无线设备、已信任的无线设备、编辑连接弹窗 |
| 统计页 | 延迟分段、帧率、码率与吞吐、各项汇总数值 |
| 安装页 | 设置向导、防火墙规则、驱动注册 |
| 日志 / 调试 / 关于 | 全部界面文案 |
| 启动器 | 全部按钮、对话框、进度与错误提示 |
| 底部小贴士 | 27 条随机通知全部翻译 |

**有意保留英文**：日志正文、许可证文本、编码器与协议专有名词（H264、HEVC、AV1、NVENC、AMF、CBR、VBR、CAVLC、CABAC、UDP、TCP、DSCP、IDR、GOP）。

词条共 436 条，中英对照表见 [`源码补丁/翻译对照表-设置项.txt`](源码补丁/翻译对照表-设置项.txt) 与 [`源码补丁/翻译对照表-补充.txt`](源码补丁/翻译对照表-补充.txt)。

---

## 从源码构建

环境：Windows 10/11 + [Rust](https://rustup.rs/)（stable，MSVC toolchain）+ Visual Studio Build Tools（C++ 工作负载）。

### 一键脚本

```powershell
# 在任意空目录执行，脚本会：克隆 ALVR v20.14.1 → 打汉化补丁 → 编译
.\scripts\build.ps1
```

### 手动步骤

```bash
git clone --branch v20.14.1 --recursive https://github.com/alvr-org/ALVR
cd ALVR
git apply -p2 /path/to/alvr-zh-cn.patch     # 注意 -p2，补丁路径前缀是 orig/ 与 src/
cargo build --release -p alvr_dashboard -p alvr_launcher
```

产物：

```
target/release/alvr_dashboard.exe   → 改名为 ALVR Dashboard.exe
target/release/alvr_launcher.exe    → 改名为 ALVR Launcher.exe
```

`--recursive` 不能省。官方仓库带 submodule（openvr 头文件），缺了会在 `alvr_session/build.rs` 报 `Missing openvr header files`。

---

## 技术实现

改动共 **37 个文件**，集中在界面层，核心串流代码零改动：

| 文件 | 作用 |
| --- | --- |
| `alvr/gui_common/src/fonts.rs` | 中文字体回退加载 |
| `alvr/gui_common/src/i18n.rs` | 翻译查表（精确匹配，未命中回退原文） |
| `alvr/gui_common/src/i18n/i18n_data.rs` | 生成的 436 条中英对照表 |
| `alvr/dashboard/src/dashboard/**` | 界面文案内联为中文 |
| `alvr/dashboard/src/dashboard/mod.rs` | 新增「安装路径含非 ASCII 字符」启动警告 |
| `alvr/launcher/src/*.rs` | 启动器文案内联为中文 |

### 字体回退顺序

启动时自动查找可用中文字体，找不到才用 egui 默认字体（会出现方块字）：

```
exe 同目录 cjk.ttf / cjk.otf / cjk.ttc
→ C:\Windows\Fonts\msyh.ttc     微软雅黑
→ C:\Windows\Fonts\simhei.ttf   黑体
→ C:\Windows\Fonts\Deng.ttf     等线
→ C:\Windows\Fonts\simsun.ttc   宋体
```

想换字体：把任意中文字体改名为 `cjk.ttf` 放到 `ALVR Dashboard.exe` 同目录。

---

## 仓库结构

```
ALVR-CN/
├─ 源码补丁/
│  ├─ alvr-zh-cn.patch              # 相对官方 v20.14.1 的完整改动（37 文件）
│  ├─ 补丁说明.txt
│  ├─ 翻译对照表-设置项.txt
│  └─ 翻译对照表-补充.txt
├─ scripts/
│  └─ build.ps1                     # 克隆 + 打补丁 + 编译
├─ LICENSES/                        # ALVR / Valve / FFmpeg 许可证原文
├─ 使用说明.txt                      # 面向普通用户的上手指南与崩溃排查
├─ LICENSE
└─ README.md
```

---

## 常见问题

**戴头显就弹「SteamVR 出现重大错误」**
1. 安装路径含非 ASCII 字符（最常见，见上文）。
2. `session.json` 缺失。驱动启动时必须能读到它。误删了：打开面板 → 改任一设置 → 关面板，会自动重建。
3. 同时注册了两份 ALVR 驱动，两个 `driver_alvr_server.dll` 抢同一个 HMD。查看与清理：
   ```
   "C:\Program Files (x86)\Steam\steamapps\common\SteamVR\bin\win64\vrpathreg.exe" show
   vrpathreg.exe removedriver "多余目录"
   vrpathreg.exe adddriver  "C:\ALVR-CN\streamer"
   ```

**改了设置但头显画面没变**
面板和驱动不在同一目录：面板写 A 目录的 `session.json`，驱动读 B 目录的。重启 SteamVR，或在「安装」页确认驱动列表指向当前目录。

**正确启动顺序**
打开 ALVR Dashboard → 左下角显示「SteamVR: 未连接」→ 点面板里的「启动 SteamVR」→ 戴头显，在「设备」页点「信任」。不要自己先开 SteamVR，面板启动前会把当前设置写进 `session.json`。

更多排查见 [`使用说明.txt`](使用说明.txt)。

---

## 许可

汉化补丁与文档以 **MIT** 发布，见 [LICENSE](LICENSE)。

ALVR 本体为 MIT（Copyright © 2018-2019 polygraphene，© 2020-2024 alvr-org），Valve OpenVR 头文件为 BSD-3-Clause，FFmpeg 为 LGPL。原文见 [LICENSES/](LICENSES/)。

## 致谢

- [alvr-org/ALVR](https://github.com/alvr-org/ALVR) —— 本项目的一切基础
- [egui](https://github.com/emilk/egui) / [eframe](https://github.com/emilk/egui/tree/master/crates/eframe) —— 界面框架
- 所有给 ALVR 提交过代码与翻译的人

> 本项目与 alvr-org 无隶属关系，官方不支持、也不对本版本负责。升级官方新版会覆盖 exe，中文随之丢失；想回滚英文版，把官方原版 `ALVR Dashboard.exe` 覆盖回来即可。
