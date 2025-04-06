#!/bin/sh
start_hour=22
end_hour=6
# 提醒10点-6点上床睡觉,start_hour应该大于end_hour!

# 获取当前小时 (24 小时制)
current_hour=$(date +%H)

# 判断当前小时是否在指定范围内
if [[ "$current_hour" -ge "$start_hour" || "$current_hour" -lt "$end_hour" ]]; then
  # class 可以用来在 style.css 中定义不同的样式
  echo '{"text": "󰋣  !", "tooltip": "", "class": "bedtime"}'
else
  # 不在时间段内：输出空 JSON 对象来隐藏模块
  echo '{}'
fi

exit 0
