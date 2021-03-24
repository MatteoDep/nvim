-- DAP ------------------------------------------------------------------------
local dap = require('dap')
dap.adapters.python = {
  type = 'executable';
  -- installed in system python
  command = '/usr/bin/python';
  args = { '-m', 'debugpy.adapter' };
}

local dap = require('dap')

-- python
dap.configurations.python = {
  {
    -- Options required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options for python-dap
    program = "${file}"; -- current file
    -- interpreter used to launch application
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      local env = os.getenv("VIRTUAL_ENV")
      if (env ~= nil) then
        return env .. '/bin/python'
      elseif vim.fn.executable(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
      elseif vim.fn.executable(cwd .. '/../venv/bin/python') then
        return cwd .. '/../venv/bin/python'
      elseif vim.fn.executable(cwd .. '/../.venv/bin/python') then
        return cwd .. '/../.venv/bin/python'
      elseif vim.fn.executable(cwd .. '/env/bin/python') then
        return cwd .. '/env/bin/python'
      elseif vim.fn.executable(cwd .. '/.env/bin/python') then
        return cwd .. '/.env/bin/python'
      elseif vim.fn.executable(cwd .. '/../env/bin/python') then
        return cwd .. '/../env/bin/python'
      elseif vim.fn.executable(cwd .. '/../.env/bin/python') then
        return cwd .. '/../.env/bin/python'
      else
        return '/usr/bin/python'
      end
    end;
  },
}
