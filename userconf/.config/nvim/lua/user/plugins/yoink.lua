vim.g.yoinkIncludeDeleteOperations = 1

-- vim.g.clipboard = {
--   name = "xsel_override",
--   copy = {
--     ["+"] = "xsel --input --clipboard",
--     ["*"] = "xsel --input --primary",
--   },
--   paste = {
--     ["+"] = "xsel --output --clipboard",
--     ["*"] = "xsel --output --primary",
--   },
--   cache_enabled = 1,
-- }

vim.keymap.set("n", "ü", "<plug>(YoinkRotateBack)")
vim.keymap.set("n", "Ü", "<plug>(YoinkRotateForward)")
vim.keymap.set("n", "p", "<plug>(YoinkPaste_p)")
vim.keymap.set("n", "P", "<plug>(YoinkPaste_P)")
vim.keymap.set("n", "gp", "<plug>(YoinkPaste_gp)")
vim.keymap.set("n", "gP", "<plug>(YoinkPaste_gP)")
