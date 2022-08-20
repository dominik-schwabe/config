local config = require("user.config")

require('illuminate').configure({
    providers = {
        'lsp',
        'treesitter',
    },
    delay = 100,
    filetypes_denylist = config.illuminate_blacklist,
    filetypes_allowlist = {},
    -- modes_denylist = {},
    modes_allowlist = {"n"},
    providers_regex_syntax_denylist = {},
    providers_regex_syntax_allowlist = {},
    under_cursor = true,
})
