local ls = require("luasnip")
local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- more requires
--
-- create own snippets
local duvac_snip = s({ trig = "duvac", name = "duvac" }, t("docs: update version and changelog"))

local snippets = {
	-- snippets as usual
	duvac_snip,
}

return snippets, nil
