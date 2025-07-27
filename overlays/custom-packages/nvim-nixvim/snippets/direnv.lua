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

local disable_autoformat_export = s({
	trig = "export N",
	name = "export NEOVIM_DISABLE_AUTOFORMAT=1",
	desc = "Disable neovim autoformat by the export in e.g., .envrc.",
}, t({ "export NEOVIM_DISABLE_AUTOFORMAT=1" }))

local nix_direnv_manual_reload = s({
	trig = "nix_",
	name = "nix_direnv_manual_reload",
	desc = "Use manual reload of nix env",
}, t({ "nix_direnv_manual_reload" }))

local snippets = {
	-- snippets as usual
	disable_autoformat_export,
	nix_direnv_manual_reload,
}

return snippets, nil
