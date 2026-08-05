{ pkgs, ... }:
let
  version = "0.5.5";

  # Pinned version (not "latest") for reproducibility.
  src = pkgs.fetchurl {
    url = "https://github.com/block/buzz/releases/download/desktop-v0.5.5/Buzz_0.5.5_amd64.AppImage";
    hash = "sha256-zFHK2mN9YZcSHpXwgyisGcu/7t0+mSIotVLPQ4k+K90=";
  };

  # AppImage is stripped of infra libs and relies on the host GStreamer stack.
  gstPkgs = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];

  # nixpkgs GStreamer has no default system plugin path (Nix does not use /usr).
  # gstreamer's own plugins (coreelements) live in its "out" output, not the default "bin".
  gstPluginPath = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" (
    [ pkgs.gst_all_1.gstreamer.out ]
    ++ (with pkgs.gst_all_1; [ gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav ])
  );

  extracted = pkgs.appimageTools.extract { pname = "buzz"; inherit version src; };

  # The AppImage boots via: AppRun -> linuxdeploy GTK hook (force-sets
  # GST_PLUGIN_SYSTEM_PATH_1_0 to an empty in-bundle dir) -> usr/bin/buzz-desktop
  # (a shell launcher that then *unsets* the bundle-pointing GST_PLUGIN_* vars) ->
  # buzz-desktop.bin. That unset assumes a distro GStreamer with a compiled-in default
  # plugin path; nixpkgs GStreamer has none, so the app is left with zero plugins and
  # WebKit's media pipeline fails ("appsink not found"). No external env var survives
  # both the hook and the unset, so re-export our plugin path *inside* the launcher,
  # right before it execs the real binary.
  patched = pkgs.runCommand "buzz-${version}-patched" { } ''
    cp -r ${extracted} $out
    chmod -R u+w $out
    substituteInPlace $out/usr/bin/buzz-desktop \
      --replace 'exec -a "buzz-desktop"' \
        'export GST_PLUGIN_SYSTEM_PATH_1_0="${gstPluginPath}"
exec -a "buzz-desktop"'
  '';

  buzzApp = pkgs.appimageTools.wrapAppImage {
    pname = "buzz";
    inherit version;
    src = patched;
    # elfutils -> libelf.so.1, zstd -> libzstd.so.1, gst_all_1.* -> host GStreamer stack.
    extraPkgs = pkgs: [ pkgs.elfutils pkgs.zstd ] ++ gstPkgs;
  };

  # Outer wrapper for the remaining host-integration fixes (GStreamer is handled inside
  # the patched launcher above, since no outer env var survives the AppImage's hooks):
  #  * WEBKIT_DISABLE_SANDBOX=1 -> WebKitGTK otherwise spawns its web process in a nested
  #    bubblewrap sandbox that does not expose /nix/store or /run/opengl-driver.
  #  * GL: bundled Mesa cannot drive the NVIDIA GPU. The FHS already bind-mounts
  #    /run/opengl-driver, so point glvnd at the host's version-matched NVIDIA driver
  #    (no nixGL needed — that is for non-NixOS distros).
  buzz = pkgs.runCommand "buzz-${version}" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${buzzApp}/bin/buzz $out/bin/buzz \
      --set WEBKIT_DISABLE_SANDBOX 1 \
      --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
  '';

  buzzIcon = pkgs.runCommand "buzz-icon" { } ''
    install -Dm644 ${extracted}/buzz-desktop.png \
      $out/share/icons/hicolor/128x128/apps/buzz-desktop.png
  '';
in
{
  config = {
    home.packages = [ buzz buzzIcon ];

    xdg.desktopEntries.buzz = {
      name = "Buzz";
      genericName = "buzz";
      comment = "Buzz desktop app";
      # Bundled .desktop uses Exec=buzz-desktop, but the wrapper exposes the binary as "buzz".
      exec = "${buzz}/bin/buzz";
      icon = "buzz-desktop";
      terminal = false;
      type = "Application";
      startupNotify = true;
      mimeType = [ "x-scheme-handler/buzz" ];
      settings = {
        StartupWMClass = "buzz-desktop";
      };
    };
  };
}
