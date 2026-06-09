{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [
      gopls
      lua-language-server
      pyright
      rust-analyzer
      harper

      cljfmt
      gotools
      stylua
      yapf

      python3Packages.debugpy
      delve
      vscode-extensions.vadimcn.vscode-lldb
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
        vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { buffer = bufnr, desc = "Code Action" })
      end)

      -- Diagnostics
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
      })

      -- Harper toggle
      vim.keymap.set("n", "<leader>th", function()
        local clients = vim.lsp.get_clients({ name = "harper_ls" })
        if #clients > 0 then
          vim.cmd("LspStop harper_ls")
          vim.notify("Harper off")
        else
          vim.cmd("LspStart harper_ls")
          vim.notify("Harper on")
        end
      end, { desc = "Toggle Harper" })
      
      if vim.lsp.enable then
        vim.lsp.config('harper_ls', {
          cmd = { 'harper-ls', '--stdio' },
          filetypes = { 'markdown', 'gitcommit', 'text', 'plaintext' },
          root_markers = { '.git' },
          settings = {
            ["harper-ls"] = {
              diagnosticSeverity = "warning",
            },
          },
        })
        vim.lsp.enable('gopls')
        vim.lsp.enable('lua_ls')
        vim.lsp.enable('pyright')
        vim.lsp.enable('harper_ls')
      else
        local lspconfig = require('lspconfig')
        lspconfig.gopls.setup({})
        lspconfig.lua_ls.setup({})
        lspconfig.pyright.setup({})
        lspconfig.harper_ls.setup({
          settings = {
            ["harper-ls"] = {
              diagnosticSeverity = "warning",
            },
          },
        })
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

      -- Rustaceanvim
      vim.g.rustaceanvim = {
        server = {
          cmd = function()
            return { 'rust-analyzer' }
          end,
        },
        dap = {
          adapter = function()
            return {
              type = 'server',
              host = '127.0.0.1',
              port = '$' .. '{port}',
              executable = {
                command = '${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb',
                args = { '--port', '$' .. '{port}' },
              },
            }
          end,
        },
      }

      -- Dap (Go, Python, Rust)
      require("dap-go").setup()
      require("dap-python").setup(vim.fn.exepath("python"))
      require("dapui").setup()
      local dap = require("dap")
      dap.adapters.codelldb = {
        type = 'server',
        host = '127.0.0.1',
        port = '$' .. '{port}',
        executable = {
          command = '${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb',
          args = { '--port', '$' .. '{port}' },
        },
      }
      dap.configurations.rust = dap.configurations.rust or {
        {
          name = "Launch bin",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/simhash-lsh-uf', 'file')
          end,
          args = function()
            local a = vim.fn.input('Args: ', '-i data/sample.csv')
            return vim.split(a, ' ')
          end,
          cwd = vim.fn.getcwd(),
          stopOnEntry = false,
        },
      }
      vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, {desc = "toggle Breakpoint"})
      vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, {desc = "Continue"})
      vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, {desc = "Step Into"})
      vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end, {desc = "Step Over"})
      vim.keymap.set("n", "<leader>dO", function() require("dap").step_out() end, {desc = "Step Out"})
      vim.keymap.set("n", "<leader>dd", function() require("dapui").toggle() end, {desc = "Toggle DAP UI"})
      vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end, {desc = "Toggle REPL"})
      vim.keymap.set("n", "<leader>dq", function() require("dap").terminate() end, {desc = "Terminate"})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          vim.keymap.set("n", "<leader>dR", function()
            vim.cmd('RustLsp debuggables')
          end, { buffer = true, desc = "Rust Debuggables" })
        end,
      })

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
