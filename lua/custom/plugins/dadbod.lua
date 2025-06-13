return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    version = '*',
    event = 'VimEnter',
    config = function()
      local function get_conn_string()
        -- Get current buffer and cursor position
        local bufnr = vim.api.nvim_get_current_buf()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local pattern = '-- conn: '

        -- Search through lines above current position
        for line_num = current_line, 1, -1 do
          local line_content = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]

          -- Check if line exists and matches pattern
          if line_content and line_content:match(pattern) then
            return line_content:gsub(pattern, '')
          end
        end

        return ''
      end

      local function execute_query()
        local conn_string = get_conn_string()
        if not vim.api.nvim_get_mode().mode:find '^[vV\22]' then
          vim.cmd 'norm vip'
        end
        vim.fn.feedkeys(':DB ' .. conn_string)
      end

      local function set_db_url()
        vim.env.DATABASE_URL = get_conn_string()
      end

      vim.keymap.set('n', '<leader>qr', execute_query, { desc = '[R]un query' })
      vim.keymap.set('n', '<leader>qs', set_db_url, { desc = '[R]un query' })
    end,
  },
}
