{ config
, ...
}:
{
  config.programs.git.ignores = [
    "*.key"
    "*~"
    ".DS_Store"
    ".authorized_keys"
    ".local.*"
    ".remote.*"
    ".sw[op]"
    ".tags"
    "nohup.out"
  ];
}
