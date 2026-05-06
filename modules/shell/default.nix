{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    shellExec = mkOption {
      type = types.str;
      default = "${pkgs.fish}/bin/fish";
      description = "Shell executable.";
      readOnly = true;
    };
  };

  imports = [
    ./prompt.nix
    ./fish.nix
    ./bash.nix
  ];

  config = {
    programs.lsd.enable = true;
    programs.carapace.enable = true;
    programs.mcfly.enable = true;
    programs.zoxide.enable = true;
  };
}
