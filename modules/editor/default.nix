{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    editorExec = mkOption {
      type = types.str;
      default = "${config.programs.vim.package}/bin/vim";
      description = "Editor executable.";
      readOnly = true;
    };

    difftoolExec = mkOption {
      type = types.str;
      default = "${config.programs.vim.package}/bin/vimdiff";
      description = "Diff editor executable.";
      readOnly = true;
    };

    editor.RCs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of vimrc configuration strings.";
    };
  };

  imports = lib.filesystem.listFilesRecursive ./plugins;

  config = {
    home.sessionVariables.EDITOR = "vim";

    programs.fish.shellAliases.editor = "${config.editorExec} --servername (${config.vcsExec} remote get-url origin | awk -F'[:/]' '{print $(NF-1) \"/\" $(NF)}' | sed 's/\\.git$//')";

    programs.vim = {
      enable = true;
      # compose the vimrc out of files from pre directory, plugin configurations
      # and files from post directory:
      extraConfig = lib.strings.concatStringsSep "\n" (lib.lists.flatten [
        (builtins.map builtins.readFile (lib.filesystem.listFilesRecursive ./pre))
        config.editor.RCs
        (builtins.map builtins.readFile (lib.filesystem.listFilesRecursive ./post))
      ]);
    };
  };
}
