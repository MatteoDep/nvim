return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    version = '*',
    event = 'VimEnter',
    config = function()
      -- Every function below takes the buffer explicitly: pickers and the psql fetch are async,
      -- so the current buffer when a callback runs may not be the one the action started from.
      local function set_db(buf, name, base_url, final_url)
        if not vim.api.nvim_buf_is_valid(buf) then
          vim.notify('Buffer closed; connection not set', vim.log.levels.WARN)
          return false
        end
        vim.b[buf].db          = final_url
        vim.b[buf].db_name     = name
        vim.b[buf].db_base_url = base_url
        local dbname = final_url:match '.*/([^/?]+)'
        local label  = (base_url and dbname) and (name .. ' / ' .. dbname) or name
        vim.notify('db = ' .. label, vim.log.levels.INFO)
        return true
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

      -- Kept outside the nvim repo so credentials never get committed
      local config_home = vim.env.XDG_CONFIG_HOME
      if not config_home or config_home == '' then config_home = vim.fn.expand '~/.config' end
      local connections_path = config_home .. '/dadbod/connections.yaml'

      local function edit_connections()
        if not vim.uv.fs_stat(connections_path) then
          vim.fn.mkdir(vim.fn.fnamemodify(connections_path, ':h'), 'p', tonumber('700', 8))
          -- 'wx' + 600: create exclusively, never readable by others
          local fd, err = vim.uv.fs_open(connections_path, 'wx', tonumber('600', 8))
          if not fd then
            vim.notify('Could not create ' .. connections_path .. ': ' .. err, vim.log.levels.ERROR)
            return
          end
          vim.uv.fs_write(fd, table.concat({
            '# One "name: url" per line, no quoting. {{dbname}} = pick the database when connecting.',
            '# Saving syncs ~/.pg_service.conf (read-only for tools like pgro); end a line with "# rw" to allow writes.',
            '# local: postgresql://user:pass@localhost:5432/{{dbname}}  # rw',
            '',
          }, '\n'))
          vim.uv.fs_close(fd)
        end
        vim.cmd.edit(vim.fn.fnameescape(connections_path))
      end

      -- Generate ~/.pg_service.conf + per-connection passfiles (see scripts/dadbod_sync.lua),
      -- so tools can connect by name (`psql service=<name>`, `pgro`) without seeing passwords
      local sync_script = vim.fn.stdpath 'config' .. '/scripts/dadbod_sync.lua'
      local function sync_pgpass()
        vim.system({ vim.v.progpath, '--clean', '-l', sync_script }, { text = true }, function(res)
          local msg = vim.trim((res.stdout or '') .. (res.stderr or ''))
          local level = res.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
          vim.schedule(function() vim.notify(msg, level) end)
        end)
      end

      local function is_connections_file(path)
        if path == '' then return false end
        path = vim.fn.fnamemodify(path, ':p')
        return (vim.uv.fs_realpath(path) or path) == (vim.uv.fs_realpath(connections_path) or connections_path)
      end
      -- Keep plaintext credentials out of undo and swap files (turning 'swapfile' off
      -- also deletes an existing swap file, for buffers loaded before this config ran)
      local function protect(buf)
        if is_connections_file(vim.api.nvim_buf_get_name(buf)) then
          vim.bo[buf].undofile = false
          vim.bo[buf].swapfile = false
        end
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do protect(buf) end
      local group = vim.api.nvim_create_augroup('dadbod_connections', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre' }, {
        group = group,
        pattern = '*.yaml',
        callback = function(ev) protect(ev.buf) end,
      })
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = group,
        pattern = '*.yaml',
        callback = function(ev)
          if is_connections_file(ev.file) then sync_pgpass() end
        end,
      })

      local function select_connection(buf, callback)
        local ok, lines = pcall(vim.fn.readfile, connections_path)
        if not ok then
          vim.notify('Could not read ' .. connections_path .. ' (<leader>qe to create)', vim.log.levels.ERROR)
          return
        end

        local connections = {}
        local names = {}
        for _, line in ipairs(lines) do
          local name, url = line:match '^([^%s#:][^%s:]*):%s*(.+)$'
          if name and url then
            url = vim.trim((url:gsub('%s+#.*$', ''))) -- drop trailing ` # tags` (e.g. `# rw`, see dadbod_sync.lua)
            connections[name] = url
            table.insert(names, name)
          end
        end

        if #names == 0 then
          vim.notify('No connections found in ' .. connections_path, vim.log.levels.WARN)
          return
        end

        vim.ui.select(names, { prompt = 'Connection> ' }, function(selected)
          if not selected then return end
          local url = connections[selected]
          if url:find('{{dbname}}', 1, true) then
            select_db_for_url(url, function(final_url)
              if final_url and set_db(buf, selected, url, final_url) then
                if callback then callback(final_url) end
              end
            end)
          else
            if set_db(buf, selected, nil, url) and callback then callback(url) end
          end
        end)
      end

      local function select_db(buf, cb)
        local base_url, name = vim.b[buf].db_base_url, vim.b[buf].db_name
        if not base_url then
          vim.notify('No template URL; select a connection first', vim.log.levels.WARN)
          return
        end
        select_db_for_url(base_url, function(final_url)
          if final_url and set_db(buf, name, base_url, final_url) then
            if cb then cb(final_url) end
          end
        end)
      end

      -- Confirm (or change) the buffer's connection, then call cb(url)
      local function check_connection(buf, cb)
        local db, base_url = vim.b[buf].db, vim.b[buf].db_base_url
        if not db then
          select_connection(buf, cb)
        else
          local label = vim.b[buf].db_name or db
          if base_url then
            local dbname = db:match '.*/([^/?]+)'
            if dbname then label = label .. ' / ' .. dbname end
          end
          local opts = { 'Run', 'Change connection', 'Abort' }
          if base_url then table.insert(opts, 2, 'Change database') end
          vim.ui.select(opts, { prompt = label .. '> ' }, function(selected)
            if selected == 'Run' then
              cb(db)
            elseif selected == 'Change database' then
              select_db(buf, cb)
            elseif selected == 'Change connection' then
              select_connection(buf, cb)
            end
          end)
        end
      end

      local preview_ns = vim.api.nvim_create_namespace 'dadbod_preview'
      local preview_group = vim.api.nvim_create_augroup('dadbod_preview', { clear = true })

      local function execute_query()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        local in_visual = vim.api.nvim_get_mode().mode:find '^[vV\22]'

        -- Work out the line range once, here. Re-selecting it after the dialog is unreliable:
        -- smooth scrolling (snacks.scroll) can move the cursor while visual mode is active and
        -- shrink the selection (e.g. a DELETE running without its WHERE lines).
        if in_visual then
          vim.cmd 'normal! \27' -- leaving visual mode sets '< and '>
        else
          local view = vim.fn.winsaveview()
          vim.cmd 'normal! vip\27'
          vim.fn.winrestview(view)
        end
        local first = vim.api.nvim_buf_get_mark(buf, '<')[1]
        local last = vim.api.nvim_buf_get_mark(buf, '>')[1]
        -- Ex widens a range to cover closed folds, so do it here too: highlight = what runs
        if vim.fn.foldclosed(first) ~= -1 then first = vim.fn.foldclosed(first) end
        if vim.fn.foldclosedend(last) ~= -1 then last = vim.fn.foldclosedend(last) end
        local query = vim.api.nvim_buf_get_lines(buf, first - 1, last, true)
        if vim.trim(table.concat(query, '\n')) == '' then
          vim.notify('No query under cursor', vim.log.levels.WARN)
          return
        end

        -- Highlight the query so the user can see what will run
        local function clear_hl()
          if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, preview_ns, 0, -1) end
          vim.api.nvim_clear_autocmds { group = preview_group }
        end
        clear_hl()
        vim.api.nvim_buf_set_extmark(buf, preview_ns, first - 1, 0, {
          end_row = last - 1,
          end_col = #query[#query],
          hl_group = 'Visual',
        })
        -- Clear highlight on cursor move in case the user aborts
        vim.api.nvim_create_autocmd('CursorMoved', { group = preview_group, buffer = buf, once = true, callback = clear_hl })

        check_connection(buf, function()
          clear_hl()
          if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf) then
            vim.notify('Query window closed or showing another buffer; not running', vim.log.levels.WARN)
            return
          end
          if not vim.deep_equal(vim.api.nvim_buf_get_lines(buf, first - 1, last, false), query) then
            vim.notify('Query changed since it was selected; not running', vim.log.levels.WARN)
            return
          end
          vim.api.nvim_set_current_win(win)
          local ok, err = pcall(vim.cmd, ('%d,%dDB'):format(first, last))
          if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
        end)
      end

      local function pg_import(url)
        if not url then
          check_connection(vim.api.nvim_get_current_buf(), function(selected_url)
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

            vim.notify('Importing ' .. file_name .. ' into ' .. table_name .. '...', vim.log.levels.INFO)

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
      vim.api.nvim_create_user_command('PgImport', function(opts) pg_import(opts.args ~= '' and opts.args or nil) end, { nargs = '?' })
      vim.api.nvim_create_user_command('DBConnections', edit_connections, {})
      vim.api.nvim_create_user_command('DBSyncPgpass', sync_pgpass, {})
      vim.keymap.set({ 'n', 'v' }, '<leader>qr', execute_query, { desc = '[r]un query' })
      vim.keymap.set('n', '<leader>qs', function() select_connection(vim.api.nvim_get_current_buf()) end, { desc = '[s]elect connection' })
      vim.keymap.set('n', '<leader>qd', function() select_db(vim.api.nvim_get_current_buf()) end, { desc = '[d]atabase select' })
      vim.keymap.set('n', '<leader>qe', edit_connections, { desc = '[e]dit connections' })
    end,
  },
}
