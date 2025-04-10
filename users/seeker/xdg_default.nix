{ pkgs, ... }: {
  # TODO!
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # --- Web ---
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";

      # --- PDF ---
      "application/pdf" = "org.gnome.Evince.desktop";

      # --- Picture ---
      "image/jpeg" = "viewnior.desktop"; # JPG, JPEG
      "image/png"  = "viewnior.desktop"; # PNG
      "image/gif"  = "viewnior.desktop"; # GIF
      "image/bmp"  = "viewnior.desktop"; # BMP
      "image/tiff" = "viewnior.desktop"; # TIFF
      "image/webp" = "viewnior.desktop"; # WebP
    };
  };

}
