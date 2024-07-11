{ config
, ...
}:
{
  config = {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = config.editorExec;
        prompt = "enabled";
        aliases.current = "pr view --comments";
      };
    };

    programs.gh-dash.enable = true;
  };
}
