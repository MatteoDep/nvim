return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    version = '*',
    event = 'VimEnter',
    config = function()
      local function set_db(name, base_url, final_url)
        vim.b.db          = final_url
        vim.b.db_name     = name
        vim.b.db_base_url = base_url
        local dbname = final_url:match '.*/([^/?]+)'
        local label  = (base_url and dbname) and (name .. ' / ' .. dbname) or name
        vim.notify('db = ' .. label, vim.log.levels.INFO)
      end

      local function select_db_for_url(url, callback)
        local bootstrap = url:gsub('{{dbname}}', 'postgres')
        local names = {}
        vim.fn.jobstart({ 'psql', bootstrap, '-t', '-A', '-c', 'SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;' }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data then
              for _, line in ipairs(data) do
                local name = line:match '^%s*(.-)%s*$'
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

      local function select_connection(callback)
        local config_path = './connections.yaml'
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
                set_db(selected, url, final_url)
                if callback then callback(final_url) end
              end
            end)
          else
            set_db(selected, nil, url)
            if callback then callback(url) end
          end
        end)
      end

      local function select_db(cb)
        if not vim.b.db_base_url then
          vim.notify('No template URL; select a connection first', vim.log.levels.WARN)
          return
        end
        select_db_for_url(vim.b.db_base_url, function(final_url)
          if final_url then
            set_db(vim.b.db_name, vim.b.db_base_url, final_url)
            if cb then cb() end
          end
        end)
      end

      local function check_connection(cb)
        if not vim.b.db then
          select_connection(cb)
        else
          local label = vim.b.db_name or vim.b.db or '(none)'
          if vim.b.db_base_url then
            local dbname = vim.b.db:match '.*/([^/?]+)'
            if dbname then label = label .. ' / ' .. dbname end
          end
          local opts = { 'Run', 'Change connection', 'Abort' }
          if vim.b.db_base_url then table.insert(opts, 2, 'Change database') end
          vim.ui.select(opts, { prompt = label .. '> ' }, function(selected)
            if selected == 'Run' then
              cb()
            elseif selected == 'Change database' then
              select_db(cb)
            elseif selected == 'Change connection' then
              select_connection(cb)
            end
          end)
        end
      end

      local function execute_query()
        local mode = vim.api.nvim_get_mode().mode
        local in_visual = mode:find '^[vV\22]'
        if in_visual then vim.cmd 'normal! \27' end -- exit visual to save '< '>
        local pos = vim.api.nvim_win_get_cursor(0)

        -- Determine query range: for normal mode, temporarily select the paragraph
        if not in_visual then
          vim.cmd 'normal! vip'
          vim.cmd('normal! \27')
          vim.api.nvim_win_set_cursor(0, pos)
        end

        -- Highlight the query so the user can see what will run
        local ns = vim.api.nvim_create_namespace 'dadbod_preview'
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        local s = vim.api.nvim_buf_get_mark(0, '<')
        local e = vim.api.nvim_buf_get_mark(0, '>')
        vim.api.nvim_buf_set_extmark(0, ns, s[1] - 1, 0, {
          end_row = e[1] - 1,
          end_col = #vim.api.nvim_buf_get_lines(0, e[1] - 1, e[1], true)[1],
          hl_group = 'Visual',
        })

        local function clear_hl()
          vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        end

        -- Clear highlight on cursor move in case the user aborts
        vim.api.nvim_create_autocmd('CursorMoved', {
          buffer = 0,
          once = true,
          callback = clear_hl,
        })

        check_connection(function()
          clear_hl()
          vim.api.nvim_win_set_cursor(0, pos)
          if in_visual then
            vim.cmd 'normal! gv'
          else
            vim.cmd 'norm! vip'
          end
          vim.fn.feedkeys ':DB\r'
        end)
      end

      local function pg_import(url)
        if not url then
          check_connection(function(selected_url)
            if not selected_url then return end
            pg_import(selected_url)
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
      vim.keymap.set('n', '<leader>qd', select_db, { desc = '[d]atabase select' })
    end,
  },
}
