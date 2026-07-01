vim.pack.add({ "https://github.com/saghen/blink.lib", "https://github.com/saghen/blink.cmp" })
local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup({
    keymap = { preset = "enter" },
    appearance = {
        nerd_font_variant = "mono",
    },
    completion = { documentation = { auto_show = false } },
    signature = { enabled = true },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
})
