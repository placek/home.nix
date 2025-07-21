{ config
, ...
}:
{
  config = {
    services.clipcat.enable = true;
    services.clipcat.daemonSettings = {
      daemonize = true;
      watcher.enable_primary = false;
      watcher.enable_secondary = true;
      max_history = 100;
    };
  };
}
