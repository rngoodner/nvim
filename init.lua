-- ~/.config/nvim/init.lua

-- requires nvim >= 0.7.0
-- https://github.com/neovim/neovim/releases/

-- Install LSPs (and other deps)
-- ubuntu: sudo apt install clang-tools bear
-- rhel: sudo dnf install clang-tools-extra bear
-- macos: brew install llvm bear
-- go install golang.org/x/tools/gopls@latest
-- go install golang.org/x/tools/cmd/goimports@latest
-- pip3 install 'python-lsp-server[all]' # maybe after installing miniconda and enabling base env

-- Install packer with:
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
-- Everything should install automatically on first run
-- If not, try :PackerCompile and :PackerInstall

-- Add new lsp's to this list in order to activate
-- If setup is needed, see this link and then add after setup loop below:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- note: to stop lsp run :LspStop
local servers = {'clangd', 'gopls', 'pylsp'}

-- Packer packages
local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim'              -- Package manager
  use "EdenEast/nightfox.nvim"              -- Theme
  use 'maxmx03/solarized.nvim'
  use 'ellisonleao/gruvbox.nvim'
  use 'neovim/nvim-lspconfig'               -- Collection of configurations for the built-in LSP client
  use 'hrsh7th/nvim-cmp'                    -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'                -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'            -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip'                    -- Snippets plugin
  use 'tpope/vim-sleuth'                    -- indent style detection
  use "ray-x/lsp_signature.nvim"            -- Function signature while typing
  use "bronson/vim-trailing-whitespace"     -- Trailing white space, fix w/ :FixWhitespace
  use "mattn/vim-goimports"                 -- Go code formatting and imports management
  use "preservim/nerdcommenter"             -- Comments with <leader>cc, <leader>cu, <leader>c<space> <leader>cl
  use "kyazdani42/nvim-tree.lua"            -- file tree, toggle w/ C-n, manip w/ a,d,c,p,x,R
end)

-- recompile if this file changes
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost init.lua source <afile> | PackerCompile
augroup end
]])

-- basic settings
vim.cmd 'PackerInstall'
vim.cmd 'set background=dark'
vim.cmd 'set termguicolors'
vim.cmd 'colorscheme gruvbox' -- nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox, gruvbox
vim.g.mapleader = ' '

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Use a loop to conveniently call 'setup' on multiple LSP servers and
-- map buffer local keybindings when the language server attaches
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
      capabilities = capabilities,
    }
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- function signature config
cfg = {}
require "lsp_signature".setup(cfg)

-- go imports on save
vim.cmd 'let g:goimports = 1'

-- nvim tree
-- these settings get rid of the need for any special fonts
require'nvim-tree'.setup {
  renderer = {
    indent_markers = {
      enable = true,
      icons = {
        corner = "└ ",
        edge = "│ ",
        item = "│ ",
        none = "  ",
      }
    },
    icons = {
      webdev_colors = true,
      git_placement = "before",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
        git = false,
      }
    }
  }
}
vim.cmd([[
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>
" More available functions:
" NvimTreeOpen
" NvimTreeClose
" NvimTreeFocus
" NvimTreeFindFileToggle
" NvimTreeResize
" NvimTreeCollapse
" NvimTreeCollapseKeepBuffers

set termguicolors " this variable must be enabled for colors to be applied properly

" a list of groups can be found at `:help nvim_tree_highlight`
highlight NvimTreeFolderIcon guibg=blue
]])

-- spellcheck language
-- activate with `:set spell`
-- deactivate with `:set nospell`
vim.cmd 'set spelllang=en_us'

-- line numbers
vim.cmd 'set number'

-- highlight current line number
vim.cmd 'set cursorline'
vim.cmd 'set cursorlineopt=number'

-- enable mouse support
vim.cmd 'set mouse=a'

-- system clipboard
vim.api.nvim_set_option("clipboard","unnamed")

-- basic tabs and spacing
vim.cmd 'set tabstop=4'
vim.cmd 'set shiftwidth=4'
vim.cmd 'set expandtab'
vim.cmd 'set autoindent'

-- reselect visual block after indent
vim.cmd 'vnoremap < <gv'
vim.cmd 'vnoremap > >gv'

-- MOVE LINE/BLOCK
vim.cmd 'nnoremap <C-S-Down> :m+<CR>=='
vim.cmd 'nnoremap <C-S-Up> :m-2<CR>=='
vim.cmd 'inoremap <C-S-Down> <Esc>:m+<CR>==gi'
vim.cmd 'inoremap <C-S-Up> <Esc>:m-2<CR>==gi'
vim.cmd 'vnoremap <C-S-Down> :m\'>+<CR>gv=gv'
vim.cmd 'vnoremap <C-S-Up> :m-2<CR>gv=gv'
