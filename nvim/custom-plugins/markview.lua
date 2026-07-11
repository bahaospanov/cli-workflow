return {
    'OXY2DEV/markview.nvim',
    lazy = false,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        require('markview').setup {}
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'markdown',
            callback = function()
                vim.opt_local.indentexpr = ''
            end,
        })
    end,
}