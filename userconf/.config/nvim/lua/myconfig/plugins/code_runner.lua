local subconfig = {
  json_path = vim.fn.stdpath("config") .. "/code_runner.json",
}
require("code_runner").setup({
  term = { position = "vert", size = 8 },
  filetype = subconfig,
  project_context = subconfig,
})
