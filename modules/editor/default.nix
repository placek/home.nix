{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    projectsDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Projects";
      description = "A path to project directory.";
    };

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

  imports = [
    ./dirvish.nix
    ./tags.nix
    ./fugitive.nix
    ./ctrlp.nix
    ./ale.nix
    ./copilot.nix
    ./tertius.nix
    ./gitgutter.nix
    ./blameline.nix
    ./expand-region.nix
    ./syntax.nix
    ./todo.nix
  ];

  config = {
    home.sessionVariables.EDITOR = "vim";

    programs.fish.shellAliases.editor = "${config.editorExec} --servername (${config.vcsExec} remote get-url origin | awk -F'[:/]' '{print $(NF-1) \"/\" $(NF)}' | sed 's/\\.git$//')";

    programs.vim = let
      composeVimRC = pre: post: lib.strings.concatStringsSep "\n" (lib.lists.flatten [ pre config.editor.RCs post ]);
    in {
      enable = true;
      extraConfig = composeVimRC [
        (builtins.readFile ./settings.vim)
        (builtins.readFile ./helpers.vim)
      ] [
        (builtins.readFile ./mappings.vim)
        (builtins.readFile ./autocmd.vim)
      ];
    };
  };
}
