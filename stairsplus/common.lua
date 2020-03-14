--[[
More Blocks: registrations

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = moreblocks.S

local descriptions = {
	["micro"] = "@1 Microblock",
	["slab"] = "@1 Slab",
	["slope"] = "@1 Slope",
	["panel"] = "@1 Panel",
	["stair"] = "@1 Stairs",
}

local alternate_i18n = {
    	["slab_quarter"] = "@1 Slab Quarter",
    	["slab_three_quarter"] = "@1 Slab Three Quarter",
    	["slab_two_sides"] = "@1 Slab Two Sides",
    	["slab_three_sides"] = "@1 Slab Three Sides",
    	["slab_three_sides_u"] = "@1 Slab Three Sides U",
    	["slope_half"] = "@1 Slop Half",
    	["slope_half_raised"] = "@1 Slop Half Raised",
    	["slope_inner"] = "@1 Slope Inner",
    	["slope_inner_half"] = "@1 Slope Inner Half",
    	["slope_inner_half_raised"] = "@1 Slope Inner Half Raised",
    	["slope_inner_cut"] = "@1 Slope Inner Cut",
    	["slope_inner_cut_half"] = "@1 Slope Inner Cut Half",
    	["slope_inner_cut_half_raised"] = "@1 Slope Inner Cut Half Raised",
    	["slope_outer"] = "@1 Slope Outer",
    	["slope_outer_half"] = "@1 Slope Outer Half",
    	["slope_outer_half_raised"] = "@1 Slope Outer Half Raised",
    	["slope_outer_cut"] = "@1 Slope Outer Cut",
    	["slope_outer_cut_half"] = "@1 Slope Outer Cut Half",
    	["slope_outer_cut_half_raised"] = "@1 Slope Outer Cut Half Raised",
    	["slope_cut"] = "@1 Slope Cut",
    	["stair_half"] = "@1 Stair Half",
    	["stair_right_half"] = "@1 Stair Right Half",
    	["stair_inner"] = "@1 Stair Inner",
    	["stair_outer"] = "@1 Stair Outer",
}


stairsplus.register_single = function(category, alternate, info, modname, subname, recipeitem, fields, fulldesc)
	-- parameters examples:
	--   category: eg. `"micro"`
	--   fulldesc: eg. `S("Stone Microblock")` or `S("Stone Slab (@1/16)", info)`  
	--      if nil, fallback is provided but translation will be approximative
	local desc_base = S(descriptions[category], fields.description)
	local def = {}

	if category ~= "slab" then
		def = table.copy(info)
	end

	-- copy fields to def
	for k, v in pairs(fields) do
		def[k] = v
	end

	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = def.paramtype2 or "facedir"

	-- This makes node rotation work on placement
	def.place_param2 = nil

	-- Darken light sources slightly to make up for their smaller visual size
	def.light_source = math.max(0, (def.light_source or 0) - 1)

	def.on_place = minetest.rotate_node
	def.groups = stairsplus:prepare_groups(fields.groups)

	if category == "slab" then
		if type(info) ~= "table" then
			def.node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, (info/16)-0.5, 0.5},
			}
			def.description = fulldesc or S("@1 (@2/16)", desc_base, info)
		else
			def.node_box = {
				type = "fixed",
				fixed = info,
			}
			def.description = fulldesc or
				(alternate_i18n[category..alternate] and S(alternate_i18n[category..alternate], fields.description)) or
				desc_base .. alternate:gsub("_", " "):gsub("(%a)(%S*)", function(a, b) return a:upper() .. b end)
		end
	else
		def.description = fulldesc or 
				(alternate_i18n[category..alternate] and S(alternate_i18n[category..alternate], fields.description)) or
				desc_base
		if category == "slope" then
			def.drawtype = "mesh"
		elseif category == "stair" and alternate == "" then
			def.groups.stair = 1
		end
	end

	if fields.drop and not (type(fields.drop) == "table") then
		def.drop = modname.. ":" .. category .. "_" .. fields.drop .. alternate
	end

	minetest.register_node(":" ..modname.. ":" .. category .. "_" .. subname .. alternate, def)
	stairsplus.register_recipes(category, alternate, modname, subname, recipeitem)
end
