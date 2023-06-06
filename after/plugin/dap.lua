local dap = require('dap')
local dapui = require("dapui")

vim.fn.sign_define('DapBreakpoint', {text=''})
vim.fn.sign_define('DapBreakpointCondition', {text=''})
vim.fn.sign_define('DapLogPoint', {text=''})
vim.fn.sign_define('DapStopped', {text='→'})
vim.fn.sign_define('DapBreakpointRejected', {text=''})

dapui.setup()
require("nvim-dap-virtual-text").setup({})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set('n', '<leader>dc', dap.continue, {desc="[d]ap [c]ontinue"})
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, {desc="[d]ap toggle [b]reakpoint"})
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "[d]ap conditional [B]reakpoint" })
vim.keymap.set('n', '<leader>dl', function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "[d]ap [L]og point" })
vim.keymap.set('n', '<leader>dl', dap.step_into, {desc="[d]ap step into"})
vim.keymap.set('n', '<leader>dj', dap.step_over, {desc="[d]ap step over"})
vim.keymap.set('n', '<leader>dh', dap.step_out, {desc="[d]ap step out"})
vim.keymap.set('n', '<leader>dr', dap.repl.open, {desc="[d]ap repl open"})
vim.keymap.set('n', '<leader>du', dapui.toggle, {desc="[d]ap ui toggle"})

-- variables
local bindir = "bin"
local ext = ""
if vim.fn.has("win32") == 1 then
  bindir = "Scripts"
  ext = ".exe"
end

-- csharp
dap.adapters.cs = {
  type = 'executable',
  command = vim.fn.stdpath('data').."/mason/packages/netcoredbg/netcoredbg/netcoredbg"..ext,
  args = {'--interpreter=vscode'}
}

require('dap.ext.vscode').load_launchjs("launch.json", {
  coreclr = { "cs" }
})

if dap.configurations.cs == nil then
  dap.configurations.cs = {}
end
dap.configurations.cs[#dap.configurations.cs+1] = {
  type = "coreclr",
  name = "launch dll",
  request = "launch",
  program = function()
    return vim.fn.input({
      prompt='path to dll: ',
      default=vim.fn.getcwd() .. '/bin/Debug/',
      completion='file'
    })
  end,
}


local python_path = function()
  local s
  local f = assert(io.popen("where python", "r"))
  s = assert(f:read("*a"))
  f:close()
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+.*', '')
  return s
end

dap.adapters.python = function(cb, config)
  if config.request == 'attach' then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port or 5678
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a python `attach` configuration'),
      host = host,
      options = {
        source_filetype = 'python',
      },
    })
  else
    cb({
      type = 'executable',
      command = vim.fn.stdpath('data')..'/mason/packages/debugpy/venv/'..bindir..'/python',
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    })
  end
end

if dap.configurations.python == nil then
  dap.configurations.python = {}
end
dap.configurations.python[#dap.configurations.python+1] = {
  type = 'python',
  request = 'launch',
  name = "launch file",
  program = "${file}",
  pythonPath = python_path,
}
dap.configurations.python[#dap.configurations.python+1] = {
  type = 'python',
  request = "attach",
  name = "attach remote",
  host = function()
    return vim.fn.input({
      prompt='host: ',
      default='localhost',
    })
  end,
  port = function()
    return vim.fn.input({
      prompt='port: ',
      default='5678',
    })
  end,
}
