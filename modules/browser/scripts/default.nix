{ config
, lib
, ...
}:
let
  js_files = builtins.map (file: {
    "qutebrowser/greasemonkey/${builtins.baseNameOf file}".source = file;
  }) (lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt "js") ./.));
in
{
#   config.xdg.configFile = lib.mkMerge js_files;
}
