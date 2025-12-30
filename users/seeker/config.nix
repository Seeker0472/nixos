{pkgs, ...}: {
  config = {
    seeker.home = {
      qq.enable = true;
      wechat.enable = true;
    };
    programs = {
      fish.enable = true;
      kitty.enable = true;
    };
  };
}
