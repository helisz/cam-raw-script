#!/bin/bash
#
# 清理RAW文件夹中的ARW文件，只保留与上级目录中JPG同名的文件。
# 或者解锁当前目录及子目录下的所有文件（移除macOS Locked状态）。
#
# 双击此文件即可运行

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 功能1: 清理RAW文件夹中的ARW文件
clean_raw_files() {
    local raw_dir="$SCRIPT_DIR/RAW"
    
    if [ ! -d "$raw_dir" ]; then
        echo "错误: RAW文件夹 '$raw_dir' 不存在。"
        return 1
    fi
    
    echo ""
    echo "正在扫描JPG文件..."
    jpg_files=()
    for ext in jpg JPG jpeg JPEG; do
        while IFS= read -r -d '' file; do
            jpg_files+=("$file")
        done < <(find "$SCRIPT_DIR" -maxdepth 1 -type f -iname "*.$ext" -print0)
    done
    
    if [ ${#jpg_files[@]} -eq 0 ]; then
        echo "警告: 未找到任何JPG文件。"
    else
        echo "找到 ${#jpg_files[@]} 个JPG文件"
    fi
    
    echo ""
    echo "正在扫描ARW文件..."
    arw_files=()
    for ext in arw ARW; do
        while IFS= read -r -d '' file; do
            arw_files+=("$file")
        done < <(find "$raw_dir" -type f -iname "*.$ext" -print0)
    done
    
    if [ ${#arw_files[@]} -eq 0 ]; then
        echo "未找到任何ARW文件。"
        return 0
    fi
    
    echo "找到 ${#arw_files[@]} 个ARW文件"
    
    # 找出需要删除的文件
    to_delete=()
    for arw_file in "${arw_files[@]}"; do
        basename=$(basename "$arw_file" | sed 's/\.[^.]*$//')
        found=0
        for jpg_file in "${jpg_files[@]}"; do
            jpg_basename=$(basename "$jpg_file" | sed 's/\.[^.]*$//')
            if [ "$basename" = "$jpg_basename" ]; then
                found=1
                break
            fi
        done
        if [ $found -eq 0 ]; then
            to_delete+=("$arw_file")
        fi
    done
    
    if [ ${#to_delete[@]} -eq 0 ]; then
        echo ""
        echo "没有需要删除的ARW文件。"
        return 0
    fi
    
    echo ""
    echo "将删除 ${#to_delete[@]} 个ARW文件:"
    for file in "${to_delete[@]}"; do
        echo "  $(basename "$file")"
    done
    
    echo ""
    read -p "确认删除? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消。"
        return 0
    fi
    
    echo ""
    echo "正在删除..."
    deleted_count=0
    for file in "${to_delete[@]}"; do
        if rm -f "$file"; then
            echo "  已删除: $(basename "$file")"
            ((deleted_count++))
        else
            echo "  删除失败: $(basename "$file")"
        fi
    done
    
    echo ""
    echo "完成。已删除 $deleted_count 个文件。"
}

# 功能2: 解锁当前目录及子目录下的所有文件
unlock_files() {
    echo ""
    echo "正在解锁目录: $SCRIPT_DIR"
    echo "这将递归解锁当前目录及所有子目录中的文件..."
    echo ""
    read -p "确认继续? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消。"
        return 0
    fi
    
    echo ""
    echo "正在解锁文件..."
    unlocked_count=0
    
    # 使用chflags移除Locked状态
    while IFS= read -r -d '' file; do
        if chflags -R nouchg "$file" 2>/dev/null; then
            ((unlocked_count++))
            echo "  已解锁: $file"
        fi
    done < <(find "$SCRIPT_DIR" -type f -print0)
    
    echo ""
    echo "完成。已解锁 $unlocked_count 个文件。"
}

# 主程序
cd "$SCRIPT_DIR"

while true; do
    echo ""
    echo "=========================================="
    echo "  RAW文件清理工具"
    echo "=========================================="
    echo "当前目录: $SCRIPT_DIR"
    echo ""
    echo "请选择功能:"
    echo "  1. 清理RAW文件夹中的ARW文件（只保留与JPG同名的文件）"
    echo "  2. 解锁当前目录及子目录下的所有文件"
    echo "  0. 退出"
    echo "=========================================="
    read -p "请输入选项 (0/1/2): " choice
    
    case "$choice" in
        0)
            echo "退出程序。"
            break
            ;;
        1)
            clean_raw_files
            ;;
        2)
            unlock_files
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..." dummy
done

# 保持窗口打开以便查看结果
echo ""
echo "按回车键关闭窗口..."
read dummy
