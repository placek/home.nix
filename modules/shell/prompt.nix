{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "$directory"
          "$git_state"
          "$git_branch"
          "$git_commit"
          "$git_status"
          "$direnv"
          "$nix_shell"
          "$jobs"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];
        add_newline = false;
        directory = {
          disabled = false;
          fish_style_pwd_dir_length = 1;
          truncate_to_repo = false;
          style = "yellow bold";
        };
        direnv = {
          disabled = false;
          format = "[with direnv](bright-black) [$loaded/$allowed]($style) ";
          style = "white";
        };
        nix_shell = {
          disabled = false;
          format = "[via nix](bright-black) [$state]($style) ";
          unknown_msg = "unknown";
          style = "white";
        };
        git_state = {
          disabled = false;
          format = "[$state]($style) ";
          rebase = "rebasing";
          merge = "merging";
          revert = "reverting";
          cherry_pick = "cherry-picking";
          bisect = "bisecting";
          style = "white";
        };
        git_branch = {
          format = "[on git](bright-black) [$branch(:$remote_branch)]($style)";
          style = "white";
        };
        git_commit = {
          disabled = false;
          only_detached = false;
          format = "[\\($hash\\)]($style)";
          style = "bright-black";
        };
        git_status = {
          disabled = false;
          format = "[$all_status]($style) ";
          style = "white";
          stashed = "≡";
          modified = "*";
        };
        jobs = {
          disabled = false;
          symbol_threshold = 1;
          number_threshold = 1;
          format = "[with](bright-black) [$number$symbol ]($style) ";
          style = "white";
        };
        cmd_duration = {
          disabled = false;
          format = "[took](bright-black) [$duration]($style) ";
          style = "white";
        };
      };
    };
  };
}
