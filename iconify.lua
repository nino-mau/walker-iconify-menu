Name = "iconify"
NamePretty = "Iconify"
Icon = "preferences-desktop-wallpaper"
Cache = false
Action = "wl-copy %VALUE%"
HideFromProviderlist = false
Description = "Search iconify icon and copy name to clipboard"
SearchName = true
KeepOpen = true

-- Actions available in the iconify menu
Actions = {
	-- To copy the iconify icon name
	copy_name = "wl-copy %VALUE%",
	-- To copy the raw svg code
	copy_svg = "lua:CopyIconSvg",
	-- To toggle the "search all" mode
	toggle_search_all = "lua:ToggleSearchAll",
	-- To toggle the "search lucide" mode
	toggle_search_lucide = "lua:ToggleSearchLucide",
	-- To toggle the "search hugeicons" mode
	toggle_search_hugeicons = "lua:ToggleSearchHugeicons",
	-- To toggle the "search phosphor" mode
	toggle_search_phosphor = "lua:ToggleSearchPhosphor",
	-- To toggle the "search tabler" mode
	toggle_search_tabler = "lua:ToggleSearchTabler",
}

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

-- Dir where the icon svg will be cached
local CACHE_DIR = os.getenv("HOME") .. "/.cache/elephant/iconify"

-- Link to the iconify API
local API_BASE = "https://api.iconify.design"

-- Amount of icons that will be returned by each search query to the iconify API
local ICONIFY_API_SEARCH_LIMIT = 64

-- By default only icons from these collections will be shown to improve performance
local DEFAULT_COLLECTIONS = { "lucide", "hugeicons" }

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

-- Ensure cache directory exists
os.execute("mkdir -p '" .. CACHE_DIR .. "'")

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

-- Print a table, used for debug
function tprint(tbl, indent)
	if not indent then
		indent = 0
	end

	-- Check if the input is actually a table
	if type(tbl) ~= "table" then
		print(string.rep("  ", indent) .. tostring(tbl))
		return
	end

	for k, v in pairs(tbl) do
		local formatting = string.rep("  ", indent) .. tostring(k) .. ": "

		if type(v) == "table" then
			print(formatting)
			tprint(v, indent + 1)
		else
			print(formatting .. tostring(v))
		end
	end
end

--------------------------------------------------------------------------------
-- ACTIONS FUNCTIONS
--------------------------------------------------------------------------------

function CopyIconSvg(value)
	local url = "https://api.iconify.design/" .. value:gsub(":", "/") .. ".svg"
	os.execute("curl -s " .. url .. " | wl-copy")
end

function ToggleSearchAll()
	local current_state = state() or {}
	if current_state[1] == "search_all_on" then
		setState({})
	else
		setState({ "search_all_on" })
	end
end

function ToggleSearchLucide()
	local current_state = state() or {}
	if current_state[1] == "search_lucide_on" then
		setState({})
	else
		setState({ "search_lucide_on" })
	end
end

function ToggleSearchHugeicons()
	local current_state = state() or {}
	if current_state[1] == "search_hugeicons_on" then
		setState({})
	else
		setState({ "search_hugeicons_on" })
	end
end

function ToggleSearchPhosphor()
	local current_state = state() or {}
	if current_state[1] == "search_phosphor_on" then
		setState({})
	else
		setState({ "search_phosphor_on" })
	end
end

function ToggleSearchTabler()
	local current_state = state() or {}
	if current_state[1] == "search_tabler_on" then
		setState({})
	else
		setState({ "search_tabler_on" })
	end
end

--------------------------------------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------------------------------------

--
-- Query iconify API for icons from all collections
--
local function searchIconsAll(query)
	if not query or query == "" then
		return {}
	end

	if query:find("/") then
		local coll, name = query:match("([^/]+)/(.+)")

		if name == nil then
			return {}
		end

		-- URL encode the query
		local encoded_query = name:gsub(" ", "%%20")
		local url = API_BASE .. "/search?query=" .. encoded_query .. "&prefix=" .. coll .. "&limit=64"

		local handle = io.popen("curl -s '" .. url .. "'")
		if handle then
			local json_string = handle:read("*a")
			handle:close()
			local data = jsonDecode(json_string)
			if data and data.icons then
				return data.icons
			end
		end
	end

	-- URL encode the query
	local encoded_query = query:gsub(" ", "%%20")
	local url = API_BASE .. "/search?query=" .. encoded_query .. "&limit=" .. ICONIFY_API_SEARCH_LIMIT

	local handle = io.popen("curl -s '" .. url .. "'")
	if handle then
		local json_string = handle:read("*a")
		handle:close()
		local data = jsonDecode(json_string)
		if data and data.icons then
			return data.icons
		end
	end
	return {}
end

--
-- Query iconify API for icons from specified collection
--
local function searchIconsColls(query, colls)
	if not query or query == "" then
		return {}
	end

	local encoded_query = query:gsub(" ", "%%20"):gsub(".*/", "")
	local colls_str = table.concat(colls, ",")
	local url = API_BASE .. "/search?query=" .. encoded_query .. "&prefixes=" .. colls_str .. "&limit=64"

	local handle = io.popen("curl -s '" .. url .. "'")
	if handle then
		local json_string = handle:read("*a")
		handle:close()
		local data = jsonDecode(json_string)
		if data and data.icons then
			return data.icons
		end
	end
	return {}
end

--
-- Fetch and cache icon svg
--
local function fetchSvg(prefix, name)
	local cache_path = CACHE_DIR .. "/" .. prefix .. "_" .. name .. ".svg"

	-- Check if already cached
	local svg_exists = io.open(cache_path, "r")
	if svg_exists then
		svg_exists:close()
		return cache_path
	end

	-- Fetch from API with fixed height for consistent preview sizing
	local url = API_BASE .. "/" .. prefix .. "/" .. name .. ".svg?height=128"
	os.execute("curl -s '" .. url .. "' -o '" .. cache_path .. "' 2>/dev/null")

	return cache_path
end

--
-- Build the menu entries, runs everytime the user input something
--
function GetEntries(query)
	local entries = {}
	local icons = {}

	local current_state = state() or {}

	if not query or query == "" then
		table.insert(entries, {
			Text = "Type to search icons...",
			Subtext = "Search across all Iconify icon sets",
			Value = "",
		})
		return entries
	end

	-- Search icons via API
	if current_state[1] == "search_all_on" then
		icons = searchIconsAll(query)
	elseif current_state[1] == "search_lucide_on" then
		icons = searchIconsColls(query, { "lucide" })
	elseif current_state[1] == "search_hugeicons_on" then
		icons = searchIconsColls(query, { "hugeicons" })
	elseif current_state[1] == "search_phosphor_on" then
		icons = searchIconsColls(query, { "ph" })
	elseif current_state[1] == "search_tabler_on" then
		icons = searchIconsColls(query, { "tabler" })
	else
		icons = searchIconsColls(query, DEFAULT_COLLECTIONS)
	end

	if #icons == 0 then
		table.insert(entries, {
			Text = "No icons found",
			Subtext = "Try a different search term",
			Value = "",
		})
		return entries
	end

	for _, icon_full_name in ipairs(icons) do
		local prefix, name = icon_full_name:match("([^:]+):(.+)")

		if prefix and name then
			-- Fetch and cache SVG
			local cache_path = fetchSvg(prefix, name)

			table.insert(entries, {
				Text = icon_full_name:gsub(":", "/"),
				Subtext = prefix,
				Value = icon_full_name,
				Icon = cache_path,
				IconPreview = cache_path,
			})
		end
	end

	return entries
end
