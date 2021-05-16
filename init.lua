local S = minetest.get_translator("smoke_signals")

local dye_colors = {
	white		= "FFF",
	grey		= "BBB",
	dark_grey	= "777",
	black		= "000",
	violet		= "F0F",
	blue		= "00F",
	cyan		= "0FF",
	dark_green	= "070",
	green		= "0F0",
	yellow		= "FF0",
	brown		= "B84",
	orange		= "F90",
	red			= "F00",
	magenta		= "C28",
	pink		= "F88",
}

local function fire_particles_on(pos) -- 3 layers of fire
	local meta = minetest.get_meta(pos)
	local id1 = minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 9,
		time = 0,
		minpos = {x = pos.x - 0.2, y = pos.y - 0.4, z = pos.z - 0.2},
		maxpos = {x = pos.x + 0.2, y = pos.y - 0.1, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 0.7, z= 0},
		minexptime = 0.5,
		maxexptime = 0.7,
		minsize = 2,
		maxsize = 5,
		collisiondetection = false,
		vertical = true,
		texture = "smoke_fire_particle_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.8,},
	})
	meta:set_int("layer_1", id1)

	local id2 = minetest.add_particlespawner({ -- 2 layer smol particles fire
		amount = 1,
		time = 0,
		minpos = {x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.1, y = pos.y + 0.4, z = pos.z + 0.1},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.4,
		maxexptime = 0.6,
		minsize = 0.5,
		maxsize = 0.7,
		collisiondetection = false,
		vertical = true,
		texture = "smoke_fire_particle_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.7,},
	})
	meta:set_int("layer_2", id2)

	local id3 = minetest.add_particlespawner({ --3 layer smoke
		amount = 1,
		time = 0,
		minpos = {x = pos.x - 0.1, y = pos.y - 0.2, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.2, y = pos.y + 0.4, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.6,
		maxexptime = 0.8,
		minsize = 2,
		maxsize = 4,
		collisiondetection = true,
		vertical = true,
		texture = "smoke_fire_particle_anim_smoke.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.9,},
	})
	meta:set_int("layer_3", id3)
end

local function fire_particles_off(pos)
	local meta = minetest.get_meta(pos)
	local id_1 = meta:get_int("layer_1");
	local id_2 = meta:get_int("layer_2");
	local id_3 = meta:get_int("layer_3");
	minetest.delete_particlespawner(id_1)
	minetest.delete_particlespawner(id_2)
	minetest.delete_particlespawner(id_3)
end

local function start_fire_effects(pos, node, clicker, chimney)
	local this_spawner_meta = minetest.get_meta(pos)
	local id = this_spawner_meta:get_int("smoky")
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name

	if id ~= 0 then
		minetest.delete_particlespawner(id)
		this_spawner_meta:set_int("smoky", 0)
		this_spawner_meta:set_int("sound", 0)
		return
	end

	if above == "air" and (not id or id == 0) then
		id = minetest.add_particlespawner({
			amount = 4, time = 0, collisiondetection = true,
			minpos = {x=pos.x-0.25, y=pos.y+0.4, z=pos.z-0.25},
			maxpos = {x=pos.x+0.25, y=pos.y+5, z=pos.z+0.25},
			minvel = {x=-0.2, y=0.3, z=-0.2}, maxvel = {x=0.2, y=1, z=0.2},
			minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0.5,z=0},
			minexptime = 1, maxexptime = 3,
			minsize = 4, maxsize = 8,
			texture = "smoke_particle.png",
		})
		if chimney == 1 then
			this_spawner_meta:set_int("smoky", id)
			this_spawner_meta:set_int("sound", 0)
		else
			fire_particles_on(pos)
			this_spawner_meta:set_int("sound", s_handle)
		end
	end
end

local function stop_smoke(pos)
	local this_spawner_meta = minetest.get_meta(pos)
	local id = this_spawner_meta:get_int("smoky")

	if id ~= 0 then
		minetest.delete_particlespawner(id)
	end

	this_spawner_meta:set_int("smoky", 0)
end

local function smoke_ploom(pos, name)
	local texture_name = "smoke_fire_ploom_grey.png^[colorize:#".. dye_colors[name]..":50"
	minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 25, time = 0.01, collisiondetection = false,
		minpos = {x=pos.x-0.25, y=pos.y+0.3, z=pos.z-0.5},
		maxpos = {x=pos.x+0.25, y=pos.y+0.5, z=pos.z},
		minvel = {x=-0.02, y=0.73, z=-0.05}, maxvel = {x=0.02, y=0.78, z=0.02},
		minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0,z=0},
		minexptime = 14, maxexptime = 16,
		minsize = 1, maxsize = 2,
		texture = texture_name,
	})
	minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 25, time = 0.01, collisiondetection = false,
		minpos = {x=pos.x-0.25, y=pos.y+0.3, z=pos.z},
		maxpos = {x=pos.x+0.25, y=pos.y+0.5, z=pos.z+0.5},
		minvel = {x=-0.02, y=0.73, z=-0.02}, maxvel = {x=0.02, y=0.78, z=0.05},
		minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0,z=0},
		minexptime = 14, maxexptime = 16,
		minsize = 1, maxsize = 2,
		texture = texture_name,
	})
	minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 25, time = 0.01, collisiondetection = false,
		minpos = {x=pos.x-0.5, y=pos.y+0.3, z=pos.z-0.25},
		maxpos = {x=pos.x, y=pos.y+0.5, z=pos.z+0.25},
		minvel = {x=-0.05, y=0.73, z=-0.02}, maxvel = {x=0.02, y=0.78, z=0.02},
		minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0,z=0},
		minexptime = 14, maxexptime = 16,
		minsize = 1, maxsize = 2,
		texture = texture_name,
	})
	minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 25, time = 0.01, collisiondetection = false,
		minpos = {x=pos.x, y=pos.y+0.3, z=pos.z-0.25},
		maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.25},
		minvel = {x=-0.02, y=0.73, z=-0.02}, maxvel = {x=0.05, y=0.78, z=0.02},
		minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0,z=0},
		minexptime = 14, maxexptime = 16,
		minsize = 1, maxsize = 2,
		texture = texture_name,
	})
	s_handle = minetest.sound_play("smoke_fire_smoke_ploom", {
		pos = pos,
		max_hear_distance = 10,
		loop = false
	})
end

local sbox = {
	type = 'fixed',
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
}

minetest.register_node("smoke_signals:smoke_fire", {
	inventory_image = "smoke_fire_inv.png",
	description = S("Smoke Fire"),
	drawtype = "mesh",
	mesh = "smoke_fire.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {oddly_breakable_by_hand=3, flammable=0},
	sunlight_propagates = true,
	light_source = 13,
	walkable = false,
	buildable_to = false,
	damage_per_second = 3,
	selection_box = sbox,
	tiles = {
		"default_cobble.png",
		"default_junglewood.png",
	},
	on_construct = function(pos)
		fire_particles_on(pos)
	end,
	on_destruct = function(pos, oldnode, oldmetadata, digger)
		fire_particles_off(pos)
	end,
})

--Click functions
local dyes = dye.dyes

for i = 1, #dyes do
	local name, desc = unpack(dyes[i])
	minetest.override_item("wool:" .. name, {
		on_place = function(itemstack, placer, pointed_thing)
			if(pointed_thing.under ~= nil) then
				local node = minetest.get_node(pointed_thing.under)
				if(node.name == "smoke_signals:smoke_fire") then
					smoke_ploom(pointed_thing.under, name)
					return itemstack
				else
					minetest.item_place(itemstack, placer, pointed_thing)
				end
			else
				minetest.item_place(itemstack, placer, pointed_thing)
			end
		end,
		node_placement_prediction = "",
	})
end

-- CRAFTS

minetest.register_craft({
	output = 'smoke_signals:smoke_fire',
	recipe = {
		{"", "default:torch", ""},
		{"default:stick", "default:torch", "default:stick"},
		{"default:cobble", "default:stick", "default:cobble"},
	}
})

-- OTHER

minetest.register_lbm({
	name = "smoke_signals:reload_particles",
	label = "restart fire particles on reload",
	nodenames = {"smoke_signals:smoke_fire"},
	run_at_every_load = true,
	action = function(pos, node)
		fire_particles_off(pos)
		fire_particles_on(pos)
	end
})
