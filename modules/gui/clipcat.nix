{ config
, ...
}:
{
  config = {
    services.clipcat = {
      enable = true;

      daemonSettings = {
        daemonize = true;
        max_history = 500;
        watcher = {
          enable_clipboard = true;
          enable_primary = false;
        };
      };
    };
  };
}
