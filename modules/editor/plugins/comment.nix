{ vimPlugins, runLua, ... }:
{
  plugin = vimPlugins.comment-nvim;
  config = runLua ''
    require("Comment").setup()
  '';
}
