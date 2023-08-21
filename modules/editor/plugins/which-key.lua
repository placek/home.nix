local wk = require("which-key")
local cth = require("telescope.themes").get_cursor()

wk.register({
  ["<leader>/"]               = { "<cmd>lua require('telescope').extensions.file_browser.file_browser({ path = '%:p:h', grouped = true, hidden = true, respect_gitignore = true, display_stat = { date = true }})<cr>", "Browse files" },
  ["<leader><esc>"]           = { "<cmd>lua require('telescope.builtin').resume()<cr>",                   "Last search" },
  ["<leader><space>"]         = { "<cmd>lua require('telescope.builtin').builtin()<cr>",                  "Other search options" },
  ["<leader>\\"]              = { "<cmd>lua require('telescope.builtin').git_files({hidden=true})<cr>",   "Search git files only" },
  ["<leader>b"]               = { "<cmd>lua require('telescope.builtin').buffers()<cr>",                  "Search buffers" },
  ["<leader>t"]               = { "<cmd>lua require('telescope.builtin').tags()<cr>",                     "Search tags" },
  ["<leader>T"]               = { "<cmd>TodoTelescope<cr>",                                               "Search todos" },
  ["<leader>u"]               = { "<cmd>UndotreeToggle<cr>",                                              "Undo tree" },
  ["<leader>f"]               = { "<cmd>lua require('telescope.builtin').live_grep()<cr>",                "Grep files" },
  ["<leader>F"]               = { "<cmd>lua require('telescope.builtin').find_files()<cr>",               "Search files" },
  ["<leader>H"]               = { "<cmd>lua require('telescope.builtin').jumplist()<cr>",                 "Search history" },
  ["<leader>m"]               = { "<cmd>lua require('telescope.builtin').marks()<cr>",                    "Search marks" },
  ["<leader>r"]               = { "<cmd>lua require('telescope.builtin').registers()<cr>",                "Search registers" },

  ["<leader>h"]               = { name = "Git hunk" },
  ["<leader>hp"]              = { "<cmd>lua require('gitsigns').preview_hunk()<cr>",                      "Preview" },
  ["<leader>hr"]              = { "<cmd>lua require('gitsigns').reset_hunk()<cr>",                        "Reset" },
  ["<leader>hR"]              = { "<cmd>lua require('gitsigns').reset_buffer()<cr>",                      "Reset buffer" },
  ["<leader>hs"]              = { "<cmd>lua require('gitsigns').stage_hunk()<cr>",                        "Stage" },
  ["<leader>hS"]              = { "<cmd>lua require('gitsigns').stage_buffer()<cr>",                      "Stage buffer" },
  ["<leader>hu"]              = { "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",                   "Undo stage" },

  ["<leader>g"]               = { name = "Git" },
  ["<leader>gq"]              = { "<cmd>lua require('gitsigns').setqflist()<cr>",                         "Quickfix list" },
  ["<leader>gQ"]              = { "<cmd>lua require('gitsigns').setloclist()<cr>",                        "Local list" },

  ["K"]                       = { "<cmd>lua vim.lsp.buf.hover()<cr>",                                     "Show documentation" },
  ["<localleader>,"]          = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<cr>",       "Show diagnostic" },
  ["<localleader>a"]          = { "<cmd>lua vim.lsp.buf.code_action()<cr>",                               "Code actions" },
  ["<localleader>l"]          = { "<cmd>lua vim.lsp.codelens.refresh()<cr>",                              "Code lens" },
  ["<localleader>d"]          = { "<cmd>lua require('telescope.builtin').diagnostics()<cr>",              "Diagnostics" },
  ["<localleader>D"]          = { "<cmd>lua vim.diagnostic.setloclist({ open_loclist = false })<cr>",     "Diagnostics in loclist" },
  ["<localleader>f"]          = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>",                    "Format" },
  ["<localleader>i"]          = { "<cmd>lua require('telescope.builtin').lsp_incoming_calls(cth)<cr>",    "Incoming calls" },
  ["<localleader>o"]          = { "<cmd>lua require('telescope.builtin').lsp_outgoing_calls(cth)<cr>",    "Outgoing calls" },
  ["<localleader>r"]          = { "<cmd>lua require('telescope.builtin').lsp_references(cth)<cr>",        "References" },
  ["<localleader>s"]          = { "<cmd>AerialToggle<cr>",                                                "Symbols outline" },
  ["<localleader>S"]          = { "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>",    "Workspace symbols" },
  ["<localleader>I"]          = { "<cmd>LspInfo<cr>",                                                     "LSP info" },
  ["<localleader><space>"]    = { "<cmd>AV<cr>",                                                          "Alternative file (vertical)" }, -- FIXME: this is rails only!
  ["<localleader><M-space>"]  = { "<cmd>A<cr>",                                                           "Alternative file" }, -- FIXME: this is rails only!
}, { mode = "n" })

wk.register({
  ["<leader>a"]               = { name = "Tabularize" },
  ["<leader>a="]              = { "<cmd>Tab /^[^=]*\\zs=/l1c1l0<cr>",                                     "Align to '=' symbol" },
  ["<leader>a<bar>"]          = { "<cmd>Tab /|<cr>",                                                      "Align markdown table" },
  ["<leader>a:"]              = { "<cmd>Tab /^[^:]*\\zs:/l1c0l0<cr>",                                     "Align to first symbol" },
  ["<leader>as"]              = { "<cmd>Tab /::<cr>",                                                     "Align to '::'" },
  ["<leader>a;"]              = { "<cmd>Tab /^[^:]*:\zs/l1l0<cr>",                                        "Align to key in hash" },
  ["<leader>at"]              = { ":Tabularize /",                                                        "Custom alignment", silent = false },

  ["<leader>f"]               = { "\"sy:Telescope grep_string<cr><C-r>s",                                 "Search for phrase in project" },
  ["<leader>\\"]              = { "\"sy:Telescope git_files<cr><C-r>s",                                   "Search for phrase in git repo file names" },
  ["<leader>t"]               = { "\"sy:Telescope tags<cr><C-r>s",                                        "Search for tag symbol in project" },
  ["<leader>gG"]              = { "\"sy:G log -p -G <C-r>s<cr>",                                          "Pickaxe (fugitive)" }
}, { mode = "v" })
