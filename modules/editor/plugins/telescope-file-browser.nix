{ vimPlugins, runLua, ... }:
{
    plugin = vimPlugins.telescope-file-browser-nvim;
    config = runLua ''
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("harpoon")
      require("telescope").setup {
        extensions = {
          file_browser = {
            hijack_netrw = true,
          },
        },
      }
    '';
  }
