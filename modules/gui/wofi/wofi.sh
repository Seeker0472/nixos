# 打印菜单
# FIXME: add a more flexible way to add menu items
call_menu() {
    echo ' next wallpaper'
    [ "$(docker ps | grep windows)" ] && echo '󰖳 shutdown windows' || echo '󰖳 open windows'
}

call_power(){
    case $(echo -e '  Shutdown\n  Reboot\n 󰒲 Hibernate\n  Lock\n' | wofi --show dmenu) in
    "  Shutdown") poweroff ;;
    "  Reboot") reboot ;;
    " 󰒲 Hibernate") systemctl hibernate ;;
    "  Lock") hyprlock ;;
    esac
}

# 执行菜单
execute_menu() {
    case $1 in
    ' next wallpaper')
        wpaperctl next-wallpaper
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
