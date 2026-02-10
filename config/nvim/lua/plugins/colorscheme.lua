return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = false,
      custom_highlights = function(colors)
        return {
          Normal = { bg = "#1a1a1a" },
          NormalFloat = { bg = "#1a1a1a" },
          NvimTreeNormal = { bg = "#1a1a1a" },
        }
      end,
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
