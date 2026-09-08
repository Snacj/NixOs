-- Floating terminals
--
-- A small manager for named, persistent floating terminals.
--
--   <leader>tt   toggle the shell terminal
--   <leader>tg   lazygit (opened at the git root of the current file)
--   <leader>tr   run the current file
--   <leader>tc   prompt for a shell command and run it
--   <leader>tl   re-run the last command
--   <leader>ts   send the current line / visual selection to the shell terminal
--
-- Inside a floating terminal:
--   <C-q>        hide the float (the process keeps running)
--   q            hide the float (normal mode)
--   <esc><esc>   leave terminal mode -- not mapped for TUI apps such as lazygit
--
-- Commands: :Floaterminal  :Lazygit  :FloatRun {cmd}  :FloatRunFile

local M = {}

-- ---------------------------------------------------------------- state ----

---@type table<string, table>
local terms = {}

local defaults = {
    width = 0.85,          -- fraction of the editor
    height = 0.85,
    border = "rounded",
    close_on_exit = true,  -- close the float when the process ends
    esc_to_normal = true,  -- map <esc><esc> to leave terminal mode
    auto_hide = true,      -- hide the float when it loses focus
    insert = true,         -- enter terminal mode on open
}

local function define(name, opts)
    opts = vim.tbl_extend("keep", opts or {}, defaults)
    opts.name = name
    opts.title = opts.title or name
    terms[name] = opts
    return opts
end

local function is_open(t)
    return t.win ~= nil and vim.api.nvim_win_is_valid(t.win)
end

local function has_buf(t)
    return t.buf ~= nil and vim.api.nvim_buf_is_valid(t.buf)
end

local function is_running(t)
    return t.job ~= nil
end

-- --------------------------------------------------------------- window ----

local function win_config(t, title)
    local width = math.max(1, math.min(vim.o.columns - 2, math.floor(vim.o.columns * t.width)))
    local height = math.max(1, math.min(vim.o.lines - 4, math.floor(vim.o.lines * t.height)))

    return {
        relative = "editor",
        width = width,
        height = height,
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
        row = math.max(0, math.floor((vim.o.lines - height) / 2 - 1)),
        style = "minimal",
        border = t.border,
        title = " " .. (title or t.title) .. " ",
        title_pos = "center",
    }
end

local function close(t)
    if is_open(t) then
        local win = t.win
        t.win = nil
        pcall(vim.api.nvim_win_close, win, true)
    end
    t.win = nil
end

-- ----------------------------------------------------------------- term ----

local function buf_keymaps(t)
    local opts = { buffer = t.buf, silent = true }
    vim.keymap.set({ "t", "n" }, "<C-q>", function() close(t) end, opts)
    vim.keymap.set("n", "q", function() close(t) end, opts)
    if t.esc_to_normal then
        vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", opts)
    end
end

local function on_exit(t, job, code)
    -- a stale job from a previous run must not clobber the current one
    if t.job ~= job then
        return
    end
    t.job = nil
    t.code = code
    vim.schedule(function()
        if t.on_close then
            t.on_close(code)
        end
        if t.close_on_exit then
            close(t)
            if has_buf(t) then
                pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
            end
            t.buf = nil
        elseif is_open(t) then
            local label = ("%s [exit %d]"):format(t.title, code)
            pcall(vim.api.nvim_win_set_config, t.win, win_config(t, label))
            if vim.api.nvim_get_current_win() == t.win then
                vim.cmd.stopinsert()
            end
        end
    end)
end

local function start(t)
    local cmd = type(t.cmd) == "function" and t.cmd() or t.cmd
    local cwd = type(t.cwd) == "function" and t.cwd() or t.cwd

    -- set before jobstart: TermOpen fires while the job is being created
    vim.b[t.buf].floaterm = t.name

    vim.api.nvim_buf_call(t.buf, function()
        local job
        job = vim.fn.jobstart(cmd or vim.o.shell, {
            term = true,
            cwd = cwd and vim.fn.isdirectory(cwd) == 1 and cwd or nil,
            on_exit = function(id, code)
                on_exit(t, id, code)
            end,
        })
        t.job = job > 0 and job or nil
    end)

    if not t.job then
        vim.notify(("floaterminal: could not start %s"):format(cmd or vim.o.shell), vim.log.levels.ERROR)
        return false
    end

    buf_keymaps(t)
    return true
end

local function open(t)
    -- only one floating terminal on screen at a time
    for _, other in pairs(terms) do
        if other ~= t then
            close(other)
        end
    end

    if not has_buf(t) then
        t.buf = vim.api.nvim_create_buf(false, false)
        vim.bo[t.buf].bufhidden = "hide"
        t.job = nil
    end

    local title = t.title
    if not is_running(t) and t.code then
        title = ("%s [exit %d]"):format(t.title, t.code)
    end
    t.win = vim.api.nvim_open_win(t.buf, true, win_config(t, title))
    vim.wo[t.win][0].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
    vim.wo[t.win][0].scrolloff = 0
    vim.wo[t.win][0].sidescrolloff = 0

    if not is_running(t) then
        t.code = nil
        if not start(t) then
            close(t)
            return
        end
    end

    if t.insert then
        vim.cmd.startinsert()
    end
end

-- ------------------------------------------------------------------ api ----

function M.open(name)
    local t = terms[name]
    if not t then
        return vim.notify("floaterminal: unknown terminal " .. name, vim.log.levels.ERROR)
    end
    if is_open(t) then
        vim.api.nvim_set_current_win(t.win)
        if t.insert and is_running(t) then
            vim.cmd.startinsert()
        end
    else
        open(t)
    end
end

function M.hide(name)
    local t = terms[name]
    if t then
        close(t)
    end
end

function M.toggle(name)
    local t = terms[name]
    if not t then
        return vim.notify("floaterminal: unknown terminal " .. name, vim.log.levels.ERROR)
    end
    if is_open(t) and vim.api.nvim_get_current_win() == t.win then
        close(t)
    else
        M.open(name)
    end
end

-- Send text to the shell terminal (opens it if needed).
---@param lines string|string[]
function M.send(lines)
    if type(lines) == "table" then
        lines = table.concat(lines, "\n")
    end
    local t = terms.shell
    if not is_running(t) then
        M.open("shell")
    end
    if is_running(t) then
        vim.fn.chansend(t.job, lines:gsub("\n*$", "") .. "\n")
        if is_open(t) then
            vim.api.nvim_win_set_cursor(t.win, { vim.api.nvim_buf_line_count(t.buf), 0 })
        end
    end
end

-- ------------------------------------------------------------- terminals ----

local function git_root()
    return vim.fs.root(0, ".git") or vim.uv.cwd()
end

define("shell", { title = "terminal", cwd = vim.uv.cwd })

define("lazygit", {
    title = "lazygit",
    cmd = "lazygit",
    cwd = git_root,
    esc_to_normal = false, -- lazygit uses <esc> itself
    width = 0.95,
    height = 0.95,
    on_close = function()
        vim.cmd.checktime() -- reload buffers lazygit may have changed
    end,
})

define("run", {
    title = "run",
    close_on_exit = false, -- keep the output around after the command ends
    insert = false,
})

-- ------------------------------------------------------------- runners -----

local function expand(tpl, file)
    local subs = {
        file = vim.fn.shellescape(file),
        dir = vim.fn.shellescape(vim.fs.dirname(file)),
        name = vim.fn.shellescape(vim.fn.fnamemodify(file, ":t:r")),
        tmp = vim.fn.shellescape(vim.fn.tempname()),
    }
    return (tpl:gsub("{(%w+)}", function(key)
        return subs[key] or ("{" .. key .. "}")
    end))
end

-- filetype -> command template, or function(file) -> cmd, cwd
M.runners = {
    lua = "nvim -l {file}", -- nvim's lua, so vim.* is available
    python = "python3 {file}",
    sh = "bash {file}",
    bash = "bash {file}",
    zsh = "zsh {file}",
    fish = "fish {file}",
    javascript = "node {file}",
    typescript = "node {file}",
    ruby = "ruby {file}",
    php = "php {file}",
    perl = "perl {file}",
    java = "java {file}",
    zig = "zig run {file}",
    haskell = "runghc {file}",
    c = "cc {file} -o {tmp} && {tmp}",
    cpp = "c++ -std=c++20 {file} -o {tmp} && {tmp}",
    nix = "nix eval --file {file}",
    go = function(file)
        local root = vim.fs.root(file, { "go.mod" })
        if root then
            return "go run .", vim.fs.dirname(file)
        end
        return expand("go run {file}", file)
    end,
    rust = function(file)
        local root = vim.fs.root(file, { "Cargo.toml" })
        if root then
            return "cargo run", root
        end
        return expand("rustc {file} -o {tmp} && {tmp}", file)
    end,
}

-- Run an arbitrary shell command in the "run" float.
function M.run(cmd, cwd)
    if not cmd or cmd == "" then
        return
    end
    M.last = { cmd = cmd, cwd = cwd }

    local t = terms.run
    close(t)
    if is_running(t) then
        local job = t.job
        t.job = nil
        pcall(vim.fn.jobstop, job)
    end
    if has_buf(t) then
        pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
        t.buf = nil
    end

    t.cmd = cmd
    t.cwd = cwd
    t.title = "run: " .. cmd
    t.code = nil
    open(t)
end

-- Run the file in the current buffer.
function M.run_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buftype ~= "" or file == "" then
        return vim.notify("floaterminal: no file in this buffer", vim.log.levels.WARN)
    end
    if vim.bo[buf].modified then
        vim.cmd.write()
    end

    local ft = vim.bo[buf].filetype
    local runner = M.runners[ft]
    if not runner then
        return vim.notify("floaterminal: no runner for filetype '" .. ft .. "'", vim.log.levels.WARN)
    end

    local cmd, cwd
    if type(runner) == "function" then
        cmd, cwd = runner(file)
    else
        cmd = expand(runner, file)
    end
    M.run(cmd, cwd or vim.fs.dirname(file))
end

function M.run_last()
    if not M.last then
        return vim.notify("floaterminal: nothing to re-run yet", vim.log.levels.WARN)
    end
    M.run(M.last.cmd, M.last.cwd)
end

-- ----------------------------------------------------------- autocmds ------

local group = vim.api.nvim_create_augroup("floaterminal", { clear = true })

-- keep open floats centred when the editor is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
        for _, t in pairs(terms) do
            if is_open(t) then
                pcall(vim.api.nvim_win_set_config, t.win, win_config(t))
            end
        end
    end,
})

-- hide a float as soon as focus moves elsewhere
vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        for _, t in pairs(terms) do
            if t.auto_hide and is_open(t) and t.win == win then
                vim.schedule(function()
                    if is_open(t) and vim.api.nvim_get_current_win() ~= t.win then
                        close(t)
                    end
                end)
            end
        end
    end,
})

-- plain :terminal buffers keep the old <esc><esc> escape hatch
vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function(ev)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        if not vim.b[ev.buf].floaterm then
            vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { buffer = ev.buf, silent = true })
        end
    end,
})

-- ----------------------------------------------------------- commands ------

vim.api.nvim_create_user_command("Floaterminal", function()
    M.toggle("shell")
end, { desc = "Toggle the floating terminal" })

vim.api.nvim_create_user_command("Lazygit", function()
    M.toggle("lazygit")
end, { desc = "Toggle lazygit in a float" })

vim.api.nvim_create_user_command("FloatRun", function(o)
    M.run(o.args ~= "" and o.args or nil, vim.uv.cwd())
end, { nargs = "*", complete = "shellcmd", desc = "Run a shell command in a float" })

vim.api.nvim_create_user_command("FloatRunFile", function()
    M.run_file()
end, { desc = "Run the current file in a float" })

-- ----------------------------------------------------------- keymaps -------

local map = vim.keymap.set

map("n", "<leader>tt", function() M.toggle("shell") end, { desc = "Toggle floating terminal" })
map("n", "<leader>tg", function() M.toggle("lazygit") end, { desc = "Lazygit" })
map("n", "<leader>tr", M.run_file, { desc = "Run current file" })
map("n", "<leader>tl", M.run_last, { desc = "Re-run last command" })

map("n", "<leader>tc", function()
    vim.ui.input({ prompt = "Run: ", completion = "shellcmd" }, function(cmd)
        M.run(cmd, vim.uv.cwd())
    end)
end, { desc = "Run a command" })

map("n", "<leader>ts", function()
    M.send(vim.api.nvim_get_current_line())
end, { desc = "Send line to terminal" })

map("x", "<leader>ts", function()
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
    M.send(lines)
end, { desc = "Send selection to terminal" })

return M
