{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # --- Web ---
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";

      # --- Web ---
      # "text/html" = "firefox.desktop";
      # "x-scheme-handler/http" = "firefox.desktop";
      # "x-scheme-handler/https" = "firefox.desktop";
      # "x-scheme-handler/about" = "firefox.desktop";
      # "x-scheme-handler/unknown" = "firefox.desktop";

      # --- PDF ---
      "application/pdf" = "org.gnome.Evince.desktop";

      # --- Word,PPT,Excel ---
      # Word (.doc, .docx)
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        "libreoffice-writer.desktop";

      # Excel (.xls, .xlsx)
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";

      # PowerPoint (.ppt, .pptx)
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
        "libreoffice-impress.desktop";

      # --- Picture ---
      "image/jpeg" = "viewnior.desktop"; # JPG, JPEG
      "image/png" = "viewnior.desktop"; # PNG
      "image/gif" = "viewnior.desktop"; # GIF
      "image/bmp" = "viewnior.desktop"; # BMP
      "image/tiff" = "viewnior.desktop"; # TIFF
      "image/webp" = "viewnior.desktop"; # WebP

      # --- Video ---
      "video/mp4" = "mpv.desktop";
      "video/mpv" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/avi" = "mpv.desktop";

      # --- Audio ---
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/mp3" = "mpv.desktop";
    };
  };
}
