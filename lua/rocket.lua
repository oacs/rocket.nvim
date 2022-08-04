Rocket = {}
print("Hello from rocket developer !!")

local function bind(op, outer_opts)
        outer_opts = outer_opts or { noremap = true }
        return function(lhs, rhs, opts)
                opts = vim.tbl_extend("force", outer_opts, opts or {})
                vim.keymap.set(op, lhs, rhs, opts)
        end
end

function Rocket.setup(opts)
        opts = opts or {}
        local nnoremap = bind("n")
        Rocket.cmd = "curl"
        nnoremap("<leader>ro", ':lua require("rocket").open_window()<CR>')
end

-- render
local api = vim.api
local buf, win

function Rocket.open_window()
        buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

        api.nvim_buf_set_option(buf, "bufhidden", "wipe")
        api.nvim_buf_set_option(buf, "syntax", "json")

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
                relative = "editor",
                width = win_width,
                height = win_height,
                row = row,
                col = col,
        }
        local url = "https://api.publicapis.org/entries"
        local method = "get"
        vim.pretty_print(Rocket)
        local job_string="curl" .. " -sk --request " .. string.upper(method) .. " " .. url .. " | json_pp"
        vim.pretty_print(job_string)
        vim.fn.jobstart(job_string, {
                stdout_buffered= true,
                stderr_buffered= true,
                on_stdout = function(_,data)
                        vim.api.nvim_buf_set_lines(buf, -1, -1, false,  data )
                end,
                on_stderr = function(_, data)
                        vim.api.nvim_buf_set_lines(buf, -1, -1, false,   data  )
                end,
        })

        -- and finally create it with buffer attached
        return api.nvim_open_win(buf, true, opts)
end


return Rocket
-- Lua check loaded package
-- P(package.loaded["rocket"])
-- package.loaded["rocket"] = nil
