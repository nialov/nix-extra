local ls = require("luasnip")
local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
local l = require("luasnip.extras").lambda
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
local p = require("luasnip.extras").partial
-- more requires
--
--
local entry_date_string = function(prefix)
	return string.format(
		"%s📅 %s ⏰ %s",
		prefix,
		vim.fn.systemlist("date +'%d.%m.%Y'")[1],
		vim.fn.systemlist("date +'%H:%M:%S'")[1]
	)
end

local report_completed_tasks_tbl_pretty_task = function()
	local task_table = require("nialov_utils").report_completed_tasks_tbl_pretty_task()
	if type(task_table) ~= "table" then
		vim.notify("Expected report_completed_tasks_tbl_pretty_task to return a table.", vim.log.levels.ERROR)
		return {}
	end
	if #task_table == 0 then
		return { "No completed tasks." }
	end
	return task_table
end

local entry_snip_pretty_task = s(
	"entry",
	fmt(
		[[

        {}
        {}
        {}
        ]],
		{
			p(entry_date_string, "📘 Entry "),
			t({ "----------------------------------", "", "Completed tasks in the past 24 hours:", "" }),
			p(report_completed_tasks_tbl_pretty_task, nil),
		}
	)
)

local meeting_snip = s(
	"meeting",
	fmt(
		[[
        {}
        {}

        -   Stakeholders & Participants:

            -  {}

        ]],
		{
			p(entry_date_string, "Meeting "),
			t({
				"-----------------------------------",
			}),
			i(1),
		}
	)
)

local topic_snip = s(
	"topic",
	fmt(
		[[
{}
{}

{}
]],
		{
			i(1, "<topic-of-discussion>"),
			l(l._1:gsub(".", "~"), 1),
			-- Example choice node:
			-- c(2, { t("happy"), t("content"), t("angry") }),
			i(2, "<contents>"),
		}
	)
)

local url_snip = s("url", fmt([[ `{} <{}>`__ ]], { i(1), i(1) }))
local code_snip = s(
	"code",
	fmt(
		[[
.. code:: {}

   {}


]],
		{ i(1, "bash"), i(2) }
	)
)

local backtick_snip = s({ trig = "bt" }, fmt([[``{}``]], { i(1, "<code>") }))

-- snippets needs to be a list of values
local snippets = {
	meeting_snip,
	url_snip,
	entry_snip_pretty_task,
	code_snip,
	topic_snip,
	backtick_snip,
}

return snippets, nil
