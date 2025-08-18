#!/bin/bash

# 检查 ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "错误: ffmpeg 未安装。" >&2
    exit 1
fi

# 检查是否提供了目录参数，如果没有则使用当前目录
# TARGET_DIR="${1:-.}"
#TARGET_DIR="/run/media/seeker/7000-8000/DCIM/100GOPRO/"
TARGET_DIR="/run/media/seeker/Data-C001-GoProAll/GOPRO/骑车/"
#CMD_COMMAND="-c copy"
#CMD_COMMAND="-vf "transpose=2,transpose=2" -c:v libx264 -crf 20 -preset medium -c:a copy"
CMD_COMMAND="-vf "format=nv12,transpose=2,transpose=2,hwupload" -c:v h264_vaapi -qp 20 -preset medium -c:a copy"
OUTPUT_DIR="/run/media/seeker/DATA_EXT/compress/qc/"

if [ ! -d "$TARGET_DIR" ]; then
    echo "错误: 目录 '$TARGET_DIR' 不存在。" >&2
    exit 1
fi

echo "将在目录 '$TARGET_DIR' 中进行操作..."

# 进入目标目录会让后续路径处理更简单
cd "$TARGET_DIR" || exit

echo "开始查找 GoPro 视频序列..."

VIDEO_IDS=$(ls -1 GH*.MP4 2>/dev/null | sed -n 's/GH..\(....\)\.MP4/\1/p' | sort -u)

if [ -z "$VIDEO_IDS" ]; then
    echo "在目录中未找到格式为 GHxxYYYY.MP4 的文件。"
    exit 0
fi

echo "找到以下视频序列ID: $VIDEO_IDS"
echo "---"

for id in $VIDEO_IDS; do
    OUTPUT_FILE="$OUTPUT_DIR/GOPRO_MERGED_${id}.MP4"
    echo "正在处理视频序列: ${id}"

    if [ -f "$OUTPUT_FILE" ]; then
        echo "  -> 跳过，因为合并文件 ${OUTPUT_FILE} 已存在。"
        echo "---"
        continue
    fi

    LIST_FILE="file_list_${id}.txt"
    # 使用 find . -maxdepth 1... 因为我们已经 cd 到了目标目录
    find . -maxdepth 1 -name "GH*${id}.MP4" | sort | while read -r filename; do
        echo "file '${filename#./}'" >> "$LIST_FILE"
    done

    if [ ! -s "$LIST_FILE" ]; then
        echo "  -> 错误: 无法为序列 ${id} 创建文件列表。"
        rm -f "$LIST_FILE"
        continue
    fi

    echo "  -> 找到的分片文件已写入 ${LIST_FILE}"
    echo "  -> 开始合并成 ${OUTPUT_FILE}..."

    ffmpeg -f concat -safe 0 -hwaccel vaapi -i "$LIST_FILE" $CMD_COMMAND "$OUTPUT_FILE"

    if [ $? -eq 0 ]; then
        echo "  -> 成功创建: ${OUTPUT_FILE}"
    else
        echo "  -> 错误: 合并序列 ${id} 时发生错误。"
    fi
    
    rm "$LIST_FILE"
    echo "---"
done

echo "所有任务已完成！"
