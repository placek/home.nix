{ pkgs, glpkgs, settings, secrets, ... }:
{
  stateVersion = "23.05";
  username = settings.user.name;
  homeDirectory = settings.dirs.home;

  packages = import ./packages { inherit pkgs glpkgs settings; };

  sessionVariables = {
    EDITOR = "vim";
    SHELL = "fish";
    SSH_AUTH_SOCK = settings.key.sshAuthSocket;
    OPENAI_API_KEY = secrets.chatGPT;
  };
}
