# RAW文件清理工具

一个macOS命令行工具，用于管理RAW文件。

## 功能

1. **解锁文件** - 解锁当前目录及子目录下的所有文件（移除macOS Locked状态）
2. **移动RAW文件** - 创建RAW文件夹并将所有RAW文件移入其中
3. **清理RAW文件** - 删除RAW文件夹中没有对应JPG同名的文件

## 支持的RAW格式

3fr, arw, cr2, dng, erf, kdc, mef, mos, mrw, nrw, orf, pef, ptx, pxn, r3d, raw, raf, rw2, rwl, srf, srw, x3f

## 使用方法

双击 `clean_raw.command` 文件即可运行，然后选择对应的功能选项。

## 注意事项

- 删除操作不可逆，请确认后再执行
- 文件名匹配基于基本文件名（不含扩展名）
