local M = {}

M.defaults = {
  auto_chdir = true,
  setup_auto_cmd = true,
  path_replacements = {},
  rules = {
    {
      0,
      ends_with = {
        "/nvim",
        "/node_modules",
      },
      contains = {
        ".bzr",
        ".git",
        ".hg",
        ".latexmkrc",
        ".luarc.json",
        ".svn",
        "Cargo.toml",
        "Makefile",
        "Pipfile",
        "Pipfile.lock",
        "_darcs",
        "node_modules",
        "package-lock.json",
        "package.json",
        "pyproject.toml",
        "requirements.txt",
      },
      patterns = { "/lib/python3.[0-9]*$" },
    },
    {
      1,
      ends_with = { "/site-packages" },
      patterns = { "/lib/python3.[0-9]*$" },
    },
  },
}

M.config = {}

function M.setup(options)
  M.config = vim.tbl_extend("force", {}, M.defaults, options or {})
end

return M
