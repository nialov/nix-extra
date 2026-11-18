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

-- snippets needs to be a list of values
local snippets = {
	beamer_columns,
	pandoc_figure,
}

return snippets, nil
