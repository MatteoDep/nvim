-- Markdown preview via glow in Snacks floating terminal
vim.api.nvim_create_user_command('Glow', function()
  Snacks.terminal.open('glow --style dark --pager ' .. vim.fn.shellescape(vim.fn.expand '%:p'), {
    win = { position = 'float', width = 0.8, height = 0.8 },
    interactive = true,
  })
end, {})

vim.keymap.set('n', '<leader>mp', '<cmd>Glow<cr>', { desc = 'Markdown Preview (Glow)' })

return {}