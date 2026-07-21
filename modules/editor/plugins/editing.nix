{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.targets-vim        # richer pair/quote/argument text objects (ci( ci, ci")
      pkgs.vimPlugins.vim-indent-object  # indentation text objects (ai/ii) for nix, yaml, elixir
      pkgs.vimPlugins.vim-matchup        # extend % to if/endif, def/end, tags; better matchparen
      pkgs.vimPlugins.traces-vim         # live preview for :s, :g, :sort ranges (Vim's inccommand)
    ];
  };
}
