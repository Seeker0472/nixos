#!/bin/bash

# --- 配置 ---
TARGET_DIR="audio"
OUTPUT_DIR="srt"
# --- 配置结束 ---

# 检查源目录是否存在
if [ ! -d "./$TARGET_DIR" ]; then
    echo "错误：在当前目录下未找到源目录 \"$TARGET_DIR\"。"
    echo "请确保你在包含 '$TARGET_DIR' 目录的父目录下运行此脚本。"
    exit 1
fi

# 创建主输出目录
echo "确保主输出目录 \"$OUTPUT_DIR\" 存在..."
if ! mkdir -p "$OUTPUT_DIR"; then
    echo "错误：无法创建主输出目录 \"$OUTPUT_DIR\"。"
    exit 1
fi

echo "正在搜索 \"./$TARGET_DIR\" 中的 MP3 文件..."

# 使用 Process Substitution 和 mapfile 将 find 的结果读入数组 (需要 Bash 4+)
declare -a mp3_files
mapfile -d $'\0' mp3_files < <(find "./$TARGET_DIR" -type f -name "*.srt" -print0)

# 检查 find 是否找到文件
if [[ ${#mp3_files[@]} -eq 0 ]]; then
    echo "未在 \"./$TARGET_DIR\" 中找到任何 .mp3 文件。"
    exit 0
fi

echo "找到 ${#mp3_files[@]} 个 MP3 文件。开始转换..."

# 遍历数组
file_count=0
converted_count=0
skipped_count=0
error_count=0

for mp3_file in "${mp3_files[@]}"; do
    ((file_count++))
    echo -n "处理中 ($file_count/${#mp3_files[@]}): \"$mp3_file\" ... "

    # 检查文件路径是否真的存在且可读 
    if [[ ! -r "$mp3_file" ]]; then
        echo "错误：文件似乎不存在或无法读取。跳过。"
        ((error_count++))
        continue
    fi

    # 获取相对路径
    relative_path="${mp3_file#./$TARGET_DIR/}"
    relative_path="${relative_path#$TARGET_DIR/}" # 兼容没有 './' 前缀的情况
    #wav_relative_path="${relative_path%.mp3}.wav"
    wav_relative_path="${relative_path}"
    wav_full_output_path="$OUTPUT_DIR/$wav_relative_path"
    wav_output_dir=$(dirname "$wav_full_output_path")

    # 检查目标文件是否已存在
    if [[ -f "$wav_full_output_path" ]]; then
        echo "已存在，跳过。"
        ((skipped_count++))
        continue
    fi

    # 创建输出目录
    if ! mkdir -p "$wav_output_dir"; then
        echo "错误：无法创建目录 \"$wav_output_dir\"。跳过。"
        ((error_count++))
        continue
    fi

    # 执行 ffmpeg 转换，重定向输出以保持整洁
#    ffmpeg -hide_banner -i "$mp3_file" -vn -acodec pcm_s16le -ar 16000 -ac 2 "$wav_full_output_path" > /dev/null 2>&1
    cp "$mp3_file" "$wav_full_output_path"
    ffmpeg_exit_code=0

    if [[ $ffmpeg_exit_code -eq 0 ]]; then
        echo "转换成功。"
        ((converted_count++))
    else
        echo "转换失败 (ffmpeg exit code: $ffmpeg_exit_code)。"
        ((error_count++))
        # 可以选择删除可能产生的空/不完整输出文件
        # rm -f "$wav_full_output_path"
    fi
done

echo "----------------------------------------"
echo "所有转换任务处理完毕！"
echo "总文件数: $file_count"
echo "成功转换: $converted_count"
echo "已存在跳过: $skipped_count"
echo "发生错误: $error_count"
echo "输出文件位于 \"$OUTPUT_DIR\" 目录。"

exit 0
