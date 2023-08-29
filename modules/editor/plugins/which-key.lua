local wk = require("which-key")
local cth = require("telescope.themes").get_cursor()

wk.register({
  ["\\/"]            = { "<cmd>lua require('telescope').extensions.file_browser.file_browser({ path = '%:p:h', grouped = true, hidden = true, respect_gitignore = true, display_stat = { date = true }})<cr>", "Browse files" },
  ["\\<esc>"]        = { "<cmd>lua require('telescope.builtin').resume()<cr>",                 "Last search" },
  ["\\<space>"]      = { "<cmd>lua require('telescope.builtin').builtin()<cr>",                "Other search options" },
  ["\\\\"]           = { "<cmd>lua require('telescope.builtin').git_files({hidden=true})<cr>", "Search git files only" },
  ["\\b"]            = { "<cmd>lua require('telescope.builtin').buffers()<cr>",                "Search buffers" },
  ["\\t"]            = { "<cmd>lua require('telescope.builtin').tags()<cr>",                   "Search tags" },
  ["\\T"]            = { "<cmd>TodoTelescope<cr>",                                             "Search todos" },
  ["\\u"]            = { "<cmd>UndotreeToggle<cr>",                                            "Undo tree" },
  ["\\f"]            = { "<cmd>lua require('telescope.builtin').live_grep()<cr>",              "Grep files" },
  ["\\F"]            = { "<cmd>lua require('telescope.builtin').find_files()<cr>",             "Search files" },
  ["\\H"]            = { "<cmd>lua require('telescope.builtin').jumplist()<cr>",               "Search history" },
  ["\\m"]            = { "<cmd>lua require('telescope.builtin').marks()<cr>",                  "Search marks" },
  ["\\r"]            = { "<cmd>lua require('telescope.builtin').registers()<cr>",              "Search registers" },

  ["<localleader>l"] = { "<cmd>lua vim.lsp.codelens.refresh()<cr>",                            "Code lens" },
  ["<localleader>f"] = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>",                  "Format" },
  ["<localleader>i"] = { "<cmd>lua require('telescope.builtin').lsp_incoming_calls(cth)<cr>",  "Incoming calls" },
  ["<localleader>o"] = { "<cmd>lua require('telescope.builtin').lsp_outgoing_calls(cth)<cr>",  "Outgoing calls" },
  ["<localleader>s"] = { "<cmd>AerialToggle<cr>",                                              "Symbols outline" },
  ["<localleader>S"] = { "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>",  "Workspace symbols" },
}, { mode = "n" })

wk.register({
  ["\\f"]            = { "\"sy:Telescope grep_string<cr><C-r>s",                               "Search for phrase in project" },
  ["\\\\"]           = { "\"sy:Telescope git_files<cr><C-r>s",                                 "Search for phrase in git repo file names" },
  ["\\t"]            = { "\"sy:Telescope tags<cr><C-r>s",                                      "Search for tag symbol in project" },
}, { mode = "v" })
