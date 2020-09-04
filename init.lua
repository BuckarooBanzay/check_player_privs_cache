
local old_check_player_privs = minetest.check_player_privs

local cache = {}

minetest.check_player_privs = function(player_or_name, ...)
	local playername = player_or_name
	if type(player_or_name) == "table" and player_or_name.get_player_name then
		playername = player_or_name:get_player_name()
	end

	local requested_privs = {...}
	print(dump(requested_privs))

	local result = cache[playername]
	if result == nil then
		-- cache miss
		result = {true, {}}
		result[1], result[2] = old_check_player_privs(player_or_name, unpack(requested_privs))
		print("db hit", player_or_name, result[1], dump(result[2]))
		cache[playername] = { result[1], result[2] }
	end

	return result[1], result[2]
end

local function invalidate()
	cache = {}
	minetest.after(2, invalidate)
end

minetest.after(2, invalidate)
