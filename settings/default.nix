{
  # user settings
  user = {
    fullName = "Paweł Placzyński";
    email = "placzynski.pawel@gmail.com";
    name = "placek";
  };

  # encription settings
  key = {
    sign = "1D95E554315BC053";
    ssh = "D75BFE7D95CB0CB4B3FE0B64E624230BAE5B5299";
    store = "/home/placek/.password-store";
    pubKey = ./placek.asc;
    # FIXME: the SSH_AUTH_SOCK should point to pinned data
    sshAuthSocket = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  # directories
  dirs = rec{
    home = "/home/placek";
    downloads = "${home}/Pobrane";
    projects = "${home}/Projekty";
  };

  # font settings
  font = {
    name = "Iosevka";
    fullName = "Iosevka Nerd Font";
    size = rec {
      int = 12;
      pt = "${builtins.toString int}pt";
    };
  };

  # color scheme
  colors = import ./colors.nix;

  # defaults
  defaults = {
    terminal = {
      name = "kitty";
      executable = "kitty-gl";
    };
  };
}
