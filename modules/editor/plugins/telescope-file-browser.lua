require("telescope").load_extension("file_browser")
require("telescope").setup {
  extensions = {
    file_browser = {
      hijack_netrw = true,
    },
  },
}

better_git_commits = function()
  require("telescope.builtin").git_commits({
    attach_mappings = function(_, map)
      map("i", "<M-f>", function(_)
        local commit = require("telescope.actions.state").get_selected_entry().value
        local files = vim.split(vim.api.nvim_exec("G diff-tree --no-commit-id --name-only " .. commit .. " -r", true), '\n')
        require("telescope.pickers").new({}, {
          prompt_title = commit .. " commit files",
          finder = require("telescope.finders").new_table({ results = files }),
          sorter = require("telescope.config").values.generic_sorter(),
          previewer = require("telescope.previewers").new_buffer_previewer {
            define_preview = function(self, entry, status)
              -- Execute another command using the highlighted entry
              return require('telescope.previewers.utils').job_maker(
                { "cat", entry.value },
                self.state.bufnr,
                {
                  callback = function(bufnr, content)
                    if content ~= nil then
                      require('telescope.previewers.utils').regex_highlighter(bufnr)
                    end
                  end,
                }
              )
            end
          },
        }):find()
      end)
      map("i", "<cr>", function(_)
        local commit = require("telescope.actions.state").get_selected_entry().value
        vim.api.nvim_exec("G show " .. commit, true)
      end)
      return true
    end
  })
end
