#!/bin/bash
# 批量处理 PNG 文件，使用 ImageMagick 进行转换为 JPG 格式

# 确保输出目录存在
mkdir -p compressed_images

# 获取 CPU 核心数 (逻辑核心)
num_cores=$(nproc)
echo "将使用 $num_cores 个核心进行并行处理..."

# 使用 find 和 xargs 并行处理
# find 更安全地处理包含特殊字符的文件名
# -print0 和 xargs -0 配合使用，确保正确处理含空格等特殊字符的文件名
# 修改了输出文件名的部分，确保扩展名为 .jpg
find . -maxdepth 1 -type f -name '*.png' -print0 | xargs -0 -P "$num_cores" -I {} sh -c '
  input_file="$1"
  output_basename=$(basename "$input_file" .png) # 移除 .png 后缀
  output_file="compressed_images/${output_basename}.jpg"
  echo "处理: $input_file -> $output_file"
  magick "$input_file" -quality 90% -format jpg "$output_file"
' sh {}

echo "并行处理完成！输出文件位于 compressed_images 目录。"
