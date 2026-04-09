{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [
      gopls
      lua-language-server
      pyright

      cljfmt
      gotools # provides goimports
      stylua
      yapf

      python3Packages.debugpy
      delve
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      neodev-nvim
      lsp-zero-nvim
      cmp-nvim-lsp
      nvim-cmp
      luasnip
      fidget-nvim
      
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-dap-go
      nvim-dap-python
      
      conform-nvim
      rustaceanvim
      
      conjure
      cmp-conjure
      vim-hy
      iron-nvim
    ];

    initLua = ''
      -- Conform (Formatting)
      _G.format_on_save_enabled = true
      require("conform").setup({
        formatters_by_ft = {
          clojure = { "cljfmt" },
          lua = { "stylua" },
          go = { "goimports", "gofmt" },
          python = { "yapf" },
        },
        format_on_save = function(bufnr)
          if _G.format_on_save_enabled then
            return { lsp_fallback = true, timeout_ms = 5000 }
          else
            return nil
          end
        end,
      })
      vim.keymap.set("n", "<leader>cf", function() require("conform").format() end, {desc = "Format codes"})

      -- LSP Zero Setup
      local lsp_zero = require("lsp-zero")
      lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)
      
      if vim.lsp.enable then
        vim.lsp.enable('gopls')
        vim.lsp.enable('lua_ls')
        vim.lsp.enable('pyright')
      else
        local lspconfig = require('lspconfig')
        lspconfig.gopls.setup({})
        lspconfig.lua_ls.setup({})
        lspconfig.pyright.setup({})
      end

      -- CMP
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ["<TAB>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'conjure' },
        }
      })

      -- Dap (Go & Python)
      require("dap-go").setup()
      require("dap-python").setup(vim.fn.exepath("python"))
      require("dapui").setup()
      vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, {desc = "toggle Breakpoint"})

      -- Iron REPL
      local cfn = vim.api.nvim_buf_get_name(0)
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            go = { command = { "bash" } },
            lua = { command = { "lua" } },
            python = { command = { "ipython" } },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright("50%"),
        },
      })
    '';
  };
}
