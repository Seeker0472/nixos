#!/bin/bash
# 批量处理音频文件，使用 whisper.cpp 进行转录

MODEL_PATH="/root/whisper.cpp/models/ggml-large-v3-turbo.bin"
INPUT_DIR="/root/audio/unpacked"
WISPER_DIR=/root/whisper.cpp/build/bin/whisper-cli
LANGUAGE="en" # 或者指定语言如 "en", "zh"

# 查找所有常见的音频/视频文件并处理
find "$INPUT_DIR" -type f  -name "*.wav" -print0 | while IFS= read -r -d $'\0' file; do
    echo "Processing file: $file"
    $WISPER_DIR -t 64 -m "$MODEL_PATH" -f "$file" -l "$LANGUAGE" -osrt -ovtt --split-on-word  --print-progress
    echo "Finished processing: $file"
    echo "---------------------"
done

echo "Batch processing complete."
