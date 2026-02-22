#!/usr/bin/env python3
"""
清理RAW文件夹中的ARW文件，只保留与上级目录中JPG同名的文件。
或者解锁当前目录及子目录下的所有文件（移除macOS Locked状态）。

用法:
    python clean_raw.py [--dry-run] [--verbose] [--raw-dir RAW]

选项:
    --dry-run   : 仅显示将要删除的文件，不实际删除。
    --verbose   : 显示详细信息。
    --raw-dir   : 指定RAW文件夹名称（默认为RAW）。
"""

import os
import sys
import argparse
import subprocess
from pathlib import Path


def get_jpg_basenames(directory: Path) -> set[str]:
    """返回目录中所有.jpg/.JPG文件的基本文件名（无扩展名）集合。"""
    jpg_files = []
    for ext in ('.jpg', '.JPG', '.jpeg', '.JPEG'):
        jpg_files.extend(directory.glob(f'*{ext}'))
    # 提取基本文件名（不带扩展名）
    basenames = {f.stem for f in jpg_files}
    return basenames


def get_arw_files(raw_dir: Path) -> list[Path]:
    """返回RAW文件夹中所有.arw/.ARW文件的列表。"""
    arw_files = []
    for ext in ('.arw', '.ARW'):
        arw_files.extend(raw_dir.glob(f'*{ext}'))
    return arw_files


def unlock_files(directory: Path, verbose: bool = False) -> int:
    """解锁指定目录及子目录下的所有文件（移除macOS Locked状态）。"""
    unlocked_count = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            file_path = Path(root) / file
            try:
                # 使用chflags移除Locked状态（uchg标志）
                result = subprocess.run(
                    ['chflags', '-R', 'nouchg', str(file_path)],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    unlocked_count += 1
                    if verbose:
                        print(f"已解锁: {file_path}")
            except Exception as e:
                if verbose:
                    print(f"解锁失败 {file_path}: {e}")
    return unlocked_count


def show_menu():
    """显示功能选择菜单。"""
    print("\n请选择功能:")
    print("  1. 清理RAW文件夹中的ARW文件（只保留与JPG同名的文件）")
    print("  2. 解锁当前目录及子目录下的所有文件")
    print("  0. 退出")
    choice = input("请输入选项 (0/1/2): ").strip()
    return choice


def main():
    parser = argparse.ArgumentParser(description='清理RAW文件夹中的ARW文件，或解锁文件。')
    parser.add_argument('--dry-run', action='store_true',
                        help='仅显示将要删除的文件，不实际删除（仅对功能1有效）。')
    parser.add_argument('--verbose', action='store_true',
                        help='显示详细信息。')
    parser.add_argument('--raw-dir', default='RAW',
                        help='RAW文件夹名称（默认为RAW）。')
    args = parser.parse_args()

    # 显示菜单并获取用户选择
    choice = show_menu()

    if choice == '0':
        print("退出程序。")
        return
    elif choice == '1':
        # 功能1: 清理RAW文件夹中的ARW文件
        current_dir = Path.cwd()
        raw_dir = current_dir / args.raw_dir

        if not raw_dir.exists():
            print(f"错误: RAW文件夹 '{raw_dir}' 不存在。")
            sys.exit(1)
        if not raw_dir.is_dir():
            print(f"错误: '{raw_dir}' 不是目录。")
            sys.exit(1)

        # 获取上级目录中的JPG基本文件名
        jpg_basenames = get_jpg_basenames(current_dir)
        if args.verbose:
            print(f"当前目录: {current_dir}")
            print(f"找到 {len(jpg_basenames)} 个JPG文件: {sorted(jpg_basenames)}")

        # 获取RAW文件夹中的ARW文件
        arw_files = get_arw_files(raw_dir)
        if args.verbose:
            print(f"RAW文件夹: {raw_dir}")
            print(f"找到 {len(arw_files)} 个ARW文件。")

        # 决定保留和删除的文件
        to_keep = []
        to_delete = []
        for arw in arw_files:
            if arw.stem in jpg_basenames:
                to_keep.append(arw)
            else:
                to_delete.append(arw)

        if args.verbose:
            print(f"将保留 {len(to_keep)} 个ARW文件: {[f.name for f in to_keep]}")
            print(f"将删除 {len(to_delete)} 个ARW文件: {[f.name for f in to_delete]}")

        if not to_delete:
            print("没有需要删除的ARW文件。")
            return

        if args.dry_run:
            print("干运行模式 - 以下文件将被删除:")
            for f in to_delete:
                print(f"  {f}")
            print(f"总计: {len(to_delete)} 个文件。")
            return

        # 实际删除
        print(f"准备删除 {len(to_delete)} 个ARW文件...")
        deleted_count = 0
        for f in to_delete:
            try:
                f.unlink()
                if args.verbose:
                    print(f"已删除: {f}")
                deleted_count += 1
            except Exception as e:
                print(f"删除失败 {f}: {e}")
        print(f"完成。已删除 {deleted_count} 个文件。")
    elif choice == '2':
        # 功能2: 解锁当前目录及子目录下的所有文件
        current_dir = Path.cwd()
        print(f"正在解锁目录: {current_dir}")
        print("这将递归解锁当前目录及所有子目录中的文件...")
        
        confirm = input("确认继续? (y/n): ").strip().lower()
        if confirm != 'y':
            print("已取消。")
            return
        
        unlocked_count = unlock_files(current_dir, args.verbose)
        print(f"完成。已解锁 {unlocked_count} 个文件。")
    else:
        print("无效的选项。")
        sys.exit(1)


if __name__ == '__main__':
    main()