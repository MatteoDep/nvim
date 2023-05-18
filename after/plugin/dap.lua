local dap = require('dap')
local dapui = require("dapui")

vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
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
vim.keymap.set('n', '<leader>dB', function () dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, {desc="[d]ap conditional [B]reakpoint"})
vim.keymap.set('n', '<leader>dl', dap.step_into, {desc="[d]ap step into"})
vim.keymap.set('n', '<leader>dj', dap.step_over, {desc="[d]ap step over"})
vim.keymap.set('n', '<leader>dh', dap.step_out, {desc="[d]ap step out"})
vim.keymap.set('n', '<leader>dr', dap.repl.open, {desc="[d]ap repl open"})
vim.keymap.set('n', '<leader>du', dapui.toggle, {desc="[d]ap ui toggle"})

dap.adapters.coreclr = {
  type = 'executable',
  command = [[C:\Users\matte\AppData\Local\nvim-data\mason\packages\netcoredbg\netcoredbg\netcoredbg.exe]],
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        return vim.fn.input({
          prompt='Path to dll: ',
          default=vim.fn.getcwd() .. '/bin/Debug/',
          completion='file'
        })
    end,
  },
}
