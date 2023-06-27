let
  settings = import ../../settings;
  inherit (settings.defaults) editor;
in
{
  enable = true;
  settings = {
    git_protocol = "ssh";
    editor = editor;
    prompt = "enabled";
    aliases = {
      co = "pr checkout";
      pv = "pr view";
    };
  };
}
