{ pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      nvim-autopairs
      nvim-surround
      comment-nvim
      flash-nvim
      vim-parinfer
      zoomwintab-vim
      im-select-nvim
    ];

    initLua = ''
      -- Autopairs & Surround
      require('nvim-autopairs').setup({})
      require("nvim-surround").setup({})

      -- Flash
      vim.keymap.set({"n", "v", "o"}, "X", function() require("flash").jump() end, {desc = "Flash Jump"})

      -- Comment
      require('Comment').setup({ mappings = { extra = false } })

      -- Maximizer keymap
      vim.keymap.set("n", "<leader>tm", "<cmd>ZoomWinTabToggle<cr>", {desc = "Toggle Maximizing"})

      -- IME auto-switch (fcitx5)
      require('im_select').setup({
        im_select_command = 'fcitx5-remote',
        im_default_messages = { en = '1' },
        im_set_messages = {
          Active = 'fcitx5-remote -o',
          Inactive = 'fcitx5-remote -c',
        },
      })
    '';
  };
}
