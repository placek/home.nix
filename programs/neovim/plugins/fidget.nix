{ vimPlugins, runLua, ... }:
{
  plugin = vimPlugins.fidget-nvim;
  config = runLua ''
    require("fidget").setup {
      text = {
        spinner = "dots",
      },
      timer = {
        fidget_decay = 999999,
      },
    }
  '';
}
