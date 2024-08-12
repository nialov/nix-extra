------------------------------------------------------
--  Utilities for general neovim lua configuration  --
------------------------------------------------------
local plenary = require("plenary")
local path = require("plenary.path")
local treesit = require("nvim-treesitter")
local Popup = require("nui.popup")

local separator = "\n"

local function mytransform(line)
	local matched =
		line:gsub("%s*[%[%(%{]*%s*$", ""):gsub("def ", ""):gsub("class ", ""):match("([%a_%d]+)"):gsub(" ", "")
	return matched
end

local function starts_with(str, start)
	return str:sub(1, #start) == start
end

local M = {}
-- Get short filename string
-- Shortens a filename using 'plenary'.
function M.filename()
	local current_file = vim.fn.expand("%")
	if current_file == nil or #current_file == 0 then
		return ""
	end
	local home = vim.fn.expand("~")
	if starts_with(current_file, home) then
		current_file = vim.fn.substitute(current_file, home, "~/")
	end
	local filepath_table = vim.fn.split(current_file, "/")
	if #filepath_table < 3 or #vim.fn.join(filepath_table) < 40 then
		return current_file
	end
	-- use plenary.path
	-- if path then
	return path:new(current_file):shorten()
	-- else
	-- 	return nil
	-- end
end

function M.get_curr_parent()
	local opts = {
		indicator_size = 100,
		type_patterns = { "class", "function", "method" },
		transform_fn = mytransform,
		separator = separator,
	}
	local curr = treesit.statusline(opts)
	if not curr then
		error("Expected treesitter to return a string statusline. Got nil.")
	end
	local lines = {}
	for s in curr:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines[#lines]
end

function M.pytest_target()
	-- local poetry_lock_file = "poetry.lock"
	-- if not vim.fn.filereadable("poetry.lock") then
	--     error(string.format("Could not find local readable % file.",
	--                         poetry_lock_file))
	-- end

	local curr_parent = M.get_curr_parent()

	if not curr_parent or #curr_parent == 0 then
		-- Get current filename stem (no extension)
		return vim.fn.expand("%:t:r")
	end

	return curr_parent
end
function M.locational_pytest()
	-- Check for readable poetry.lock
	local poetry_lock_file = "poetry.lock"
	if vim.fn.filereadable("poetry.lock") == 0 then
		error(string.format("Could not find local readable %s file.", poetry_lock_file))
	end

	-- Get the testing target function, module, etc. string
	local target = M.pytest_target()

	-- Current filename without any parents
	local current_file = vim.fn.expand("%:t")

	-- Determine which of nox, invoke or pytest to use for test
	local test_tool
	if current_file == "noxfile.py" then
		test_tool = string.format("nox --session %s", target)
	elseif current_file == "tasks.py" then
		test_tool = string.format("invoke %s", string.gsub(target, "_", "-"))
	else
		test_tool = string.format("pytest -k %s", target)
	end

	-- Create command string
	local cmd_string = string.format("Dispatch poetry run %s", test_tool)

	-- Execute command string
	vim.cmd(cmd_string)
end

function M.delete_non_project_buffers()
	-- Check that vim-rooter is installed and that it defines
	-- g:FindRootDirectory
	local find_root_directory_function_name = "g:FindRootDirectory"
	if vim.fn.exists("*" .. find_root_directory_function_name) ~= 1 then
		error("Expected vim-rooter to be installed to find current root directory.")
	end

	-- Call vim-rooter to find current root dir
	local current_root = vim.fn[find_root_directory_function_name]()
	-- Get list of current buffer handles (numbers)
	local buffer_list = vim.api.nvim_list_bufs()

	-- Report to user
	vim.notify(string.format("Found root folder as %s", current_root), vim.log.levels.INFO)
	vim.notify(
		string.format("Found %s buffers, searching for non-project-local buffers.", #buffer_list),
		vim.log.levels.INFO
	)

	-- Iterate over all buffer handles
	for _, value in pairs(buffer_list) do
		local buffer_name = vim.api.nvim_buf_get_name(value)
		-- Only interested if buffer is loaded and doesn't contain root dir
		-- path string
		if vim.api.nvim_buf_is_loaded(value) then
			local buffer_parents = plenary.path:new(buffer_name):parents()

			if vim.fn.index(buffer_parents, current_root) < 0 then
				vim.notify(string.format("Did not find %s in %s parents", current_root, buffer_name))
				vim.notify(string.format("Deleting buffer %s with number/handle %s", buffer_name, value))
				vim.api.nvim_buf_delete(value, {})
			end
		end
	end
	print("Finished search.")
end

function M.wikientry()
	local wiki_dir = os.getenv("VIMWIKI")
	if not (type(wiki_dir) == "string" and #wiki_dir > 0) then
		error(string.format("Expected VIMWIKI env var to be defined."))
	end

	local diary_dir = wiki_dir .. "/diary/entries"
	local diary_dir_path = plenary.path:new(diary_dir)

	local current_month_str = vim.fn.strftime("%Y%m")
	local current_month_filename = current_month_str .. ".rst"
	-- local entry_path = diary_dir .. "/" .. current_month_filename
	local entry_path = diary_dir_path / current_month_filename
	local entry_exists = entry_path:exists()

	local existence
	if entry_exists then
		existence = "exists"
	else
		existence = "did not exist"
	end
	vim.notify(string.format("Entry for this month %s at %s. Entering.", existence, entry_path))

	vim.cmd(string.format([[ :edit %s ]], entry_path))

	local current_month_str_pretty = vim.fn.strftime("%m.%Y")
	if not entry_exists then
		vim.api.nvim_buf_set_lines(
			0,
			0,
			2,
			false,
			{ string.format("📘 Diary 📅 %s", current_month_str_pretty), "===================", "" }
		)
	end
	-- Go to last modified line

	local success, _ = pcall(function(command)
		vim.cmd(command)
	end, [[ :normal g; ]])
	if not success then
		vim.notify("Could not find last modified line. Going to end of file.")
		vim.cmd([[ :normal G ]])
	end
end

function M.determine_tmpl_filetype()
	local tail = vim.fn.expand("%:t")
	local parts = vim.fn.split(tail, "\\.")
	local tmpl_ext = vim.fn.reverse(parts)[1]
	-- local template_extensions = { "tmpl", "jinja" }
	-- if vim.tbl_contains(template_extensions, tmpl_ext) then
	-- 	return
	-- end

	-- local true_file = vim.fn.substitute(tail, ".tmpl", "", "")
	local true_file = vim.fn.substitute(tail, string.format(".%s", tmpl_ext), "", "")
	local filetype = require("plenary.filetype").detect_from_extension(true_file)

	local cmd = string.format("set filetype=%s", filetype)
	vim.cmd(cmd)
end

M.vimwiki_env = "VIMWIKI"
M.vimwiki_html_env = "VIMWIKI_HTML"
M.ip_addr = "http://127.0.0.1:8080"

M.resolve_wiki_paths = function()
	-- Get environment table
	local environ_table = vim.fn.environ()

	-- Get values for both env variables
	local wikipath = environ_table[M.vimwiki_env]
	local wikipath_html = environ_table[M.vimwiki_html_env]

	if not wikipath_html then
		wikipath_html = string.format("%s_html", wikipath)
	end
	-- local syspython_bin = environ_table[syspython_bin_env]
	return vim.fn.expand(wikipath), vim.fn.expand(wikipath_html)
end

M.resolve_matching_html_file = function()
	-- Get absolute path to current file
	local curr_file = vim.fn.expand("%:p")
	-- Get path to rst wiki and built wiki
	local wikipath, wikipath_html = M.resolve_wiki_paths()

	-- Substitute rst path to the built html path
	local html_file_base = vim.fn.substitute(curr_file, wikipath, wikipath_html, "")
	-- Substitute extension
	local html_file = vim.fn.substitute(html_file_base, ".rst", ".html", "")
	return html_file
end

M.resolve_matching_ip_url = function(html_file)
	local _, wikipath_html = M.resolve_wiki_paths()
	-- Uses the resolved html_file path to create url
	return vim.fn.substitute(html_file, wikipath_html, M.ip_addr, "")
end

M.open_wiki_html = function()
	local html_file = M.resolve_matching_html_file()
	vim.notify(string.format("Opening html file at %s", html_file))
	vim.fn.system("xdg-open " .. html_file)
end

M.open_wiki_url = function()
	-- local html_file = M.resolve_matching_html_file()
	local html_url = M.resolve_matching_ip_url(M.resolve_matching_html_file())
	vim.notify(string.format("Opening html url at %s", html_url))
	-- TODO: xdg-open should just be overwritten by wsl-open-dynamic
	vim.cmd("Dispatch xdg-open " .. html_url)
end

local DEFAULT_END_INTERVAL = "24h"

-- Report completed taskwarrior tasks with a plain-text list.
function M.report_completed_tasks_tbl_pretty_task(end_interval)
	if not end_interval then
		end_interval = DEFAULT_END_INTERVAL
	end

	local pretty_task_executable = "pretty-task"
	local pretty_task_subcommand = "completed"
	if vim.fn.executable(pretty_task_executable) ~= 1 then
		error(string.format("Expected %s to be executable.", pretty_task_executable))
	end
	local cmd_result_tbl = vim.fn.systemlist(
		string.format("%s %s --end-interval=%s", pretty_task_executable, pretty_task_subcommand, end_interval)
	)

	-- Check if system command errored
	if vim.v.shell_error ~= 0 or #cmd_result_tbl == 0 then
		vim.notify(
			string.format("Failed to parse completed tasks with shell error code: %s", vim.v.shell_error),
			vim.log.levels.WARN
		)
		return { "Report failed or none completed within 24 hours." }
	end

	return cmd_result_tbl
end

M.parse_img_path = function(text)
	-- Either match figure or img in current line
	local fig_or_img_match = string.match(text, "figure") or string.match(text, "image")
	-- If no match then exit with print
	if not fig_or_img_match or #fig_or_img_match == 0 then
		vim.notify("No img or fig found on line " .. vim.fn.line(".") .. ".", vim.log.levels.WARN)
		return ""
	end
	-- If matched then find the filename at the end after figure or img
	local _, _, captured_filename = string.find(text, string.format(".*%s:: (.+)", fig_or_img_match))
	-- use plenary.path to join the relative img filepath with absolute
	-- path to current file. I.e. image path must be relative to current file's
	-- parent directory.
	local captured_filename_full
	if starts_with(captured_filename, "/") then
		local cwd = path:new(vim.fn.getcwd())
		local captured_filename_trunc = string.sub(captured_filename, 2)

		captured_filename_full = cwd:joinpath(captured_filename_trunc)
	else
		captured_filename_full = path:new(vim.fn.expand("%:p")):parent():joinpath(captured_filename)
	end
	-- print(string.format("Resolved img path: %s", captured_filename_full))
	return tostring(captured_filename_full)
end

M.get_img_path_at_current_line = function()
	-- Get current line
	local current_line = vim.api.nvim_get_current_line()
	return M.parse_img_path(current_line)
end

M.wiki_img_show = function(img_path)
	-- Check if img exists at path
	if not img_path or vim.fn.filereadable(tostring(img_path)) == 0 then
		-- If not then report to use and do nothing
		local msg = string.format("No img file found at: %s", img_path)
		vim.notify(msg)
		-- print("No img file found at: " .. tostring(img_path))
		return
	end
	local full_cmd = "!xdg-open " .. tostring(img_path)
	vim.cmd(full_cmd)
end

M.wiki_img_show_current_line = function()
	M.wiki_img_show(M.get_img_path_at_current_line())
end

M.synonyms = function()
	local current_word = vim.fn.expand("<cword>")
	if current_word == nil or #current_word == 0 then
		vim.notify("Expected to find a word (<cword>) under cursor.", vim.log.levels.WARN)
	end
	vim.notify(string.format("Finding synonyms for %s ...", current_word))
	local answer_list = vim.fn.systemlist(string.format("syn %s", current_word))
	-- vim.pretty_print(table.concat(answer, "\n"))

	local event = require("nui.utils.autocmd").event
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
		},
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
	})

	-- mount/open the component
	popup:mount()

	-- unmount component when cursor leaves buffer
	popup:on({ event.BufLeave }, function()
		popup:unmount()
	end, { once = true })

	-- Add the queried word in the answer
	table.insert(answer_list, 1, "")
	table.insert(answer_list, 1, string.format("Query: %s", current_word))

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, answer_list)

	-- quit with q
	vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "q", "<cmd>quit<cr>", {})
end

M.fish_history_file = function()
	local tmp_history_file = vim.fn.system("mktemp --suffix .fish_history")
	vim.fn.system(string.format("fish -c 'history' | uniq > %s", tmp_history_file))
	return tmp_history_file
end

M.fish_history = function()
	local tmp_history_file = M.fish_history_file()
	vim.cmd(string.format(":edit %s", tmp_history_file))
end
M.find_github_url = function(line)
	local match = string.match(line, ".*(http[s]*://[w.]*github.com/%w*/%w*)")
	return match
end

M.gh_browse_cloned_directory = function()
	local line = vim.fn.getline(".")
	local github_url = M.find_github_url(line)
	vim.notify(string.format("Found GitHub url: %s. Cloning it.", github_url))
	local tmp_dir = vim.fn.system("mktemp -d")
	vim.cmd(string.format("Dispatch git clone %s %s", github_url, tmp_dir))
	vim.cmd(string.format(":edit %s", tmp_dir))
end

return M
