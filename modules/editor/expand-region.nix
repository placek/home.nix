{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-expand-region
    ];

    editor.RCs = [
      ''
        vmap v     <Plug>(expand_region_expand)
        vmap <C-v> <Plug>(expand_region_shrink)
      ''
    ];
  };
}
