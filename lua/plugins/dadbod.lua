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
          if line_content and line_content:match(pattern) then return line_content:gsub(pattern, '') end
        end

        return ''
      end

      local function execute_query()
        local conn_string = get_conn_string()
        if not vim.api.nvim_get_mode().mode:find '^[vV\22]' then vim.cmd 'norm vip' end
        vim.fn.feedkeys(':DB ' .. conn_string)
      end

      local function set_db_url() vim.env.DATABASE_URL = get_conn_string() end

      local function pg_import(url)
        if not url or url == '' then
          url = get_conn_string()
        end
        if not url or url == '' then
          vim.ui.input({ prompt = 'PostgreSQL URL: ' }, function(input_url)
            if not input_url then return end
            pg_import(input_url)
          end)
          return
        end

        vim.ui.input({ prompt = 'Table name: ' }, function(table_name)
          if not table_name or table_name == '' then return end

          vim.ui.input({ prompt = 'CSV file path: ' }, function(file_name)
            if not file_name or file_name == '' then return end

            -- Expand ~ and env vars in file path
            file_name = vim.fn.expand(file_name)

            local script = vim.fn.stdpath 'config' .. '/scripts/pg_import.sh'
            local cmd = string.format('sh %s %q %q %q', script, url, table_name, file_name)

            vim.notify('Importing ' .. file_name .. ' into ' .. table_name .. ' using ' .. url .. '...', vim.log.levels.INFO)

            vim.fn.jobstart(cmd, {
              stdout_buffered = true,
              stderr_buffered = true,
              on_stdout = function(_, data)
                if data and #data > 0 then vim.notify(table.concat(data, '\n'), vim.log.levels.INFO) end
              end,
              on_stderr = function(_, data)
                if data and #data > 0 then vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR) end
              end,
              on_exit = function(_, code)
                if code == 0 then
                  vim.notify('Import completed successfully!', vim.log.levels.INFO)
                else
                  vim.notify('Import failed with exit code: ' .. code, vim.log.levels.ERROR)
                end
              end,
            })
          end)
        end)
      end

      -- Command: :PgImport [url]
      vim.api.nvim_create_user_command('PgImport', function(opts) pg_import(opts.args) end, { nargs = '?' })

      vim.keymap.set('n', '<leader>qr', execute_query, { desc = '[r]un query' })
      vim.keymap.set('n', '<leader>qs', set_db_url, { desc = '[s]et db for autocomplete' })
    end,
  },
}
