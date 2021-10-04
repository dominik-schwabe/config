local vimpath = vim.fn.stdpath("config") .. "/code_runner.json"
local subconfig = {
  map = "<leader>r",
  json_path = vimpath
}
require("code_runner").setup({
  term = { position = "vert", size = 8 },
  filetype = subconfig,
  project_context = subconfig
})
