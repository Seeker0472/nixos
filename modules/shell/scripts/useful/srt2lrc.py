'''
Run it in srt file folder.
python 3.x
'''
from pathlib import Path
import os
import re
import glob


SRT_BLOCK_REGEX = re.compile(
        r'(\d+)[^\S\r\n]*[\r\n]+'
        r'(\d{2}:\d{2}:\d{2},\d{3,4})[^\S\r\n]*-->[^\S\r\n]*(\d{2}:\d{2}:\d{2},\d{3,4})[^\S\r\n]*[\r\n]+'
        r'([\s\S]*)')



def srt_time_to_lrc_time(srt_timestamp):
    """
    将 SRT 时间戳字符串 (HH:MM:SS,ms) 转换为 LRC 时间戳字符串 ([mm:ss.xx]).

    Args:
        srt_timestamp: SRT 格式的时间字符串，例如 "02:06:04,800".

    Returns:
        LRC 格式的时间字符串，例如 "[126:04.80]", 或在出错时返回 "[00:00.00]".
    """
    try:
        time_part, ms_part = srt_timestamp.split(',')
        h, m, s = map(int, time_part.split(':'))

        # 标准化毫秒到3位，然后计算百分之一秒
        # .ljust(3, '0')[:3] 确保即使原始毫秒少于3位或多于3位也能正确处理
        ms = int(ms_part.ljust(3, '0')[:3])
        hundredths = ms // 10 # 取整获取百分之一秒

        # 计算总秒数
        total_seconds = h * 3600 + m * 60 + s

        # 计算 LRC 的分钟数和秒数
        lrc_mm = total_seconds // 60
        lrc_ss = total_seconds % 60

        # 格式化输出，确保秒数和百分之一秒是两位数（补零）
        # 分钟数不需要补零，因为它可以超过两位数
        return f"[{lrc_mm:02d}:{lrc_ss:02d}.{hundredths:02d}]"
    except ValueError:
        # 如果时间戳格式不正确，返回一个默认值或打印错误
        print(f"警告：无法解析 SRT 时间戳: {srt_timestamp}")
        return "[00:00.00]"

# 将函数重命名为 srt_block_to_lrc 更准确，因为输出是 LRC 格式
def srt_block_to_lrc(block):
    """
    将单个 SRT 字幕块转换为标准的 LRC 格式行.

    Args:
        block: 包含单个 SRT 字幕块的字符串.

    Returns:
        一个 LRC 格式的字符串行 "[mm:ss.xx]Content", 或在无法解析时返回 None.
    """
    match = SRT_BLOCK_REGEX.search(block)
    if not match:
        print(f"警告：无法解析 SRT 块: {block}")
        return None

    num, ts_srt, te_srt, content = match.groups()
    # print("原始 ts:", ts_srt) # 可以取消注释用于调试
    # print("原始 te:", te_srt) # 可以取消注释用于调试

    # 使用辅助函数转换开始时间
    ts_lrc = srt_time_to_lrc_time(ts_srt)

    # --- 处理内容 ---
    # 移除首尾空白，并将多行内容合并为一行，用空格分隔
    # 这是 LRC 的常见做法，因为标准 LRC 通常一行对应一个时间戳
    co = ' '.join(content.strip().splitlines())

    # --- 构建 LRC 行 ---
    # 标准 LRC 格式是：[时间戳]歌词内容
    # 你的原始格式 '[%s]%s\n[%s]\n' 不是标准的 LRC 格式。
    # 这里我们生成标准的 LRC 行，只使用开始时间戳。
    return f"{ts_lrc}\n{ts_lrc}{co}\n"

def srt_file_to_irc(fname):
    with open(fname, encoding='utf8') as file_in:
        str_in = file_in.read()
        blocks_in = str_in.replace('\r\n', '\n').split('\n\n')
        blocks_out = [srt_block_to_lrc(block) for block in blocks_in]
        if not all(blocks_out):
            err_info.append((fname, blocks_out.index(None), blocks_in[blocks_out.index(None)]))
        blocks_out = filter(None, blocks_out)
        str_out = ''.join(blocks_out)
        with open(fname.replace('srt', 'lrc'), 'w', encoding='utf8') as file_out:
            file_out.write(str_out)


if __name__ == '__main__':
    err_info = []
        # Prompt the user to enter the directory path
    directory = input("Enter the directory path where the .lrc files are located: ")

    # Validate the directory path
    while not os.path.isdir(directory):
        print("Invalid directory path. Please try again.")
        directory = input("Enter the directory path where the .lrc files are located: ")

    # Get a list of all .lrc files in the directory
    # lrc_files = [file for file in os.listdir(directory) if file.endswith('.lrc')]
    lrc_files = [p for p in Path(directory).rglob('*.srt') if p.is_file()]
    print(lrc_files)
    for file_name in lrc_files:
        print(str(file_name))
        srt_file_to_irc(str(file_name))
    if err_info:
        print('success, but some exceptions are ignored:')
        for file_name, blocks_num, context in err_info:
            print('\tfile: %s, block num: %s, context: %s' % (file_name, blocks_num, context))
    else:
        print('success')
