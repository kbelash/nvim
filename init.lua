local fn = vim.fn
local data = fn.stdpath("data")
local packdir = data .. "/site/pack/min/start"

if fn.isdirectory(packdir) == 0 then
  fn.mkdir(packdir, "p")
end

local function InstallPlugin(name, repo)
  local path = packdir .. "/" .. name

  if fn.isdirectory(path) == 0 then
    print("Installing " .. repo)
    fn.system({
      "git",
      "clone",
      "--depth=1",
      repo,
      path,
    })
  end
end

InstallPlugin("formatter.nvim", "https://github.com/mhartington/formatter.nvim.git")
InstallPlugin("telescope.nvim", "https://github.com/nvim-telescope/telescope.nvim.git")
InstallPlugin("plenary.nvim", "https://github.com/nvim-lua/plenary.nvim.git")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "h", "hh", "hpp", "hxx", "cc", "cxx" },
  callback = function()
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd" },
      root_dir = vim.fs.root(0, {
        ".git",
        ".clang-format",
        ".clangd",
        "CMakePresets.json"
      }),
    })
  end,
})

local function splitted(f)
  return function()
    vim.cmd("vsplit")
    f()
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.keymap.set("n", "gd", splitted(vim.lsp.buf.definition), opts)
    vim.keymap.set("n", "gD", splitted(vim.lsp.buf.declaration), opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<S-e>', builtin.grep_string, {})

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup {
  -- Enable or disable logging
  logging = false,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["cpp"] = {
      require("formatter.filetypes.cpp").clangformat
    },
    ["c"] = {
      require("formatter.filetypes.c").clangformat
    },
    ["go"] = {
      require("formatter.filetypes.go").gofmt
    },
  }
}

function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end


if file_exists(".clang-format") or file_exists("go.mod") then
vim.cmd [[
inoremap <C-n> <C-x><C-o>
set completeopt-=preview
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
]]
end

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.nu = true
vim.o.rnu = true
vim.o.swapfile = false 
vim.o.splitright = true
vim.o.guifont = "Noto Sans Mono SemiCondensed:h11"
vim.opt.signcolumn = "yes"

vim.cmd [[set cinoptions=l1]]
vim.cmd [[set clipboard=unnamedplus]]

vim.cmd.command('GoBuild vs | ter go build main.go')
vim.cmd.command('GoRun vs | ter go run main.go')
vim.cmd.command('Build vs | ter cmake --workflow default')
vim.cmd.command('HostBuild vs | ter cmake --workflow host')

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})
