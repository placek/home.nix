{ pkgs
, ...
}:
let
  luaFile = path: "luafile ${pkgs.writeText (builtins.baseNameOf path) (builtins.readFile path)}";
  xit-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "xit-vim";
    version = "v0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "sadotsoy";
      repo = "vim-xit";
      rev = "9b2c60b5da69670e1b8066c3e96bedbe6067699b";
      sha256 = "sha256-edAFJMxIpvkWqRoYB17E7jERyN40heFCBjpeliazRYg=";
    };
  };
in
with pkgs.vimPlugins; [
  { plugin = vim-fugitive; }
  { plugin = vim-dirvish; }
  { plugin = vim-eunuch; }

  { plugin = cmp-buffer; }
  { plugin = cmp-nvim-lsp; }
  { plugin = cmp-path; }
  { plugin = cmp-tabnine; }
  { plugin = cmp_luasnip; }
  { plugin = direnv-vim; }
  { plugin = dressing-nvim; }
  { plugin = friendly-snippets; }
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
  { plugin = vim-fish; }
  { plugin = vim-jinja; }
  { plugin = vim-nix; }
  { plugin = vim-polyglot; }
  { plugin = vim-rails; }
  { plugin = vim-rhubarb; }
  { plugin = vim-ruby; }
  { plugin = vim-signature; }
  { plugin = vim-surround; }
  { plugin = xit-vim; }

  { plugin = aerial-nvim; config = luaFile ./aerial.lua; }
  { plugin = comment-nvim; config = luaFile ./comment.lua; }
  { plugin = fidget-nvim; config = luaFile ./fidget.lua; }
  { plugin = gitsigns-nvim; config = luaFile ./gitsigns.lua; }
  { plugin = lualine-nvim; config = luaFile ./lualine.lua; }
  { plugin = nvim-cmp; config = luaFile ./cmp.lua; }
  { plugin = nvim-lspconfig; config = luaFile ./lspconfig.lua; }
  { plugin = telescope-file-browser-nvim; config = luaFile ./telescope-file-browser.lua; }
  { plugin = todo-comments-nvim; config = luaFile ./todo-comments.lua; }
  { plugin = undotree; config = builtins.readFile ./undotree.vim; }
  { plugin = vim-expand-region; config = builtins.readFile ./expand-region.vim; }
  { plugin = which-key-nvim; config = luaFile ./which-key.lua; }
]
