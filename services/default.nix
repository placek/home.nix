{ config, settings, ... }:
{
  mbsync = import ./mbsync { inherit config; };
}
