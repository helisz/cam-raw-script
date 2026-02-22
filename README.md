# RAW文件夹清理工具

一个Python脚本，用于清理RAW文件夹中的ARW文件，仅保留与上级目录中JPG同名的文件。

## 功能

- 扫描当前目录下的所有JPG文件（支持 `.jpg`, `.JPG`, `.jpeg`, `.JPEG` 扩展名）
- 进入指定的RAW文件夹（默认为 `RAW`）
- 识别所有ARW文件（支持 `.arw`, `.ARW` 扩展名）
- 删除那些没有对应JPG文件的ARW文件
- 提供干运行模式预览将要删除的文件
- 支持详细输出和自定义RAW文件夹名称

## 使用场景

摄影师经常使用相机同时拍摄JPG和RAW（ARW）格式的照片。JPG文件通常存放在主目录，RAW文件存放在子文件夹（如 `RAW`）中。本工具可帮助清理RAW文件夹，删除那些没有对应JPG文件的RAW文件（例如，误拍或已删除的JPG对应的RAW文件）。

## 使用方法

### 基本用法

1. 将 `clean_raw.py` 脚本放在包含JPG文件的目录中。
2. 确保存在RAW文件夹（默认名称 `RAW`），其中包含ARW文件。
3. 运行脚本：

```bash
python clean_raw.py
```

### 选项

- `--dry-run`：仅显示将要删除的文件，不实际删除。
- `--verbose`：显示详细信息，包括找到的JPG和ARW文件列表。
- `--raw-dir RAW`：指定RAW文件夹名称（默认为 `RAW`）。

### 示例

假设目录结构如下：

```
.
├── IMG1.jpg
├── IMG2.JPG
├── IMG3.jpeg
└── RAW/
    ├── IMG1.ARW
    ├── IMG2.arw
    ├── IMG3.ARW
    ├── IMG5.ARW
    └── IMG6.arw
```

运行命令：

```bash
python clean_raw.py --dry-run --verbose
```

输出：

```
当前目录: /path/to/directory
找到 3 个JPG文件: ['IMG1', 'IMG2', 'IMG3']
RAW文件夹: /path/to/directory/RAW
找到 5 个ARW文件。
将保留 3 个ARW文件: ['IMG2.arw', 'IMG1.ARW', 'IMG3.ARW']
将删除 2 个ARW文件: ['IMG6.arw', 'IMG5.ARW']
干运行模式 - 以下文件将被删除:
  /path/to/directory/RAW/IMG6.arw
  /path/to/directory/RAW/IMG5.ARW
总计: 2 个文件。
```

确认无误后，去掉 `--dry-run` 参数执行删除：

```bash
python clean_raw.py
```

## 安装

无需安装，只需Python 3.6或更高版本。

## 注意事项

- 脚本会永久删除文件，请务必先使用 `--dry-run` 预览。
- 确保RAW文件夹存在，否则脚本会报错退出。
- 脚本不会删除JPG文件，仅删除RAW文件夹中的ARW文件。
- 文件名匹配基于基本文件名（不含扩展名），且不区分大小写。

## 许可证

MIT
