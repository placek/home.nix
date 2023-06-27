{ pkgs, glpkgs, settings, secrets, ... }:
{
  stateVersion = "23.05";
  username = settings.user.name;
  homeDirectory = settings.dirs.home;

  packages = import ./packages { inherit pkgs glpkgs settings; };

  sessionVariables = {
    OPENAI_API_KEY = secrets.chatGPT;
  };
}
