# RAW文件清理工具

一个命令行工具，用于管理RAW文件。

## 功能

1. **解锁文件** - 解锁当前目录及子目录下的所有文件（移除只读属性）
2. **移动RAW文件** - 创建RAW文件夹并将所有RAW文件移入其中
3. **删除RAW文件** - 删除RAW文件夹中的RAW文件，只保留与JPG同名的文件（永久删除）
4. **清理RAW文件** - 删除RAW文件夹中的RAW文件，只保留与JPG同名的文件（移到回收站）

## 支持的RAW格式

- 索尼 (Sony)：.ARW、.SRF（早期型号较少见）
- 佳能 (Canon)：.CR2、.CR3（新款机型）
- 尼康 (Nikon)：.NEF、.NRW（部分紧凑型相机）
- 富士 (Fujifilm)：.RAF
- 松下 (Panasonic)：.RW2、.RAW（少数型号）
- 奥林巴斯 / OM System：.ORF
- 适马 (Sigma)：.X3F
- 徕卡 (Leica)：.DNG、.RAW（部分型号）
- 宾得 (Pentax)：.PEF、.DNG
- 哈苏 (Hasselblad)：.3FR、.FFF
- 飞思 (Phase One)：.IIQ

## 使用方法

### macOS

拷贝 `clean_raw.command` 至待清理的目录，双击即可运行。

### Windows

拷贝 `clean_raw.bat` 至待清理的目录，双击即可运行。

## 注意事项

- 文件名匹配基于基本文件名（不含扩展名）
