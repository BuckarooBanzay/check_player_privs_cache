local has_monitoring_mod = minetest.get_modpath("monitoring")

local hit_count, miss_count, cache_size

if has_monitoring_mod then
  hit_count = monitoring.counter("get_player_privs_cache_hit", "cache hits")
  miss_count = monitoring.counter("get_player_privs_cache_miss", "cache misses")
	cache_size = monitoring.gauge("get_player_privs_cache_size", "Count of all cached players")
end

local cache = {}

local old_get_player_privs = minetest.get_player_privs
minetest.get_player_privs = function(name)
	local privs = cache[name]
	if privs == nil then
		if has_monitoring_mod then
			miss_count.inc()
		end
		privs = old_get_player_privs(name)
		cache[name] = privs
	elseif has_monitoring_mod then
		hit_count.inc()
	end

	return privs
end

-- invalidation on set_privs and leave-player

local old_set_player_privs = minetest.set_player_privs
minetest.set_player_privs = function(name, privs)
	cache[name] = privs
	old_set_player_privs(name, privs);
end

minetest.register_on_leaveplayer(function(player)
	cache[player:get_player_name()] = nil
end)

-- monitoring stuff
if has_monitoring_mod then
	local function count_entries()
		local count = 0
		for _ in ipairs(cache) do
			count = count + 1
		end
		cache_size.set(count)
		minetest.after(5, count_entries)
	end

	minetest.after(5, count_entries)
end
