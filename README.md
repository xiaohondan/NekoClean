# NekoClean - C 盘空间清理工具

<div align="center">

![Windows](https://img.shields.io/badge/Windows-0078D4?style=flat-square&logo=windows&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/NekoAiDev/nekoclean)

**一个安全、简单、高效的 Windows C 盘清理工具，无需安装，下载即用。**

[English](./README_en.md) | 简体中文

</div>

---

## 功能特性

NekoClean 提供多种清理模式，满足不同场景需求：

| 模式 | 描述 | 适用场景 |
|------|------|----------|
| **快速扫描** | 仅查看可清理的垃圾文件大小，不删除 | 清理前查看预估效果 |
| **智能清理** | 自动清理安全垃圾文件（临时文件、回收站等） | 日常定期维护 |
| **深度清理** | 包含智能清理 + 预读取文件、DNS 缓存等 | 系统优化 |
| **完整清理** | 包含深度清理 + Windows 日志、错误报告等 | 紧急释放空间 |

### 支持清理的项目

- ✅ 用户临时文件夹 (`%TEMP%`)
- ✅ Windows 系统临时文件
- ✅ 预读取文件 (Prefetch)
- ✅ 缩略图缓存
- ✅ 回收站
- ✅ Windows Update 缓存
- ✅ DirectX 着色器缓存
- ✅ npm 缓存
- ✅ DNS 缓存 (深度+)
- ✅ Windows 日志 (完整)
- ✅ 错误报告文件 (完整)

## 界面预览

```
  ============================================================
  |       NekoClean  C盘清理工具  v1.0.0                  |
  ============================================================

  [!] 使用前请关闭其他程序，建议右键以管理员身份运行

  请选择操作：

  [1]  快速扫描  - 查看可清理的垃圾文件大小
  [2]  智能清理  - 自动清理安全垃圾文件
  [3]  深度清理  - 包含 Prefetch 和 DNS 缓存
  [4]  完整清理  - 包含 Windows 日志和错误报告
  [5]  查看日志  - 查看上次清理记录
  [0]  退出
```

## 快速开始

### 方法一：直接运行

1. 下载 `NekoClean.ps1`
2. 右键选择 **"以管理员身份运行"**
3. 选择清理模式即可

> 💡 如果双击没有自动用 PowerShell 打开，可以右键 → "使用 PowerShell 运行"，或先打开 PowerShell 再执行 `.\NekoClean.ps1`

### 方法二：PowerShell 命令行

```powershell
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode scan   # 扫描
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode smart  # 智能清理
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode deep   # 深度清理
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode full    # 完整清理
```

### 方法三：克隆仓库

```bash
git clone https://github.com/NekoAiDev/nekoclean.git
cd nekoclean
.\NekoClean.ps1
```

## 使用说明

### 基本操作流程

1. **启动工具**：右键 `NekoClean.ps1` → "以管理员身份运行"（或双击）
2. **快速扫描**：先选择 `1` 扫描，查看可清理的大小
3. **选择模式**：根据需要选择清理模式（`2`/`3`/`4`）
4. **确认清理**：按回车开始，自动完成清理
5. **重启建议**：清理完成后建议重启电脑

### 模式说明

#### 快速扫描
扫描并显示各类垃圾文件的总大小，不进行任何删除操作。适合在清理前评估空间占用。

#### 智能清理（推荐）
安全清理以下项目，**不影响系统正常运行**：
- 用户临时文件
- Windows 临时文件
- 缩略图缓存（自动重建）
- 回收站
- Windows Update 缓存
- DirectX 着色器缓存

#### 深度清理
在智能清理基础上额外清理：
- 预读取文件（提升开机速度）
- DNS 缓存（解决 DNS 解析问题）

#### 完整清理
在深度清理基础上额外清理：
- Windows 日志文件
- 错误报告文件
- 启动碎片整理（后台执行）

### 注意事项

- ⚠️ 部分清理操作需要 **管理员权限**，请右键"以管理员身份运行"
- ⚠️ 清理过程中请勿关闭 PowerShell 窗口
- ⚠️ 完整清理可能影响系统日志查看，如无必要建议使用智能清理
- ⚠️ 缩略图缓存清理后会短暂影响图片预览，重新打开文件夹即可恢复

## 常见问题

### Q: 双击 .ps1 文件无法运行？
**A:** 右键 → "使用 PowerShell 运行"，或者打开 PowerShell 后输入 `.\NekoClean.ps1`

### Q: 提示"禁止运行脚本"？
**A:** 当前执行策略限制了脚本运行。使用 `-ExecutionPolicy Bypass` 参数绕过，或以管理员身份运行：`powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1`

### Q: 清理后缩略图不显示？
**A:** 正常现象，NekoClean 会自动重建缩略图缓存，首次打开文件夹时需要重新生成预览。

### Q: 可以定时自动清理吗？
**A:** 可以通过 Windows 任务计划程序设置定时任务，指向 `powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode smart`

### Q: 是否支持清理其他磁盘？
**A:** 当前版本仅支持 C 盘清理，其他磁盘清理功能开发中。

## 项目结构

```
nekoclean/
├── Nekoclean.ps1     # 主程序 (PowerShell)
├── README.md          # 项目说明 (简体中文)
├── README_en.md       # 项目说明 (English)
└── LICENSE            # MIT 许可证
```

## 更新日志

### v1.0.0 (2026-05-01)
- 🎉 首次发布
- 支持四种清理模式（扫描/智能/深度/完整）
- 交互式菜单界面
- 清理日志记录
- 缩略图缓存自动重建
- 碎片整理后台执行

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

本项目采用 [MIT License](LICENSE) 开源。

---

<div align="center">

**Made with ❤️ by <a href="https://github.com/NekoAiDev">Neko Ai</a>**

</div>
