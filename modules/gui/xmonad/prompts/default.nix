{ config
, lib
, pkgs
, ...
}:
{
  config = {
    xsession.windowManager.xmonad.libFiles = {
      "RunPrompt.hs" = import ./run_prompt.nix { inherit pkgs; };
      "ClipboardPrompt.hs" = import ./clipboard_prompt.nix { inherit pkgs; };
      "UDisksPrompt.hs" = import ./udisks_prompt.nix { inherit pkgs; };
      "UDisksDevice.hs" = import ./udisks_device.nix { inherit pkgs; };
      "PassCredential.hs" = import ./pass_credential.nix { inherit pkgs; };
      "PassPrompt.hs" = import ./pass_prompt.nix { inherit pkgs; };
    };
  };
}
