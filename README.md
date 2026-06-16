# Game2048Plus 🎮

> 一款基于 **HarmonyOS (鸿蒙)** 开发的跨平台 2048 益智游戏，支持手机、平板、折叠屏、电脑、手表等多设备自适应。

---

## 目录

- [项目概述](#项目概述)
- [功能特性](#功能特性)
- [项目结构](#项目结构)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
- [游戏玩法](#游戏玩法)
- [架构设计](#架构设计)
- [多设备适配](#多设备适配)
- [数据持久化](#数据持久化)
- [构建与部署](#构建与部署)
- [许可协议](#许可协议)
- [贡献指南](#贡献指南)

---

## 项目概述

**Game2048Plus** 是经典 2048 数字益智游戏的鸿蒙原生实现。项目采用 **ArkTS** 语言和 **ArkUI** 框架，遵循 **Stage 模型** 开发，充分利用鸿蒙系统的多设备协同能力，在一套代码基础上自适应手机、平板、折叠屏、PC、手表等不同形态设备。

游戏不仅保留了原版 2048 的核心玩法，还内置了**交互式教学模式**，帮助新玩家快速上手。最高合成数字持久化存储，确保游戏进度不丢失。

### 基本信息

| 项目 | 说明 |
|------|------|
| 包名 | `com.example.game2048plus` |
| 版本 | 1.0.0 (versionCode: 1000000) |
| 开发框架 | ArkTS + ArkUI (Stage 模型) |
| 目标设备 | Phone, Tablet, 2in1, Car, Wearable, TV |
| 最低 API | API 10+ |

---

## 功能特性

### 🎯 核心玩法
- **经典 4×4 棋盘**：上下左右滑动合并相同数字，挑战 2048
- **触控滑动**：支持手指滑动手势操作（PanGesture）
- **键盘支持**：方向键 / WASD 操作（PC 设备）
- **实时计分**：每次合并获得对应分值，步数统计
- **最高合成追踪**：记录玩家曾合成过的最大数字方块
- **胜利/结束弹窗**：达成 2048 或无路可走时触发提示

### 🎨 双模式选择
- **🎮 普通模式**：直接开始游戏
- **📖 教学模式**：单页滚动教程覆盖层，涵盖规则、操作、策略等全套内容，上下滑动即可浏览

### 📱 多设备自适应
- **5 档断点响应**：XS / SM / MD / LG / XL
- **6 种设备分类**：Watch / Phone / Tablet / PC / Foldable Dual / Foldable Tri
- **折叠屏适配**：实时监听折叠状态变化，自动调整布局
- **自适应 UI**：棋盘大小、方块尺寸、字体大小均随断点动态调整

### 💾 数据持久化
- 最高合成数字通过 `@kit.ArkData` (preferences) 本地持久化存储
- 备份恢复能力已配置（backup extension）

### 🌓 深色模式支持
- 启动窗口背景色支持亮/暗双主题

---

## 项目结构

```
game2048plus/
├── AppScope/                          # 应用级配置
│   ├── app.json5                      # 应用信息 (bundleName、版本等)
│   └── resources/
│       └── base/
│           ├── element/
│           │   └── string.json        # 应用名称
│           └── media/                 # 应用图标 (background/foreground/layered)
│
├── game2048_plus/                     # 主模块 (entry)
│   ├── build-profile.json5            # 构建配置 (Stage模式)
│   ├── oh-package.json5               # 包依赖配置
│   ├── hvigorfile.ts                  # Hvigor 构建脚本
│   ├── obfuscation-rules.txt          # 混淆规则
│   ├── src/
│   │   ├── main/
│   │   │   ├── module.json5           # 模块配置 (Ability、权限、设备类型)
│   │   │   ├── ets/
│   │   │   │   ├── pages/
│   │   │   │   │   └── Index.ets      # 🏠 主页面 (游戏UI、模式选择、弹窗)
│   │   │   │   ├── model/
│   │   │   │   │   └── Game2048Model.ets  # 🧠 核心游戏逻辑模型
│   │   │   │   ├── components/
│   │   │   │   │   ├── TileCellComponent.ets  # 🧩 方块组件
│   │   │   │   │   └── TeachingOverlay.ets    # 📖 教学模式覆盖层
│   │   │   │   ├── constants/
│   │   │   │   │   └── GameConstants.ets      # 📐 常量 (颜色、棋盘尺寸)
│   │   │   │   ├── utils/
│   │   │   │   │   └── BreakPointSystem.ets   # 📏 断点响应系统
│   │   │   │   ├── game2048_plusability/
│   │   │   │   │   └── Game2048_plusAbility.ets  # 🚀 Ability 生命周期
│   │   │   │   └── game2048_plusbackupability/
│   │   │   │       └── Game2048_plusBackupAbility.ets  # 💾 备份扩展
│   │   │   └── resources/
│   │   │       ├── base/
│   │   │       │   ├── element/
│   │   │       │   │   ├── color.json    # 颜色资源 (亮色)
│   │   │       │   │   ├── string.json   # 字符串资源
│   │   │       │   │   └── float.json    # 浮点数值
│   │   │       │   ├── media/            # 图片资源
│   │   │       │   └── profile/
│   │   │       │       ├── main_pages.json    # 页面路由配置
│   │   │       │       └── backup_config.json # 备份配置
│   │   │       └── dark/
│   │   │           └── element/
│   │   │               └── color.json    # 深色主题颜色
│   │   ├── mock/
│   │   │   └── mock-config.json5         # Mock 配置
│   │   ├── test/
│   │   │   ├── List.test.ets             # 列表测试
│   │   │   └── LocalUnit.test.ets        # 单元测试
│   │   └── ohosTest/
│   │       └── module.json5              # 测试模块配置
│   └── build/
│       └── config/
│           └── buildConfig.json
│
├── hvigor/
│   └── hvigor-config.json5               # Hvigor 全局构建配置
├── oh_modules/                           # 依赖模块
└── .hvigor/                              # 构建缓存
```

---

## 技术栈

| 技术 | 说明 |
|------|------|
| **ArkTS** | 鸿蒙原生 TypeScript 方言，静态类型 + 装饰器 |
| **ArkUI** | 声明式 UI 框架 (@Component, @State, @Prop, @Builder) |
| **Stage 模型** | 鸿蒙 Ability 生命周期管理 |
| **@kit.ArkUI** | PanGesture、KeyEvent、mediaquery、display API |
| **@kit.ArkData** | preferences 数据持久化 |
| **@kit.AbilityKit** | UIAbility、Want、ConfigurationConstant |
| **@kit.PerformanceAnalysisKit** | hilog 日志记录 |
| **Hvigor** | 鸿蒙构建工具 |

---

## 快速开始

### 环境要求

- DevEco Studio 5.0+
- HarmonyOS SDK API 10+
- Node.js 18+

### 运行步骤

1. **克隆项目**
   ```bash
   git clone <repo-url>
   cd game2048plus
   ```

2. **打开项目**
   - 使用 DevEco Studio 打开项目根目录

3. **配置签名**
   - 在 `build-profile.json5` 中配置签名信息
   - 或在 DevEco Studio 中自动签名

4. **运行调试**
   - 连接设备或启动模拟器
   - 点击 DevEco Studio 的 `Run` 按钮

5. **构建 HAP**
   ```bash
   # 通过 DevEco Studio 构建
   Build > Build HAP(s)
   ```

---

## 游戏玩法

### 基本规则

1. 游戏在 **4×4** 网格上进行
2. 每次操作，所有方块同时向滑动方向移动
3. 相同数字的方块相撞时**合并**为它们的和
4. 每次移动后，在随机空位生成一个新方块（90% 概率为 2，10% 概率为 4）
5. 目标：拼出 **2048** 方块！
6. 棋盘填满且无相邻相同数字时，游戏结束

### 操作方式

| 设备 | 操作 |
|------|------|
| 📱 手机/平板 | 滑动屏幕（上/下/左/右） |
| 💻 PC | 方向键 ↑↓←→ 或 WASD |
| ⌚ 手表 | 滑动屏幕 |

### 计分规则

- 每合并一次获得合并后数字对应的分数
- 例如：合并两个 `8` → 获得 `16` 分
- 合并两个 `1024` → 获得 `2048` 分

### 教学模式

所有内容在单页中垂直排列，上下滑动即可浏览全部 7 个小节：

| 节 | 主题 | 内容 |
|------|------|------|
| 1 | 🎮 欢迎 | 游戏简介与目标 |
| 2 | 🖱️ 基本操作 | 滑动、合并、键盘操作 |
| 3 | 🧮 计分规则 | 分数计算与步数 |
| 4 | 🏆 核心策略 | 角落大法 — 新手必学 |
| 5 | 🔗 进阶技巧 | 链式构建与布局 |
| 6 | 🚫 常见错误 | 新手最容易犯的 4 个错误 |
| 7 | 🎯 高手心法 | 成为达人的秘诀 |

点击半透明背景区域或「✕ 关闭」按钮即可退出教程。

---

## 架构设计

### 状态管理

```
┌──────────────────────────────────────────────────┐
│                  Index (主页面)                     │
│  @State flatBoard: number[]   ← 扁平化UI数据源     │
│  @State score / maxTileValue / moveCount          │
│  @State showModeSelect / showTeaching             │
│  @State showWinDialog / showGameOverDialog        │
│  @State currentBreakpoint / deviceCategory        │
│  @State cachedTileSize / cachedGap / … (缓存尺寸) │
└──────────────┬───────────────────────────────────┘
               │ 监听状态变化 (addListener)
               ▼
┌──────────────────────────────────────────────────┐
│              Game2048Model (游戏逻辑)              │
│  board: (Tile|null)[][]  ← 核心二维数组            │
│  移动 / 合并 / 计分 / 胜负判定                     │
│  notifyListeners() → UI 更新                      │
└──────────────────────────────────────────────────┘
```

### 关键设计决策

**扁平化数组解决响应式限制**

ArkTS 对嵌套对象（如 `board[row][col]`）的响应式追踪存在限制。本项目采用**扁平化一维数组** `@State flatBoard: number[]` 作为 UI 数据源，在监听回调中同步转换：

```typescript
private syncFromGameState(state: GameState): void {
  const newBoard: number[] = [];
  for (let r = 0; r < BOARD_SIZE; r++) {
    for (let c = 0; c < BOARD_SIZE; c++) {
      const tile = state.board[r][c];
      newBoard.push(tile ? tile.value : 0);
    }
  }
  this.flatBoard = newBoard;  // 触发 UI 刷新
  this.score = state.score;
  this.maxTileValue = state.maxTileValue;
  this.moveCount = state.moveCount;
}
```

### 组件树

```
Index (页面入口)
├── ModeSelectScreen (模式选择界面)
│   ├── Logo 区域
│   ├── 普通模式按钮
│   └── 教学模式按钮
│
├── 游戏主界面
│   ├── Header (标题 + 设备标签 + 教程入口)
│   ├── ScoreBox (分数展示) × 2
│   ├── Game Board (4×4 棋盘)
│   │   └── TileCellComponent × 16 (方块)
│   └── 操作提示
│
├── WinOverlay (胜利弹窗)
├── GameOverOverlay (游戏结束弹窗)
└── TeachingOverlay (教学模式覆盖层)
    ├── 固定标题栏 + 关闭按钮
    ├── Scroll 滚动区域 (全部 7 小节垂直排列)
    │   ├── 序号标题 + 副标题
    │   ├── 分隔线 + 要点列表
    │   └── 金色提示框
    └── 底部结语
```

---

## 多设备适配

### 断点系统 (BreakPointSystem)

采用 **单例模式** 管理设备类型和断点检测：

| 断点 | 宽度范围 | 典型设备 |
|------|----------|----------|
| XS | [0, 320vp) | 手表 |
| SM | [320, 600vp) | 手机、折叠屏外屏 |
| MD | [600, 840vp) | 折叠屏展开、平板竖屏 |
| LG | [840, 1440vp) | 平板横屏、PC、三折叠展开 |
| XL | [1440vp, +∞) | 大屏 PC、显示器 |

### 折叠屏支持

- 通过 `display.isFoldable()` 检测是否为折叠设备
- 监听 `foldStatusChange` 实时更新布局
- 双折叠屏（Mate X5/X6）和三折叠屏（Mate XT）分别识别

### 响应式 UI 调整

- **棋盘尺寸**：从 XS (120vp，适配圆形手表) 到 XL (560vp) 自适应
- **方块大小**：根据棋盘尺寸和间距动态计算
- **字体大小**：根据设备断点动态缩放
- **间距**：XS (4vp) / SM (8vp) / 其他 (10vp)
- **显隐控制**：XS 断点隐藏操作提示文字；所有尺寸值缓存为 `@State`，仅在断点切换时重新计算

---

## 数据持久化

### 最高合成数字存储

使用 `@kit.ArkData` 的 `preferences` API 实现：

```typescript
const PREFERENCE_NAME = 'game2048_storage';
const MAX_TILE_KEY = 'max_tile';

// 加载
const dataPreferences = await preferences.getPreferences(getContext(), PREFERENCE_NAME);
const saved = await dataPreferences.get(MAX_TILE_KEY, 0);
this.gameModel.setMaxTileValue(saved);

// 保存（每次新游戏 / 应用退出时）
await dataPreferences.put(MAX_TILE_KEY, this.maxTileValue);
await dataPreferences.flush();
```

### 追踪机制

最高合成数字在以下三个时刻更新：
1. **随机生成方块时** — 新方块的数值若高于当前记录则更新
2. **方块合并时** — 合并结果若高于当前记录则更新
3. **构建游戏状态时** — 直接扫描棋盘 16 个格子取最大值，作为兜底保障

### 备份恢复

通过 `Game2048_plusBackupAbility` 扩展能力支持系统级备份恢复，配置如下：
- `backup_config.json`: 允许备份恢复
- `extensionAbilities`: 注册 backup 类型扩展

---

## 构建与部署

### 构建配置

- **API 类型**: Stage Mode
- **编译 SDK**: API 10
- **目标产物**: HAP (HarmonyOS Ability Package)
- **混淆**: Release 模式可开启 (当前关闭)

### 构建命令

在 DevEco Studio 中：
1. `Build > Build HAP(s)` — 构建调试包
2. `Build > Build App Bundle(s)` — 构建发布包

---

## 许可协议

本项目为开源项目，具体许可协议请参见项目根目录的 LICENSE 文件（如有）。

---

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

<div align="center">
  <strong>Game2048Plus</strong> — 用 HarmonyOS 重新定义经典 🎯
</div>
