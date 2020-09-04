
globals = {
	"minetest",
	"find_nodes_in_area_cache",
	"jumpdrive"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- deps
	"monitoring"
}
