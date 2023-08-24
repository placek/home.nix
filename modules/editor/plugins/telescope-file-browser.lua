require("telescope").load_extension("file_browser")
require("telescope").setup {
  extensions = {
    file_browser = {
      hijack_netrw = true,
    },
  },
}
