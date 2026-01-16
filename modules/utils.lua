-- Debug utility to print table
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
