{ pass, ... }:
let
  settings = import ../../settings;
in
{
  enable = true;
  package = pass.withExtensions (exts: [ exts.pass-otp ]);
  settings = {
    PASSWORD_STORE_DIR = settings.key.store;
  };
}
