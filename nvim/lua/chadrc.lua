-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

M.ui = {
	tabufline = {
		enabled = false,
	},
	statusline = {
		modules = {
			file = function()
				local icon = "󰈚"
				local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
				local path = vim.api.nvim_buf_get_name(bufnr)
				local name = path == "" and "Empty" or vim.fn.fnamemodify(path, ":.")

				if name ~= "Empty" then
					local devicons_present, devicons = pcall(require, "nvim-web-devicons")
					if devicons_present then
						icon = devicons.get_icon(name) or icon
					end
				end

				-- CRLF badge: only shown when the buffer would write dos line
				-- endings, so a quiet statusline means unix
				local ff = vim.bo[bufnr].fileformat
				local ff_badge = ff ~= "unix" and ("%#St_lspWarning#[" .. ff .. "] ") or ""

				return "%#St_file# " .. icon .. " " .. name .. " " .. ff_badge
			end,
		},
	},
}

return M
