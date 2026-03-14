{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.machine.programs.mihomo;

  baseConfig = ''
    port: 7890
    socks-port: 7891
    allow-lan: true
    mode: rule
    log-level: info
    external-controller: 0.0.0.0:9090
    ipv6: true
    keep-alive-interval: 30
    keep-alive-idle: 60
    find-process-mode: strict
    tcp-concurrent: true
    unified-delay: true
    geodata-mode: true
    global-client-fingerprint: random

    secret: "${config.sops.placeholder.mihomo_secret}"

    dns:
      enable: true
      cache-algorithm: arc
      respect-rules: true
      listen: 0.0.0.0:53
      enhanced-mode: fake-ip
      fake-ip-range: 198.18.0.1/16

      default-nameserver:
        - 223.5.5.5
        - 119.29.29.29

      proxy-server-nameserver:
        - https://dns.alidns.com/dns-query

      fake-ip-filter:
        - '*.lan'

      nameserver-policy:
      "geosite:cn": [https://doh.pub/dns-query, https://dns.alidns.com/dns-query]
      "geosite:category-ads-all": rcode://success # 广告域名直接拦截

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
        geosite:
          - gfw
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
      auto-route: true
      auto-detect-interface: true
  '';

  providersAndRules = ''
    proxy-providers:
      airport_mojie:
        type: http
        url: "${config.sops.placeholder.airport_mojie_url}"
        path: ./providers/airport_a.yaml
        interval: 3600
        health-check: { enable: true, interval: 600, url: http://www.gstatic.com/generate_204 }

      airport_dingji:
        type: http
        url: "${config.sops.placeholder.airport_dingji_url}"
        path: ./providers/airport_b.yaml
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
        use: [airport_mojie, airport_dingji, airport_ikuuu]

      - name: "Auto-Fast-ikuuu"
        type: url-test
        url: 'http://www.gstatic.com/generate_204'
        interval: 300
        tolerance: 30
        exclude-filter: "免费|下载专用"
        use: [airport_ikuuu]

      - name: "Gemini-Group"
        type: url-test
        url: 'http://www.gstatic.com/generate_204'
        interval: 300
        tolerance: 50
        filter: "(?i)(日本|新加坡)"
        exclude-filter: "免费|下载专用"
        # filter: "(?i)美国|日本|台湾|新加坡|Gemini"
        # filter: "(?i)Gemini"
        use: [airport_ikuuu]

      - name: "Proxy"
        type: select
        proxies: ["Auto-Fast-ikuuu", "Auto-Fast-ALL", "Gemini-Group", DIRECT]

    rules:
      - DOMAIN,gemini.google.com,Gemini-Group
      - DOMAIN-KEYWORD,generativelanguage,Gemini-Group
      - DOMAIN-SUFFIX,bard.google.com,Gemini-Group

      - GEOSITE,cn,DIRECT
      - GEOIP,cn,DIRECT
      - MATCH,Proxy
      - DOMAIN-KEYWORD,subscribe,DIRECT
      - GEOSITE,category-ads-all,REJECT
  '';

in
{
  options.machine.programs = {
    mihomo = {
      enable = lib.mkEnableOption "mihomo";
      tun.enable = lib.mkEnableOption "mihomo tun";
    };
  };
  config = mkIf cfg.enable {
    users.users.mihomo = {
      group = "mihomo";
      isSystemUser = true;
    };
    users.groups.mihomo = { };

    boot.kernel.sysctl = mkIf cfg.tun.enable {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    networking.proxy = mkIf (cfg.enable && !cfg.tun.enable) {
      default = "http://localhost:7890";
      noProxy = "127.0.0.1,localhost,internal.domain";
    };

    sops.secrets.airport_mojie_url = {
      sopsFile = ./mihomo.secrets.yaml;
    };
    sops.secrets.airport_dingji_url = {
      sopsFile = ./mihomo.secrets.yaml;
    };
    sops.secrets.airport_ikuuu_url = {
      sopsFile = ./mihomo.secrets.yaml;
    };
    sops.secrets.mihomo_secret = {
      sopsFile = ./mihomo.secrets.yaml;
    };

    sops.templates."mihomo-config.yaml" = {
      owner = "mihomo";
      group = "mihomo";
      restartUnits = [ "mihomo.service" ];
      content = ''
        ${baseConfig}
        ${optionalString cfg.tun.enable tunConfig}
        ${providersAndRules}
      '';
    };

    services.mihomo = {
      enable = true;
      configFile = config.sops.templates."mihomo-config.yaml".path;
      tunMode = cfg.tun.enable;
    };
  };
}
