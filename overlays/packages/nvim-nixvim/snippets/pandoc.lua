local ls = require("luasnip")
local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local p = require("luasnip.extras").partial
-- more requires
--
--
--

local beamer_columns = s(
	"columns",
	fmt(
		[[

::: columns

:::: {{.column width=50%}}

{}

::::

:::: {{.column width=50%}}

{}

::::

:::

]],
		{ i(1), i(2) }
	)
)
local pandoc_figure = s(
	"fig",
	fmt(
		[[

![{}]({})

]],
		{ i(1, "Figure caption"), i(2, "url") }
	)
)

--local entry_date_string = function(prefix)
--	return string.format(
--		"%s📅 %s ⏰ %s",
--		prefix,
--		vim.fn.systemlist("date +'%d.%m.%Y'")[1],
--		vim.fn.systemlist("date +'%H:%M:%S'")[1]
--	)
--end

---- TODO: Use json -> rst transformation for clean tables
---- local report_completed_tasks_tbl = function()
---- 	return vim.fn.split(require("nialov_utils").report_completed_tasks_tbl(), "\n")
---- end
--local report_completed_tasks_tbl_pretty_task = function()
--	return vim.fn.split(require("nialov_utils").report_completed_tasks_tbl_pretty_task(), "\n")
--end

---- local entry_snip = s({ trig = "entry", name = "entry", desc = "Diary entry" }, {
---- 	p(entry_date_string, "📘 Entry "),
---- 	t({ "----------------------------------", "", "Completed tasks in the past 24 hours:", "", "" }),
---- 	p(report_completed_tasks_tbl),
---- })

---- TODO: Deprecate after using entry-pretty for a while
---- local entry_snip = s(
---- 	"entry",
---- 	fmt(
---- 		[[

----         {}
----         {}
----         {}
----         ]],
---- 		{
---- 			p(entry_date_string, "📘 Entry "),
---- 			t({ "----------------------------------", "", "Completed tasks in the past 24 hours:", "" }),
---- 			p(report_completed_tasks_tbl, nil),
---- 		}
---- 	)
---- )
----

--local entry_snip_pretty_task = s(
--	"entry",
--	fmt(
--		[[

--        {}
--        {}
--        {}
--        ]],
--		{
--			p(entry_date_string, "📘 Entry "),
--			t({ "----------------------------------", "", "Completed tasks in the past 24 hours:", "" }),
--			p(report_completed_tasks_tbl_pretty_task, nil),
--		}
--	)
--)

-- local meeting_snip = s(
-- 	"meeting",
-- 	fmt(
-- 		[[
--         {}
--         {}

--         Stakeholders & Participants:

--         -  {}

--         ]],
-- 		{
-- 			p(entry_date_string, "Meeting "),
-- 			t({
-- 				"-----------------------------------",
-- 			}),
-- 			i(1),
-- 		}
-- 	)
-- )

--local url_snip = s("url", fmt([[ `{} <{}>`__ ]], { i(1), i(1) }))

-- snippets needs to be a list of values
local snippets = {
	beamer_columns,
	pandoc_figure,
}

return snippets, nil
