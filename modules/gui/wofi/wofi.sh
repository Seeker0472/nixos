# 打印菜单
call_menu() {
    echo ' set wallpaper'
    [ "$(docker ps | grep windows)" ] && echo '󰖳 shutdown windows' || echo '󰖳 open windows'
}

call_power(){
    case $(echo -e ' 关机\n  重启\n 󰒲 休眠\n  锁定' | wofi --show dmenu -window-title power) in
    " 关机") poweroff ;;
    " 重启") reboot ;;
    "󰒲 休眠") systemctl hibernate ;;
    " 锁定") notify-send "TODO" ;;
    esac
}

# 执行菜单
execute_menu() {
    case $1 in
    ' set wallpaper')
          notify-send "TODO"
        ;;
    '󰖳 open windows')
        docker start 5880dec702c4
        ;;
    '󰖳 shutdown windows')
        docker stop 5880dec702c4
        ;;
    esac
}
case "$1" in
  menu)execute_menu "$(call_menu | wofi --show dmenu -p "")" ;;
  power)call_power ;;
  *) execute_menu "$(call_menu | wofi --show dmenu -p "")" ;;
esac
