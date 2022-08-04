local rocket = {}
print("Hello from rocket developer !!")

local function bind(op, outer_opts)
	outer_opts = outer_opts or { noremap = true }
	return function(lhs, rhs, opts)
		opts = vim.tbl_extend("force", outer_opts, opts or {})
		vim.keymap.set(op, lhs, rhs, opts)
	end
end

function rocket.setup(opts)
	opts = opts or {}
	local nnoremap = bind("n")
	rocket.cmd = "cmd"

	nnoremap("<leader>ro", ':lua require("rocket").open_window()<CR>')
end

-- render
local api = vim.api
local buf, win

local function open_window()
	buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- get dimensions
	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	-- calculate our floating window size
	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	-- and its starting position
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	-- set some options
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}
	local url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json"
	local method = "get"
	vim.fn.jobstart(rocket.cmd, {
		on_stdout = function(_, data)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { data })
		end,
	})

	-- and finally create it with buffer attached
	win = api.nvim_open_win(buf, true, opts)
end

rocket.open_window = open_window
rocket.win = win

return rocket
-- Lua check loaded package
-- P(package.loaded["rocket"])
-- package.loaded["rocket"] = nil
