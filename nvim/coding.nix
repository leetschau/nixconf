{ pkgs, ... }:

let
  vim-maximizer = pkgs.vimUtils.buildVimPlugin {
    name = "vim-maximizer";
    src = pkgs.fetchFromGitHub {
      owner = "szw";
      repo = "vim-maximizer";
      rev = "master";
      sha256 = "031brldzxhcs98xpc3sr0m2yb99xq0z5yrwdlp8i5fqdgqrdqlzr";
    };
  };

  vim-barbaric = pkgs.vimUtils.buildVimPlugin {
    name = "vim-barbaric";
    src = pkgs.fetchFromGitHub {
      owner = "rlue";
      repo = "vim-barbaric";
      rev = "master";
      sha256 = "0c8pm26591ivg7amlqizdndvfhq4q19ifvx7ywfhbhs7sha81vxv";
    };
  };

in
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      nvim-autopairs
      nvim-surround
      comment-nvim
      flash-nvim
      vim-parinfer
      vim-maximizer
      vim-barbaric
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
      vim.keymap.set("n", "<leader>tm", "<cmd>MaximizerToggle<cr>", {desc = "Toggle Maximizing"})
    '';
  };
}
