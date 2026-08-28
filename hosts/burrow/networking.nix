_: {
  networking = {
    nftables.enable = true;
    networkmanager.wifi.powersave = false;
    firewall.extraInputRules = ''
      ip saddr 192.168.3.0/24 tcp dport { 7890, 7891 } accept comment "Mihomo from home LAN"
      ip saddr 192.168.3.0/24 udp dport 7891 accept comment "Mihomo SOCKS UDP from home LAN"
    '';
  };
}
