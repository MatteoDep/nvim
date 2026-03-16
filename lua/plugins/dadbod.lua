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

      local function select_db_for_url(url, callback)
        local bootstrap = url:gsub('{{dbname}}', 'postgres')
        local names = {}
        vim.fn.jobstart({ 'psql', bootstrap, '-t', '-A', '-c', 'SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;' }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data then
              for _, line in ipairs(data) do
                local name = line:match('^%s*(.-)%s*$')
                if name and name ~= '' then table.insert(names, name) end
              end
            end
          end,
          on_exit = function(_, code)
            vim.schedule(function()
              if code ~= 0 or #names == 0 then
                vim.notify('Could not fetch databases (exit ' .. code .. ')', vim.log.levels.ERROR)
                callback(nil)
                return
              end
              vim.ui.select(names, { prompt = 'Database> ' }, function(dbname)
                if dbname then
                  callback(url:gsub('{{dbname}}', dbname))
                else
                  callback(nil)
                end
              end)
            end)
          end,
        })
      end

      local function select_connection()
        local config_path = vim.fn.stdpath 'config' .. '/connections.yaml'
        local ok, lines = pcall(vim.fn.readfile, config_path)
        if not ok then
          vim.notify('Could not read ' .. config_path, vim.log.levels.ERROR)
          return
        end

        local connections = {}
        local names = {}
        for _, line in ipairs(lines) do
          local name, url = line:match '^(%S+):%s*(.+)$'
          if name and url then
            connections[name] = url
            table.insert(names, name)
          end
        end

        if #names == 0 then
          vim.notify('No connections found in connections.yaml', vim.log.levels.WARN)
          return
        end

        vim.ui.select(names, { prompt = 'Connection> ' }, function(selected)
          if not selected then return end
          local url = connections[selected]
          if url:find('{{dbname}}', 1, true) then
            select_db_for_url(url, function(final_url)
              if final_url then
                vim.b.db = final_url
                vim.notify('b:db = ' .. selected .. ' / ' .. (final_url:match('/([^/?]+)%??') or '?'), vim.log.levels.INFO)
              end
            end)
          else
            vim.b.db = url
            vim.notify('b:db = ' .. selected, vim.log.levels.INFO)
          end
        end)
      end

      local function execute_query()
        if not vim.b.db then select_connection() end
        local mode = vim.api.nvim_get_mode().mode
        local in_visual = mode:find '^[vV\22]'
        if in_visual then vim.cmd 'normal! \27' end -- exit visual to save '< '>
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.ui.select({ 'Run', 'Change connection', 'Abort' }, { prompt = 'b:db = ' .. (vim.b.db or '(none)') }, function(selected)
          if selected == 'Change connection' then select_connection()
          elseif selected == 'Abort' or not selected then return end
          vim.api.nvim_win_set_cursor(0, pos)
          if in_visual then
            vim.cmd 'normal! gv'
          else
            vim.cmd 'norm! vip'
          end
          vim.fn.feedkeys(':DB\r')
        end)
      end


      local function pg_import(url)
        if not url or url == '' then url = get_conn_string() end
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
      vim.keymap.set({ 'n', 'v' }, '<leader>qr', execute_query, { desc = '[r]un query' })
      vim.keymap.set('n', '<leader>qs', select_connection, { desc = '[s]elect connection' })
    end,
  },
}
