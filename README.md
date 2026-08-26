# Otter Keyboard Tool (水獭键盘工具) — 复刻版

这是从 App Store 包（IPA `Otter Keyboard Tool` v1.2, bundle `com.cz.czk`）逆向分析后，
用 **Swift / SwiftUI** 重新编写的可编译 iOS 工程，包含：

- **容器 App**：剪贴板、常用语、脚本的管理界面，以及设置、添加键盘引导、关于 / 版本日志 / 常见问题。
- **自定义键盘扩展（Keyboard Extension）**：在系统键盘上扩展四个面板 —— 剪贴板 / 常用语 / 脚本 / 设置，
  并支持「爆炸分词」、键盘高度调节、空格/回车键、系统权限跳转。
- **JS 脚本引擎**：通过 `WKWebView.callAsyncJavaScript` 运行用户脚本，要求导出 `async function main()`，
  返回字符串或字符串数组作为候选词；内置 `async otterRequest(url, method, params, headers)` 网络请求函数。
- **共享数据**：通过 **App Group `group.czk`** 共享 `UserDefaults`（设置）与 **CoreData**（剪贴板 / 常用语 / 脚本）。

> 说明：本工程为功能等价复刻，UI 文案与原始一致（含英文 / 简体中文本地化）。个别交互细节为合理还原，
> 并非逐字节一致。

## 工程结构

```
OtterKeyboardTool.xcodeproj       Xcode 工程（由 gen_pbx.py 生成）
OtterKeyboardTool/                容器 App（SwiftUI）
  App/Screens/...                 各界面
  Assets.xcassets                 资源目录（图标请自行补充）
  *.lproj/Localizable.strings     本地化（由 gen_strings.py 生成）
  Info.plist / .entitlements
KeyboardExtension/                键盘扩展（UIInputViewController + SwiftUI）
  KeyboardViewController.swift     输入引擎桥接
  KeyboardRootView.swift           键盘主界面
  Panels.swift                     四个面板
  ExplosionView.swift              “爆炸分词”
  ScriptRunner.swift（位于 Shared） JS 引擎
Shared/                            App 与扩展共享代码
  Persistence.swift               App Group 存储 + CoreData + 设置键
  Models.swift                    CoreData 托管对象
  ScriptRunner.swift              JS 脚本引擎
  Localized.swift                 本地化辅助
  OtterKeyboardTool.xcdatamodeld  CoreData 模型
gen_pbx.py / gen_strings.py       工程与字符串生成脚本（可选，便于修改后重生成）
```

## 环境要求

- Xcode 15+（建议 15.2+）
- 目标系统 iOS 16.0+
- 一台 **真机**（自定义键盘扩展在模拟器上功能受限，建议真机验证）

## 构建与运行

1. 用 Xcode 打开 `OtterKeyboardTool.xcodeproj`。
2. 在 **Signing & Capabilities** 中为两个 target（`OtterKeyboardTool` 与 `KeyboardExtension`）
   选择你的 Development Team。
3. **必须修改 App Group**（默认 `group.czk` 属于原作者，你无法签名）：
   - 修改 `Shared/Persistence.swift` 中的 `AppConfig.appGroupID`
   - 修改两个 `.entitlements` 文件里的 `com.apple.security.application-groups`
   - 例如改为 `group.com.yourteam.OtterKeyboardTool`（需与你的开发者账号匹配）
4. 选择真机设备，构建并运行 `OtterKeyboardTool`（容器 App）。
5. 在 iOS **设置 → 键盘 → 键盘 → 添加新键盘** 中启用「Otter Keyboard Tool」，
   并开启 **允许完全访问**（剪贴板读取、脚本网络请求需要）。
6. 在任意输入框切换到该键盘即可使用四个面板。

## 已实现功能

- 键盘四面板：剪贴板历史 / 常用语（分组）/ 脚本 / 设置
- 剪贴板：自动保存系统剪贴板（需完全访问）、一键清空、存为常用语
- 常用语：分组与条目管理，点击即输入
- 脚本：新增 / 编辑 / 删除，参数开关，网络请求开关，运行测试；
  调用 `main()` 取候选词，支持从剪贴板或输入框选中文字作为脚本参数
- 爆炸分词：长按剪贴板 / 常用语条目进入分词选择，可删除条目
- 设置：自动保存、声音 / 震动、侧栏 Emoji、键盘高度（横竖屏）、菜单顺序、系统权限跳转
- 设置内：关于、版本更新日志、常见问题（QA）
- 本地化：英文 + 简体中文

## 已知限制 / 备注

- 图标资源请自行补充到 `Assets.xcassets/AppIcon.appiconset`。
- 原始 IPA 的中文 `Localizable.strings` 在打包时被错误编码为 GBK，原 App 实际显示乱码；
  本复刻使用正确编码的简体中文。
- 跨进程并发访问同一 CoreData SQLite 采用 `DELETE` journal 模式以降低风险，
  仍建议在真机充分测试数据一致性。

## 来源

基于从 App Store 下载的 IPA（`com.cz.czk`, v1.2 build 3）解包分析：
`Info.plist`、扩展 `Info.plist`、本地化字符串、CoreData 实体、二进制中可见的
类/符号（`Clipboard` / `Phrase` / `PhraseSet` / `Script`、`group.czk`、
`WKWebView.callAsyncJavaScript`、`otterRequest` 等）。
