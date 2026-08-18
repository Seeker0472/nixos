{ config, lib, ... }:
{
  config = lib.mkIf config.programs.yazi.enable {
    programs.yazi = {
      settings = {
        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
          image_alloc = 4096;
          image_bound = [
            15720
            8640
          ];
        };
      };
      shellWrapperName = "y";
    };
  };
}
