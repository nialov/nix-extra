local ls = require("luasnip")
local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
-- local rep = require("luasnip.extras").rep
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- more requires
--

local watchexec = s(
	{ trig = "we", name = "watchexec snippet" },
	fmt(
		[[
        watchexec --print-events --watch {} -- '{}'
    ]],
		{ i(1), i(2) }
	)
)

local snippets = {
	watchexec,
}

return snippets, nil
