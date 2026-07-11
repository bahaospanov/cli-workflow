return {
  'tomasky/bookmarks.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-telescope/telescope.nvim' },
  opts = {},
  keys = {
    { '<leader>bm', function() require('bookmarks').bookmark_toggle() end, desc = '[B]ook[m]ark toggle' },
    { '<leader>ba', function() require('bookmarks').bookmark_ann() end, desc = '[B]ookmark [A]nnotate' },
    { '<leader>bn', function() require('bookmarks').bookmark_next() end, desc = '[B]ookmark [N]ext' },
    { '<leader>bp', function() require('bookmarks').bookmark_prev() end, desc = '[B]ookmark [P]rev' },
    { '<leader>bc', function() require('bookmarks').bookmark_clean() end, desc = '[B]ookmark [C]lean (buffer)' },
    { '<leader>bl', function() require('custom.bookmarks_picker').list() end, desc = '[B]ookmark [L]ist (all)' },
  },
  config = function(_, opts)
    -- The plugin's own load/save (actions.loadBookmarks/saveBookmarks) are async,
    -- libuv-callback-based. That race lets a save-on-quit go unwritten, or (if
    -- something else re-reads disk mid-session) stomp in-memory changes with
    -- stale disk data. Replace both with synchronous versions so config.cache
    -- is always the single source of truth in memory, flushed reliably on quit.
    local actions = require 'bookmarks.actions'
    local bmconfig = require('bookmarks.config').config

    actions.loadBookmarks = function()
      if vim.fn.filereadable(bmconfig.save_file) == 1 then
        local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(bmconfig.save_file), '\n'))
        if ok and decoded then bmconfig.cache = decoded end
      end
    end

    actions.saveBookmarks = function()
      vim.fn.writefile({ vim.json.encode(bmconfig.cache) }, bmconfig.save_file)
    end

    require('bookmarks').setup(opts)

    -- The plugin's own initial load (via M.attach, on VimEnter) runs inside a
    -- coroutine that yields through vim.schedule before calling loadBookmarks,
    -- deferring the actual read to the next event-loop tick even though the
    -- read itself is now synchronous. That leaves a window where opening the
    -- picker immediately shows an empty/stale list until that tick fires (the
    -- "works on the second open" symptom). Load immediately here instead of
    -- waiting on that deferred path.
    actions.loadBookmarks()

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function() require('bookmarks').saveBookmarks() end,
    })
  end,
}
