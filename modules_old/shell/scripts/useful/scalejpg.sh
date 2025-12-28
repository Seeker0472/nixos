#!/bin/bash
# 批量处理 JPG 文件，使用 ImageMagick 进行压缩

# 确保输出目录存在

# 获取 CPU 核心数 (逻辑核心)
#num_cores=$(nproc)
# 调小,防止内存不足
num_cores=4

target_width=8192
echo "将使用 $num_cores 个核心进行并行处理..."

backup_dir="../original_jpg_backups"
mkdir -p "$backup_dir"

# 使用 find 和 xargs 并行处理
# find 更安全地处理包含特殊字符的文件名
# -print0 和 xargs -0 配合使用，确保正确处理含空格等特殊字符的文件名
find . -type f -name '*.jpg' -print0 | xargs -0 -P "$num_cores" -I {} sh -c '
  input_file="$1"
  target_width="$2"
  backup_dir="$3"
  output_file="$input_file"

  # ---获取scale_factor---
  current_width=$(identify -format "%w" "$input_file")
  if [ "$current_width" -lt "$target_width" ];then
    exit 0
  fi
  scale_factor=$(( target_width * 100 / current_width ))

  # ---备份原始文件---
  target_backup_file="$backup_dir/$input_file"
  mkdir -p "$(dirname "$target_backup_file")"
  if [ -f "$target_backup_file" ]; then
    echo "目标文件($target_backup_file)存在,跳过backup"
  else
    cp "$input_file" "$target_backup_file"
  fi

  echo "处理: $input_file ( Scale:${scale_factor}%) -> 目标: $output_file"

  # 执行图片压缩命令
  magick "$input_file" -scale $scale_factor% -format jpg "$output_file"

  # 检查 magick 命令的退出状态
  if [ $? -ne 0 ]; then
    echo "错误: 处理 $input_file 失败！" >&2
  fi

' _ {} "$target_width" "$backup_dir"

