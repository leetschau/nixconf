{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-moonfly-colors
      nightfly # Changed from vim-nightfly-colors
      tokyonight-nvim
      lualine-nvim
      nvim-web-devicons
      nvim-tree-lua
      aerial-nvim # outline
    ];

    initLua = ''
      -- Colorscheme
      vim.cmd([[colorscheme tokyonight-night]])

      -- Nvim-Tree
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.cmd([[ highlight NvimTreeFolderArrowClosed guifg=#3FC5FF ]])
      vim.cmd([[ highlight NvimTreeFolderArrowOpen guifg=#3FC5FF ]])
      require("nvim-tree").setup({
        view = { width = 35, relativenumber = true },
        renderer = { indent_markers = { enable = true } },
        actions = { open_file = { window_picker = { enable = false } } },
      })
      vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<cr>", {desc = "Toggle file explorer"})

      -- Lualine
      require('lualine').setup({ options = { theme = 'gruvbox_dark' } })
      
      -- Aerial Outline
      require('aerial').setup({})
      vim.keymap.set("n", "<leader>ow", "<cmd>AerialToggle<cr>", {desc = "Toggle outline"})

      vim.keymap.set("n", "<leader>v", "<cmd>Telescope colorscheme<cr>", {desc = "Colorscheme picker"})
    '';
  };
}
