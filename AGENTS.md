# gInk 开发指南

## 项目概述

gInk 是一个 Windows 上的墨迹注释工具，基于 Windows Forms 和 Microsoft Ink 技术开发。

## 技术栈

- **语言**: C#
- **框架**: .NET Framework 3.5 / Windows Forms
- **构建工具**: MSBuild (Visual Studio 2017+)
- **依赖**: Microsoft.Ink.dll (手写识别 SDK)

---

## 构建命令

### 本地构建脚本

```bash
powershell -ExecutionPolicy Bypass -File build.ps1
```

build.ps1 脚本会自动：
1. 检查并关闭正在运行的 gInk.exe
2. 使用 MSBuild 编译 Release|x86 版本
3. 输出编译结果

### 手动构建

```bash
# 使用完整路径的 MSBuild
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" gInk.sln /p:Configuration=Release /p:Platform=x86 /verbosity:minimal

# Debug 版本
msbuild gInk.sln /p:Configuration=Debug /p:Platform=x86
```

### 构建配置

- **Debug|x86**: 输出路径 `bin\`，包含调试符号
- **Release|x86**: 输出路径 `bin\`，已优化

### 运行程序

```bash
bin\gInk.exe
```

---

## 测试

本项目**没有单元测试框架**。手动测试步骤：
1. 使用 `build.ps1` 构建 Release 版本
2. 运行 `bin\gInk.exe`
3. 测试各项功能：绘图、擦除、截图、收藏等

---

## 代码风格指南

### 格式化

- **缩进**: 4 空格 (VS 默认)
- **行尾**: Windows CRLF
- **大括号**: K&R 风格 (同一行开括号，换行闭括号)
- **命名空间**: 简洁风格 (非显式 `global::`)

### 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 类/接口 | PascalCase | `Root`, `FormDisplay`, `IMessageFilter` |
| 方法 | PascalCase | `StartInk()`, `SelectPen()` |
| 字段(私有) | camelCase | `EraserMode`, `PointerMode` |
| 字段(公共) | PascalCase | `Local`, `PenAttr` |
| 常量 | PascalCase | `MaxPenCount` |
| 参数 | camelCase | `root`, `errormsg` |
| 控件字段 | PascalCase | `btnPen`, `panelMain` |

### 导入 (using)

```csharp
using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.IO;
using System.Drawing;
using Microsoft.Ink;
```

排序：System → System.XXX → 第三方

### 类型使用

- **整数**: `int` (默认)
- **布尔值**: `bool`
- **字符串**: `string`
- **集合**: `List<T>`, `Dictionary<K,V>`
- **事件**: `EventHandler`, `ThreadExceptionEventHandler`

### 错误处理

- **UI 线程异常**: 通过 `Application.ThreadException` 捕获
- **未处理异常**: 通过 `AppDomain.UnhandledException` 捕获
- **异常日志**: 写入程序目录下的 `crash.txt`
- **一般异常**: 使用 `try-catch`，避免吞掉异常

```csharp
try
{
    // 操作
}
catch (Exception ex)
{
    WriteErrorLog(ex.Message);
    // 提示用户或优雅退出
}
```

### 重要模式

#### 单实例运行 (Mutex)

```csharp
using(Mutex mutex = new Mutex(false, "Global\\" + appGuid))
{
    if(!mutex.WaitOne(0, false))
        return; // 已有一个实例
    // 主程序逻辑
}
```

#### 消息过滤器 (热键)

```csharp
public class TestMessageFilter : IMessageFilter
{
    public bool PreFilterMessage(ref Message m)
    {
        if (m.Msg == 0x0312) // WM_HOTKEY
        {
            // 处理热键
        }
        return false;
    }
}
Application.AddMessageFilter(new TestMessageFilter(this));
```

#### 资源管理

- 使用 `using` 语句确保 IDisposable 对象释放
- 图像资源嵌入为 Content 或 EmbeddedResource

### 文件组织

```
src/
├── Program.cs          # 入口点，全局异常处理
├── Root.cs            # 主程序类，全局状态
├── FormDisplay.cs     # 主绘图窗口
├── FormCollection.cs  # 收藏窗口
├── FormOptions.cs     # 选项设置窗口
├── Hotkey.cs          # 热键处理
├── Local.cs           # 本地化/语言
├── *.Designer.cs     # Windows Forms 自动生成
├── *.resx            # 资源文件
└── Properties/
    ├── AssemblyInfo.cs
    ├── Resources.resx
    └── Settings.settings
```

### 注意事项

1. **不要修改 Designer.cs** - 由 Visual Studio 自动生成
2. **resx 文件** - 包含本地化字符串和 UI 资源
3. **x86 平台** - 项目仅支持 x86 (32位)
4. **Microsoft.Ink.dll** - 必须与 exe 同目录

---

## 常用开发任务

### 添加新功能

1. 在适当的功能类中添加方法
2. 更新 `Local.cs` 添加多语言支持
3. 如需 UI，修改对应的 Form.Designer.cs
4. 构建测试

### 添加新语言

1. 编辑 `Local.cs` 的 `strings` 字典
2. 添加对应的资源字符串

### 修改选项

1. 编辑 `FormOptions.cs` 和 `FormOptions.Designer.cs`
2. 在 `Root.cs` 中添加对应字段

---

## 相关文件

- `gInk.sln` - Visual Studio 解决方案
- `build.ps1` - 本地构建脚本
- `bin/gInk.exe` - 编译输出
- `readme.md` - 项目说明
