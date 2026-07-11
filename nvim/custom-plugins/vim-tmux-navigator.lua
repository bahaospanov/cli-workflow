return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
    'TmuxNavigatorProcessList',
  },
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<CR>', desc = 'window left'},
    { '<C-j>', '<cmd>TmuxNavigateDown<CR>', desc = 'window down' },
    { '<C-k>', '<cmd>TmuxNavigateUp<CR>', desc = 'window up' },
    { '<C-l>', '<cmd>TmuxNavigateRight<CR>', desc = 'window right' },
    { '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', desc = 'window previous' },
  },
}
