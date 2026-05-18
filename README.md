# 弹性下班提醒 - HarmonyOS 版本

基于 Python PySide6 原版移植的 HarmonyOS 应用，专为鸿蒙设备设计。

## 功能特性

- **上班打卡**：点击按钮记录上班时间，自动计算下班时间
- **三种场景**：早到（固定下班）、正常弹性、迟到（按正常下班处理）
- **午休排除**：跨午休时间自动顺延下班时间
- **实时倒计时**：精确到秒的下班倒计时显示
- **下班提醒**：到达下班时间后闪烁提示
- **深色毛玻璃 UI**：280×180 卡片风格，置于桌面一角
- **设置灵活**：弹性时间区间、工作时长、午休时间均可自定义

## 计算规则

| 场景 | 打卡时间 | 下班时间 |
|------|----------|----------|
| 早到 | 弹性上班开始前 | 正常下班时间 |
| 正常 | 弹性上班区间内 | 打卡 + 8小时 + 午休（如跨午休） |
| 迟到 | 超过弹性上班结束 | 正常下班时间 |

**午休排除逻辑**：只有当上班时间在午休开始之前**且**计算出的下班时间在午休开始之后，才额外加上午休时长。

## 技术栈

- **HarmonyOS ArkTS** — 应用框架
- **ArkUI 声明式 UI** — 界面渲染
- **Worker 线程** — 后台计时任务
- **分布式数据管理** — 配置持久化

## 项目结构

```
flex-harmony/
├── oh-package.json5                  # 包管理配置
├── README.md
└── entry/src/main/
    ├── module.json5                  # 模块与权限配置
    └── ets/
        ├── entryability/
        │   └── EntryAbility.ets       # 应用入口
        ├── common/
        │   ├── calculator.ets         # 计算引擎
        │   └── storage.ets            # 持久化存储
        ├── pages/
        │   ├── Index.ets              # 主页面（倒计时卡片）
        │   └── Settings.ets           # 设置页面
        └── worker/
            └── Worker.ets             # 后台任务线程
```

## 使用方法

1. 使用 **DevEco Studio** 打开 `flex-harmony` 目录
2. 同步依赖（HarmonyOS SDK）
3. 编译并运行到设备/模拟器

## 与原版区别

| 功能 | Python PySide6 原版 | HarmonyOS 移植版 |
|------|---------------------|------------------|
| 平台 | Windows 桌面 | HarmonyOS 设备 |
| UI 风格 | Windows 11 毛玻璃 | 鸿蒙深色卡片 |
| 触发方式 | 开机/休眠/空闲/按钮 | 按钮触发 |
| 托盘 | Windows 系统托盘 | App 卡片窗口 |
| 打包 | PyInstaller exe | Hap 应用包 |

## 开源许可

MIT License

## 作者

ericshonnon-maker
