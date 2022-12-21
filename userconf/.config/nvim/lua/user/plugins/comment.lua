local F = require("user.functional")

local args = {
  padding = true,
  sticky = true,
  ignore = "^%s*$",

  mappings = {
    basic = true,
    extra = true,
  },
}

F.load("ts_context_commentstring.integrations.comment_nvim", function(ttscc)
  args.pre_hook = ttscc.create_pre_hook()
end)

require("Comment").setup(args)
