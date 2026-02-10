return {
  "johnseth97/codex.nvim",
  lazy = true,
  cmd = { "Codex", "CodexToggle" },
  keys = {
    {
      "<leader>cc",
      function()
        require("codex").toggle()
      end,
      desc = "Toggle Codex popup",
    },
  },
  opts = {
    keymaps = {
      toggle = nil, -- Disabled by default to avoid conflicts
      quit = "<C-q>", -- Close Codex window with Ctrl+q
    },
    border = "rounded",
    width = 0.8,
    height = 0.8,
    model = nil, -- Uses default model, or set to 'o3-mini', etc.
    autoinstall = true, -- Automatically install CLI if missing
  },
}
