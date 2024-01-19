-- nvim options
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.autoindent = true
vim.o.clipboard = "unnamedplus"
vim.o.number = true
vim.o.showmatch = true
vim.o.showcmd = true

vim.o.ignorecase = all
vim.o.smartcase = true
vim.o.hlsearch = true

vim.cmd([[
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif
]])

-- persistent undo
vim.o.undofile = true
vim.o.undodir = vim.fn.expand('~/.config/nvim/undodir')
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- nvim plugins
--
-- Ensure Packer is installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- Auto install packer.nvim if not exists
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- Load Packer
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost init.lua PackerCompile'

-- Define plugins
require('packer').startup(function()
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'

    use 'neovim/nvim-lspconfig'
    use 'nvim-lua/lsp-status.nvim'
    use 'nvim-lua/lsp_extensions.nvim'

    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'

    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'

    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    --use 'github/copilot.vim'
    use 'zbirenbaum/copilot.lua' as = 'copilot'

    use {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
        end,
    }

    -- Lazy loading:
    -- Load on specific commands
    use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

    -- Load on an autocommand event
    use {'andymass/vim-matchup', event = 'VimEnter'}

    -- Load on a combination of conditions: specific filetypes or commands
    -- Also run code after load (see the "config" key)
    use {
        'w0rp/ale',
        ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
        cmd = 'ALEEnable',
        config = 'vim.cmd[[ALEEnable]]'
    }

    -- Post-install/update hook with call of vimscript function with argument
    use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

    -- Use dependency and run lua function after load
    use {
        'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
        config = function() require('gitsigns').setup() end
    }

    -- You can specify multiple plugins in a single call
    use {'tjdevries/colorbuddy.vim', {'nvim-treesitter/nvim-treesitter', opt = true}}

    -- You can alias plugin names
    use {'sainnhe/sonokai'}
end)

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.html.setup {}
lspconfig.cssls.setup {}
lspconfig.jsonls.setup {}
lspconfig.vimls.setup {}
lspconfig.bashls.setup {}
lspconfig.clangd.setup {}
--lspconfig.lua.setup {}
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.rust_analyzer.setup {
    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        ['rust-analyzer'] = {},
    },
}


-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- Go to the next error
        vim.keymap.set('n', '<space>en', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>ep', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})


require('copilot').setup({
    panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
        },
        layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
        },
    },
    suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
            accept_word = false,
            accept_line = false,
            next = "<S-Tab]>",
            prev = "<C-Tab>",
            dismiss = "<C-x>",
        },
    },
    filetypes = {
        ["."] = true,
    },
    copilot_node_command = 'node', -- Node.js version must be > 18.x
    server_opts_overrides = {},
})

vim.keymap.set('i', '<Tab>', function()
    if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
    end
end, { desc = "Super Tab" })

vim.cmd('colorscheme sonokai')

-- Force background color to be black (000000)
vim.cmd('highlight Normal guibg=NONE ctermbg=NONE')
