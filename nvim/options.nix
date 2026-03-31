{ lib, ... }: {
  programs.neovim.initLua = lib.mkBefore ''
    -- =====================================================================
    -- Base Options & Keymaps (from base.lua)
    -- =====================================================================
    vim.opt.clipboard = "unnamedplus"
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.signcolumn = "auto:3"
    vim.opt.wrap = false
    vim.opt.undofile = true
    vim.opt.spelllang = { "en", "cjk" }
    vim.opt.mouse = ""

    vim.g.mapleader = " "

    vim.keymap.set("n", ";", ":")
    vim.keymap.set("v", ";", ":")

    vim.keymap.set("i", "<C-J>", "<C-x><C-n>")
    vim.keymap.set("i", "<C-J>", "<C-n>")

    vim.keymap.set("n", "<C-H>", "<C-w><C-H>")
    vim.keymap.set("n", "<C-J>", "<C-w><C-J>")
    vim.keymap.set("n", "<C-K>", "<C-w><C-K>")
    vim.keymap.set("n", "<C-L>", "<C-w><C-L>")
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
    vim.keymap.set("t", "<C-H>", "<C-w><C-H>")
    vim.keymap.set("t", "<C-J>", "<C-w><C-J>")
    vim.keymap.set("t", "<C-K>", "<C-w><C-K>")
    vim.keymap.set("t", "<C-H>", [[<C-\><C-n><C-w><C-H>]])

    vim.keymap.set("n", "<leader>th", ":set hls!<CR>")
    vim.keymap.set("n", "<leader>tn", ":set number!<CR>")
    vim.keymap.set("n", "<leader>ts", ":set spell!<CR>")
    vim.keymap.set("n", "<leader>tw", ":set wrap!<CR>")

    -- Custom Filetypes
    vim.filetype.add({
      extension = {
        jmd = "julia",
        ipy = "python",
        qmd = "markdown",
      }
    })
  '';
}
