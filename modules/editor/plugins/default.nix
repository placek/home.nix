{ pkgs, ... }:
let
  luaFile = path: "luafile ${pkgs.writeText (builtins.baseNameOf path) (builtins.readFile path)}";
in
with pkgs.vimPlugins; [
  { plugin = cmp-buffer; }
  { plugin = cmp-nvim-lsp; }
  { plugin = cmp-path; }
  { plugin = cmp-tabnine; }
  { plugin = cmp_luasnip; }
  { plugin = direnv-vim; }
  { plugin = dressing-nvim; }
  { plugin = friendly-snippets; }
  { plugin = harpoon; }
  { plugin = haskell-vim; }
  { plugin = luasnip; }
  { plugin = nvim-dap; }
  { plugin = nvim-lint; }
  { plugin = nvim-treesitter; }
  { plugin = tabular; }
  { plugin = targets-vim; }
  { plugin = telescope-fzy-native-nvim; }
  { plugin = telescope-nvim; }
  { plugin = vim-abolish; }
  { plugin = vim-css-color; }
  { plugin = vim-dirvish; }
  { plugin = vim-fish; }
  { plugin = vim-jinja; }
  { plugin = vim-nix; }
  { plugin = vim-polyglot; }
  { plugin = vim-rails; }
  { plugin = vim-rhubarb; }
  { plugin = vim-ruby; }
  { plugin = vim-signature; }
  { plugin = vim-surround; }

  { plugin = undotree; config = builtins.readFile ./undotree.vim; }
  { plugin = vim-expand-region; config = builtins.readFile ./expand-region.vim; }

  { plugin = ChatGPT-nvim; config = luaFile ./chat-gpt.lua; }
  { plugin = aerial-nvim; config = luaFile ./aerial.lua; }
  { plugin = comment-nvim; config = luaFile ./comment.lua; }
  { plugin = fidget-nvim; config = luaFile ./fidget.lua; }
  { plugin = gitsigns-nvim; config = luaFile ./gitsigns.lua; }
  { plugin = lualine-nvim; config = luaFile ./lualine.lua; }
  { plugin = nvim-cmp; config = luaFile ./cmp.lua; }
  { plugin = nvim-lspconfig; config = luaFile ./lspconfig.lua; }
  { plugin = telescope-file-browser-nvim; config = luaFile ./telescope-file-browser.lua; }
  { plugin = todo-comments-nvim; config = luaFile ./todo-comments.lua; }
  { plugin = vim-fugitive; config = luaFile ./fugitive.lua; }
  { plugin = which-key-nvim; config = luaFile ./which-key.lua; }
]
