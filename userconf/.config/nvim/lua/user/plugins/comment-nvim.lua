local args = {
  padding = true,
  sticky = true,
  ignore = "^%s*$",

  mappings = {
    basic = true,
    extra = true,
  },
}

local ttscc_loaded, ttscc = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
if ttscc_loaded then
  args.pre_hook = ttscc.create_pre_hook()
end

require("Comment").setup(args)
