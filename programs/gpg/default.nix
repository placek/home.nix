{ settings, ... }:
{
  enable = true;
  publicKeys = [
    {
      trust = 5;
      source = settings.key.pubKey;
    }
  ];
}
