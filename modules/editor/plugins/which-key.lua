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

  ["<localleader>l"]          = { "<cmd>lua vim.lsp.codelens.refresh()<cr>",                              "Code lens" },
  ["<localleader>f"]          = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>",                    "Format" },
  ["<localleader>i"]          = { "<cmd>lua require('telescope.builtin').lsp_incoming_calls(cth)<cr>",    "Incoming calls" },
  ["<localleader>o"]          = { "<cmd>lua require('telescope.builtin').lsp_outgoing_calls(cth)<cr>",    "Outgoing calls" },
  ["<localleader>s"]          = { "<cmd>AerialToggle<cr>",                                                "Symbols outline" },
  ["<localleader>S"]          = { "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>",    "Workspace symbols" },
}, { mode = "n" })

wk.register({
  ["<leader>f"]               = { "\"sy:Telescope grep_string<cr><C-r>s",                                 "Search for phrase in project" },
  ["<leader>\\"]              = { "\"sy:Telescope git_files<cr><C-r>s",                                   "Search for phrase in git repo file names" },
  ["<leader>t"]               = { "\"sy:Telescope tags<cr><C-r>s",                                        "Search for tag symbol in project" },
}, { mode = "v" })
