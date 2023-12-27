---@mod Printer.default_config Default Config
---@brief [[
--->
---{
---    behavior = "insert_below", -- default behaviour either "insert_below" for inserting the debug print below or "yank" for yanking the debug print
---    formatters  = { -- check lua/formatters.lua for default value of formatters },
---    add_to_inside = function default_addtoinside(text) return string.format("[%s:%s] %s", vim.fn.expand("%"), vim.fn.line("."), text) end,
---    -- function with signature (string) -> string which adds some text to the string inside print statement
---    default_register = [["]], -- if register is not specified to which register should "yank" put debug print
---}
---<
---@brief ]]

---@mod Printer.setting_custom_formatters Setting Custom Formatters
---@brief [[
--- Custom formatters can be setup from 'printer.setup', setting 'vim.b.printer' variable or 'vim.g.printer[filtetype]' where 'filetype' is name of the filetype.
---@brief ]]

---@mod Printer.available_keymaps Available Keymaps
---@brief [[
--- "<Plug>(printer_below)" -> Adds a line below with debug print based on the motion
--- "<Plug>(printer_yank)"  -> Yanks a line with debug print based on the motion
--- "<Plug>(printer_print)" -> Either adds or yanks the debug print (based on the supplied config)
---Example:
---   vim.keymap.set("n", "gP", "<Plug>(printer_yank)")
---   vim.keymap.set("v", "gP", "<Plug>(printer_yank)")
---@brief ]]

---@mod Printer.setting_custom_addtoinside Setting Custom addtoinside
---@brief [[
--- Function which adds some text to the string inside the print statement with '(string) -> string' signature can be setup from 'printer.setup', setting 'vim.b.printer_addtoinside' variable or 'vim.g.printer_addtoinside'
---@brief ]]

---@class Printer.config
---@field behavior string default behaviour either "insert_below" for inserting the debug print below or "yank" for yanking the debug print
---@field add_to_inside function function with signature (string) -> string which adds some text to the string inside print statement
---@field keymap string default keymap
---@field formatters table table of filetypes and function formatters
---@field default_register string to which register should "yank" put debug print if register is not specified
local CONFIG = {}

local Marks = { VISUAL = { "<", ">" }, TEXTOBJECT = { "[", "]" } }

local function notify(msg, level, opts)
    vim.notify(
        "printer: " .. msg,
        level or vim.log.levels.INFO,
        vim.tbl_extend("keep", opts or {}, {
            title = "printer",
            icon = "󰐪",
        })
    )
end

local function get_text_from_range(range)
    if range.srow ~= range.erow then
        notify("printer.nvim doesn't support multiple lines ranges", vim.log.levels.ERROR)
        return nil
    end

    -- rows (lines) are 1 based indexed but have to be 0-based and inclusive so subtracting 1 from both start and end
    -- columns are 0 based indexed, have to be exclusive, so adding 1 to the end
    return vim.api.nvim_buf_get_text(
        0,
        range.srow - 1,
        range.scol,
        range.erow - 1,
        range.ecol + 1,
        {}
    )[1]
end

local function get_range_from_marks(marks)
    local start, _end =
        vim.api.nvim_buf_get_mark(0, marks[1]), vim.api.nvim_buf_get_mark(0, marks[2])
    return { srow = start[1], scol = start[2], erow = _end[1], ecol = _end[2] }
end

local function operatorfunc(callback, ...)
    local args = { ... }

    _G["__printer_operatorfunc_callback"] = function()
        callback(args)
        _G["__printer_operatorfunc_callback"] = nil
    end

    vim.cmd([[set operatorfunc=v:lua.__printer_operatorfunc_callback]])
end

local Printer = {}

Printer.default_addtoinside = function(text)
    return string.format("[%s:%s] %s", vim.fn.expand("%"), vim.fn.line("."), text or "")
end

Printer.insert_below = function(text)
    local text_to_insert = Printer.create_print_statement(text)
    vim.fn.execute("normal! o" .. text_to_insert)
end

Printer.yank = function(text)
    local text_to_insert = Printer.create_print_statement(text)
    local register = vim.v.register or CONFIG.default_register
    vim.fn.setreg(register, text_to_insert)
end

Printer.operator_print = function(behavior)
    behavior = behavior or CONFIG.behavior
    local mode = vim.fn.mode()
    local marks = ({ ["v"] = Marks.VISUAL, ["n"] = Marks.TEXTOBJECT })[mode]

    if not marks then
        notify("called from unsupported mode :" .. mode, vim.log.levels.ERROR)
        return
    end

    operatorfunc(function()
        local range = get_range_from_marks(marks)
        Printer[behavior](get_text_from_range(range))
    end)
    return "g@"
end

Printer.create_print_statement = function(text)
    local filetype = vim.bo.filetype
    local printer = vim.b["printer"]
        or vim.g.printer[filetype]
        or CONFIG.formatters[filetype]
        or require("printer.formatters")[filetype]

    if printer == nil then
        notify(
            "no formatter defined for "
                .. filetype
                .. " filetype. See ':help Printer.setting_custom_formatters' on how to add formatter for this filetype."
        )
        return
    end

    local add_to_inside = vim.b["printer_addtoinside"]
        or vim.g["printer_addtoinside"]
        or CONFIG.add_to_inside
        or Printer.default_addtoinside

    return printer(add_to_inside(text), text)
end

--- Used for setting initial configuration see |Printer.config|
Printer.setup = function(opts)
    opts = opts or {}
    local keymap = opts.keymap or "gp"

    vim.keymap.set({ "n", "v" }, keymap, Printer.operator_print, {
        expr = true,
        desc = "(printer.nvim) Operator keymap",
    })

    vim.keymap.set("n", keymap .. "p", Printer.insert_below, {
        desc = "(printer.nvim) print without a variable",
    })

    vim.keymap.set({ "n", "v" }, "<Plug>(printer_print)", Printer.operator_print, {
        expr = true,
        desc = "(printer.nvim) Debug print based on the config behavior",
    })

    vim.keymap.set({ "n", "v" }, "<Plug>(printer_below)", function()
        Printer.operator_print("insert_below")
    end, {
        expr = true,
        desc = "(printer.nvim) Add a line below with debug print based on the motion",
    })

    vim.keymap.set({ "n", "v" }, "<Plug>(printer_yank)", function()
        Printer.operator_print("yank")
    end, {
        expr = true,
        desc = "(printer.nvim) Yank a debug print based on the motion",
    })

    if opts.add_to_inside then
        if type(opts.add_to_inside) == "function" then
            CONFIG.add_to_inside = opts.add_to_inside
        else
            notify("add_to_inside field is not a function", vim.log.levels.ERROR)
        end
    end

    CONFIG.behavior = opts.behavior or "insert_below"
    CONFIG.formatters = opts.formatters or {}
    CONFIG.default_register = opts.default_register or [["]]
    vim.g.printer = {}
end

return Printer
