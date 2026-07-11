return {
    '3rd/image.nvim',
    -- Do NOT let the plugin build luarocks/magick itself; use the ImageMagick CLI.
    build = false,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    opts = {
        backend = 'kitty', -- Ghostty speaks the Kitty graphics protocol
        processor = 'magick_cli', -- shells out to ImageMagick CLI; avoids the magick luarock
        integrations = {
            markdown = {
                enabled = true,
                only_render_image_at_cursor = false,
                filetypes = { 'markdown', 'vimwiki' },
            },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = true, -- clear images when floats/popups overlap
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = true,
    },
}
