{ config, settings, ... }:
{
  gpg-agent = import ./gpg-agent { inherit settings; };
  mbsync = import ./mbsync { inherit config; };
}
