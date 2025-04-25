# --- 配置 ---
WINDOWS_CONTAINER_NAME="WinApps" # WinApps 容器名 

# --- 主菜单项 ---
# 使用一个占位符 __INPUT__ 来标记需要用户输入的地方
declare -A menu_items

menu_items['󰖚 Hyprsunset 5000K']='pkill hyprsunset ; hyprsunset -t 5000'
menu_items[' next wallpaper']='wpaperctl next-wallpaper'
menu_items['󰌌 Set Hyprsunset Temp...']='pkill hyprsunset ; hyprsunset -t __INPUT__'
menu_items['󰹑 Set display']='nwg-displays'

update_menu_items() {
    # --- 一些需要动态更新的菜单项 ---
    # 1. 检查 Windows 容器是否在运行
    if docker ps -q -f "name=^/${WINDOWS_CONTAINER_NAME}$" | grep -q .; then
        menu_items['󰖳 shutdown windows']="docker stop ${WINDOWS_CONTAINER_NAME}"
    else
        menu_items['󰖳 open windows']="docker start ${WINDOWS_CONTAINER_NAME}"
    fi

    # 2. 检查 Waydroid 是否在运行
    # 使用 pgrep 查找匹配完整命令行的进程
    # -f 选项告诉 pgrep 匹配完整的命令行，而不仅仅是进程名
    # > /dev/null 2>&1 将 pgrep 的标准输出和标准错误都重定向到 /dev/null
    # 我们只关心 pgrep 的退出状态 (0 表示找到，非 0 表示未找到)
    if pgrep -f "lxc-start -P /var/lib/waydroid/lxc" > /dev/null 2>&1; then
        menu_items['󰀲  close waydroid']="waydroid session stop"
    else
        menu_items['󰀲 open waydroid']="waydroid session start &"
    fi
}

# --- 电源菜单项 ---
declare -A power_options
power_options['  Shutdown']='poweroff'
power_options['  Reboot']='reboot'
power_options[' 󰒲 Hibernate']='systemctl hibernate'
power_options['  Lock']='hyprlock' 


# --- 函数 ---

# 显示主菜单并获取选择
call_menu() {
    # 从 menu_items 数组的键（显示文本）生成菜单
    printf "%s\n" "${!menu_items[@]}" | wofi --show dmenu -p " Menu"
}

#  # 执行主菜单选择对应的命令
#  execute_menu() {
#      local selection="$1"
#      # 从 menu_items 数组中查找选中项对应的值（命令）
#      local command="${menu_items[$selection]}"
#  
#      # 如果找到了命令，则执行它
#      if [[ -n "$command" ]]; then
#          # 使用 eval 来确保命令中的特殊字符或参数被正确处理
#          eval "$command"
#      fi
#  }

# 执行主菜单选择对应的命令
execute_menu() {
    local selection="$1"
    local command_template="${menu_items[$selection]}" # 获取命令模板
    local user_input
    local final_command

    # 如果选择无效或用户取消，则退出
    if [[ -z "$command_template" ]]; then
        return
    fi

    # 检查命令模板是否包含占位符 __INPUT__
    if [[ "$command_template" == *__INPUT__* ]]; then
        # 如果包含占位符，则再次调用 wofi 获取用户输入
        # -p 设置提示信息
        user_input=$(wofi --show dmenu -p "Enter Temperature (e.g., 4500):")

        # 检查用户是否提供了输入（没有按 Esc 取消）
        if [[ -n "$user_input" ]]; then
            # 使用 Bash 的字符串替换功能将占位符替换为用户输入
            # ${parameter//pattern/string} 全局替换
            final_command="${command_template//__INPUT__/$user_input}"
            # 执行最终构建好的命令
            eval "$final_command"
        # else
            # 用户取消了输入，可以选择不执行任何操作或给出提示
            # echo "Input cancelled." >&2
        fi
    else
        # 如果命令模板不包含占位符，则直接执行
        eval "$command_template"
    fi
}

# 显示电源菜单并执行选择
call_power() {
    local selection
    # 从 power_options 数组的键生成菜单
    selection=$(printf "%s\n" "${!power_options[@]}" | wofi --show dmenu -p " Power")

    local command="${power_options[$selection]}"

    if [[ -n "$command" ]]; then
        eval "$command"
    # else: 用户取消选择，不执行任何操作
    fi
}

# --- 主逻辑 ---
# 根据传入脚本的第一个参数决定执行哪个菜单
case "$1" in
  menu)
    update_menu_items
    execute_menu "$(call_menu)"
    ;;
  power)
    call_power
    ;;
  *) # 默认行为，显示主菜单
    update_menu_items
    execute_menu "$(call_menu)"
    ;;
esac
