{ pkgs, ... }:
let
  runLua = script: ''
    lua << EOF
    ${script}
    EOF
  '';
in
with pkgs.vimPlugins; [
  cmp-buffer
  cmp-nvim-lsp
  cmp-path
  cmp-tabnine
  cmp_luasnip
  direnv-vim
  dressing-nvim
  friendly-snippets
  harpoon
  haskell-vim
  luasnip
  nvim-lint
  nvim-treesitter
  tabular
  targets-vim
  telescope-fzy-native-nvim
  telescope-nvim
  todo-comments-nvim
  undotree
  vim-css-color
  vim-expand-region
  vim-fish
  vim-jinja
  vim-nix
  vim-ruby
  vim-rails
  vim-signature
  vim-surround

  (import ./aerial.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./cmp.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./comment.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./fidget.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./fugitive.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./gitsigns.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./lspconfig.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./lualine.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./telescope-file-browser.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./which-key.nix { inherit (pkgs) vimPlugins; inherit runLua; })
  (import ./chat-gpt.nix { inherit (pkgs) vimPlugins; inherit runLua; })
]
