{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      codecompanion-nvim
      render-markdown-nvim
      nui-nvim
      
      telescope-nvim
      telescope-undo-nvim
      plenary-nvim
      which-key-nvim
      mini-nvim
      
      gitsigns-nvim
      neogit
      diffview-nvim
    ];

    initLua = ''
      -- Telescope & Undo
      require("telescope").setup({
        extensions = { undo = {} },
      })
      require("telescope").load_extension("undo")
      -- Telescope keymaps
      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
      vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>', {desc = "undo history"})

      -- Which-Key
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        {
          mode = { "n" },
          { "<leader>a", group = "AI" },
          { "<leader>c", group = "Coding" },
          { "<leader>cs", group = "Scala" },
          { "<leader>d", group = "Debugger" },
          { "<leader>e", group = "file Explorer" },
          { "<leader>f", group = "Finder" },
          { "<leader>g", group = "Git Ops" },
          { "<leader>gt", group = "Gitsigns Toggle" },
          { "<leader>o", group = "Outline" },
          { "<leader>p", group = "Package manager" },
          { "<leader>r", group = "REPL" },
          { "<leader>rm", group = "Marks" },
          { "<leader>rs", group = "Send" },
          { "<leader>t", group = "Toggle" },
        },
        {
          mode = { "v" },
          { "<leader>a", group = "AI" },
          { "<leader>r", group = "Repl" },
          { "<leader>rm", group = "Marks" },
          { "<leader>rs", group = "Send" },
        }
      })

      -- CodeCompanion
      require('codecompanion').setup({
        adapters = {
          http = {
            glm = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  api_key = "ZHIPU_API_KEY",
                  url = "https://open.bigmodel.cn/api/coding/paas/v4",
                  chat_url = "/chat/completions",
                },
                name = "glm",
                schema = {
                  model = {
                    default = "glm-5.1",
                    choices = { "glm-5.1" },
                  },
                },
              })
            end,
          },
        },
        strategies = {
          chat = { adapter = "glm" },
          inline = { adapter = "glm" },
          cmd = { adapter = "glm" },
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion chat" })
      
      -- Gitsigns
      require('gitsigns').setup({ current_line_blame = true })
      vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns stage_hunk<cr>", {desc = "Stage the hunk under the curor"})
      vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame<cr>", {desc = "Show blames"})
      vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", {desc = "Show diff of the current buffer"})
      vim.keymap.set("n", "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", {desc = "Jump to next hunk"})
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", {desc = "Jump to previous hunk"})
      vim.keymap.set("n", "<leader>gq", "<cmd>Gitsigns setqflist<cr>", {desc = "Show hunks in quickfix list"})
      vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns select_hunk<cr>", {desc = "Select the hunk under the curor"})
      vim.keymap.set("n", "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>", {desc = "Toggle current line blame"})
      vim.keymap.set("n", "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", {desc = "Toggle deleted texts"})
      vim.keymap.set("n", "<leader>gts", "<cmd>Gitsigns toggle_signs<cr>", {desc = "Toggle signs"})
      vim.keymap.set("n", "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>", {desc = "Toggle word diff"})
      vim.keymap.set("n", "<leader>gv", "<cmd>Gitsigns preview_hunk<cr>", {desc = "Preview hunk"})
      vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", {desc = "Unstage the hunk under the curor"})

      -- Format on save toggle
      vim.keymap.set("n", "<leader>tf", function()
        _G.format_on_save_enabled = not _G.format_on_save_enabled
        print("Format on save: " .. (_G.format_on_save_enabled and "enabled" or "disabled"))
      end, {desc = "Toggle format on save"})

      -- Neogit
      vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", {desc = "Show Neogit UI"})
    '';
  };
}
