{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.machine.programs.mihomo;
  deploySecrets = config.machine.secrets.deploy;

  inboundConfig =
    if cfg.share.enable then
      ''
        port: 7890
        socks-port: 7891
        allow-lan: true
        bind-address: "*"
        lan-allowed-ips:
          - 127.0.0.0/8
          - ::1/128
          - 10.0.0.0/8
          - 172.16.0.0/12
          - 192.168.0.0/16
          - 100.64.0.0/10
          - fc00::/7
      ''
    else
      ''
        port: 7890
        socks-port: 7891
        allow-lan: false
        bind-address: 127.0.0.1
      '';

  webConfig = optionalString cfg.web.enable ''
    external-ui: "${pkgs.metacubexd}"
  '';

  baseConfig = ''
    ${inboundConfig}

    mode: rule
    log-level: info
    external-controller: 127.0.0.1:9090
    ipv6: true
    keep-alive-interval: 30
    keep-alive-idle: 60
    find-process-mode: off
    tcp-concurrent: true
    unified-delay: true
    geodata-mode: true

    profile:
      store-selected: true
      store-fake-ip: true

    secret: "${config.sops.placeholder.mihomo_secret}"

    dns:
      enable: true
      cache-algorithm: arc
      respect-rules: true
      listen: 127.0.0.1:1053
      enhanced-mode: fake-ip
      fake-ip-range: 198.18.0.1/16

      default-nameserver:
        - 223.5.5.5
        - 119.29.29.29

      proxy-server-nameserver:
        - https://dns.alidns.com/dns-query

      fake-ip-filter:
        - '*.lan'
        - '*.local'
        - localhost

      nameserver-policy:
        "geosite:cn": [https://doh.pub/dns-query, https://dns.alidns.com/dns-query]
        "geosite:category-ads-all": rcode://success
        "geosite:gfw": [https://dns.google/dns-query, https://1.1.1.1/dns-query]

      nameserver:
        - https://doh.pub/dns-query
        - https://dns.alidns.com/dns-query

      fallback:
        - https://dns.google/dns-query
        - https://1.1.1.1/dns-query
        - tls://8.8.4.4
        - tls://1.1.1.1

      fallback-filter:
        geoip: true
        geoip-code: CN
        ipcidr:
          - 240.0.0.0/4

    sniffer:
      enable: true
      parse-pure-ip: true
      sniff:
        HTTP:
          ports: [80, 8080-8880]
          override-destination: true
        TLS:
          ports: [443, 8443]
        QUIC:
          ports: [443, 8443]
  '';

  tunConfig = ''
    tun:
      enable: true
      stack: system
      dns-hijack:
        - any:53
        - tcp://any:53
      auto-route: true
      auto-detect-interface: true
      strict-route: false
      route-exclude-address:
        - 127.0.0.0/8
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
        - 100.64.0.0/10
        - ::1/128
        - fc00::/7
        - fe80::/10
  '';

  providersAndRules = ''
    proxy-providers:
      airport_mojie:
        type: http
        url: "${config.sops.placeholder.airport_mojie_url}"
        path: ./providers/airport_a.yaml
        interval: 3600
        health-check: { enable: true, interval: 600, url: http://www.gstatic.com/generate_204 }

      airport_ikuuu:
        type: http
        url: "${config.sops.placeholder.airport_ikuuu_url}"
        path: ./providers/airport_c.yaml
        interval: 3600
        health-check: { enable: true, interval: 600, url: http://www.gstatic.com/generate_204 }

    proxy-groups:
      - name: "Auto-Fast-ALL"
        type: url-test
        url: 'http://www.gstatic.com/generate_204'
        interval: 300
        tolerance: 30
        use: [airport_mojie, airport_ikuuu]

      - name: "Auto-Fast-ikuuu"
        type: url-test
        url: 'http://www.gstatic.com/generate_204'
        interval: 300
        tolerance: 30
        exclude-filter: "免费|下载专用"
        use: [airport_ikuuu]

      - name: "Proxy"
        type: select
        proxies: ["Auto-Fast-ikuuu", "Auto-Fast-ALL", DIRECT]

    rules:
      - GEOSITE,category-ads-all,REJECT
      - DOMAIN,netbird.vps.seekerer.com,DIRECT
      - DOMAIN-SUFFIX,lan,DIRECT
      - DOMAIN-SUFFIX,local,DIRECT
      - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
      - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
      - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
      - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
      - IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
      - IP-CIDR6,::1/128,DIRECT,no-resolve
      - IP-CIDR6,fc00::/7,DIRECT,no-resolve
      - IP-CIDR6,fe80::/10,DIRECT,no-resolve
      - GEOSITE,cn,DIRECT
      - GEOIP,cn,DIRECT,no-resolve
      - MATCH,Proxy
  '';

in
{
  options.machine.programs = {
    mihomo = {
      enable = lib.mkEnableOption "mihomo";
      share.enable = lib.mkEnableOption "Mihomo proxy sharing";
      tun.enable = lib.mkEnableOption "mihomo tun";
      web.enable = lib.mkEnableOption "Mihomo web dashboard";
    };
  };
  config = mkIf (cfg.enable && deploySecrets) {
    networking.proxy = mkIf (cfg.enable && !cfg.tun.enable) {
      default = "http://localhost:7890";
      noProxy = "127.0.0.1,localhost,::1,.lan,.local";
    };

    networking.firewall = mkIf cfg.share.enable {
      allowedTCPPorts = [
        7890
        7891
      ];
      allowedUDPPorts = [ 7891 ];
    };

    sops.secrets = {
      airport_mojie_url.sopsFile = ./mihomo.secrets.yaml;
      airport_ikuuu_url.sopsFile = ./mihomo.secrets.yaml;
      mihomo_secret.sopsFile = ./mihomo.secrets.yaml;
    };

    sops.templates."mihomo-config.yaml" = {
      owner = "root";
      group = "root";
      mode = "0400";
      restartUnits = [ "mihomo.service" ];
      content = ''
        ${baseConfig}
        ${webConfig}
        ${optionalString cfg.tun.enable tunConfig}
        ${providersAndRules}
      '';
    };

    systemd.services.mihomo.environment = mkIf cfg.web.enable {
      SAFE_PATHS = "${pkgs.metacubexd}";
    };

    services.mihomo = {
      enable = true;
      configFile = config.sops.templates."mihomo-config.yaml".path;
      tunMode = cfg.tun.enable;
    };
  };
}
