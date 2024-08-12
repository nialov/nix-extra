local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- more requires
--

local doc_snip = s(
	{ trig = "doc", name = "doc" },
	sn(1, {
		t({ [["""]], "" }),
		i(1, { [[]], "" }),
		t({ [["""]] }),
	})
)

local enum_snip = s(
	{ trig = "enum", name = "enum" },
	fmt(
		[[

        @unique
        class {}(Enum):

            """
            Enums for {}.
            """

            {} = "{}"

        ]],
		{ i(1, "MyEnum"), rep(1), i(2, "MEMBER"), i(3, "value") }
	)
)

local paramtest = s(
	"paramtest",
	fmt(
		[[
    @pytest.mark.parametrize("{}", tests.test_{}_params())
    def test_{}({}):
        """
        Test {}.
        """
        result = {}()

    ]],
		{
			i(1),
			rep(2),
			i(2),
			rep(1),
			rep(2),
			rep(2),
		}
	)
)

local ipython_embed = s("iembed", t("import IPython;IPython.embed()"))

local dodo_py = s(
	"dodo",
	fmt(
		[[
    """
    doit tasks for the project.
    """

    from typing import List, Any

    from pathlib import Path

    ACTIONS = "actions"
    FILE_DEP = "file_dep"
    TASK_DEP = "task_dep"
    TARGETS = "targets"
    NAME = "name"
    PARAMS = "params"

    # base data
    DATA_PATH = Path("data")

    # outputs
    OUTPUTS_PATH = Path("outputs")

    # scripts
    SRC_PATH = Path("src")


    def command(parts: List[Any]) -> str:
        """
        Compile command-line command from parts.
        """
        return " ".join(list(map(str, parts)))

]],
		{}
	)
)

local snippets = {
	doc_snip,
	enum_snip,
	paramtest,
	ipython_embed,
	dodo_py,
}

return snippets, nil
