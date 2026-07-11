local M = {}

function M.list()
  local finders = require 'telescope.finders'
  local pickers = require 'telescope.pickers'
  local entry_display = require 'telescope.pickers.entry_display'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local config = require('bookmarks.config').config
  local utils = require 'telescope.utils'

  local function get_text(annotation)
    local pref = string.sub(annotation, 1, 2)
    local ret = config.keywords[pref]
    if ret == nil then
      ret = config.signs.ann.text .. ' '
    end
    return ret .. annotation
  end

  local function build_marklist()
    local allmarks = config.cache.data
    local marklist = {}
    for k, ma in pairs(allmarks) do
      for l, v in pairs(ma) do
        table.insert(marklist, {
          filename = k,
          lnum = tonumber(l),
          text = v.a and get_text(v.a) or v.m,
        })
      end
    end
    return marklist
  end

  local display = function(entry)
    local displayer = entry_display.create {
      separator = '▏',
      items = {
        { width = 5 },
        { width = 30 },
        { remaining = true },
      },
    }
    local line_info = { entry.lnum, 'TelescopeResultsLineNr' }
    return displayer {
      line_info,
      entry.text:gsub('.* | ', ''),
      utils.path_smart(entry.filename),
    }
  end

  local function entry_maker(entry)
    return {
      valid = true,
      value = entry,
      display = display,
      ordinal = entry.filename .. entry.text,
      filename = entry.filename,
      lnum = entry.lnum,
      col = 1,
      text = entry.text,
    }
  end

  local function open_picker()
    pickers
      .new({}, {
        prompt_title = 'bookmarks (<C-d> delete)',
        finder = finders.new_table {
          results = build_marklist(),
          entry_maker = entry_maker,
        },
        sorter = conf.generic_sorter {},
        previewer = conf.qflist_previewer {},
        attach_mappings = function(prompt_bufnr, map)
          local function delete_bookmark()
            local entry = action_state.get_selected_entry()
            if not entry then
              return
            end

            local picker = action_state.get_current_picker(prompt_bufnr)
            local original_win = picker.original_win_id

            actions.close(prompt_bufnr)

            if not original_win or not vim.api.nvim_win_is_valid(original_win) then
              vim.notify('bookmarks: could not find original window to delete from', vim.log.levels.ERROR)
              return
            end

            local bufnr = vim.fn.bufadd(entry.filename)
            vim.fn.bufload(bufnr)

            local original_buf = vim.api.nvim_win_get_buf(original_win)
            local original_cursor = vim.api.nvim_win_get_cursor(original_win)

            vim.api.nvim_win_set_buf(original_win, bufnr)
            vim.api.nvim_win_set_cursor(original_win, { entry.lnum, 0 })
            require('bookmarks').bookmark_toggle()

            vim.api.nvim_win_set_buf(original_win, original_buf)
            pcall(vim.api.nvim_win_set_cursor, original_win, original_cursor)

            open_picker()
          end

          map('n', '<C-d>', delete_bookmark)
          map('i', '<C-d>', delete_bookmark)

          return true
        end,
      })
      :find()
  end

  open_picker()
end

return M
