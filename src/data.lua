local function base_leg_index_for_angle(degrees)
  degrees = degrees % 360
  local offset = 33.22
  if degrees <= offset then return 3
  elseif degrees <= 90 then return 4
  elseif degrees <= 180 - offset then return 8
  elseif degrees <= 180 then return 7
  elseif degrees <= 180 + offset then return 6
  elseif degrees <= 270 then return 5
  elseif degrees <= 360 - offset then return 1
  else return 2
  end
end


local function generate_leg_at_position(mount_x, mount_y, index, leg_count)
  local angle = math.deg(math.atan2(mount_y, mount_x))
  local base_leg_index = base_leg_index_for_angle(angle)
  local ground_x = mount_x / 12
  local ground_y = mount_y / 16
  return {
    leg = "spidertron-leg-" .. base_leg_index,
    mount_position = util.by_pixel(mount_x, mount_y),
    ground_position = {ground_x, ground_y},
    walking_group = (index - 1)%(leg_count/2) + 1
  }
end

local function generate_legs(leg_count, width, length, offset)
  local legs = {}
  for i = 1, leg_count do
    local mount_x = -width
    if i > leg_count / 2 then
      mount_x = width
    end
    local mount_y = 0
    if leg_count > 2 then
      local position = ((i - 1)%(leg_count/2))/(leg_count/2 - 1)
      mount_y = position * length - offset
    end
    table.insert(legs, generate_leg_at_position(mount_x, mount_y, i, leg_count))
  end
  return legs
end

---@type SpiderUnitPrototype|UnitPrototype
local spiderbiter = table.deepcopy(data.raw["unit"]["big-spitter"])

spiderbiter.type = "spider-unit"

spiderbiter.name = "spiderbiter"

spiderbiter.spider_engine = {
  legs = generate_legs(6, 15, 60, 30),
  walking_group_overlap = 1 - 1/6
}

spiderbiter.height = 1


spiderbiter.graphics_set = {
  base_animation = {
    layers = {
      spiderbiter.run_animation.layers[1],
    }
  },
  animation = {
    layers = {
      spiderbiter.run_animation.layers[2],
      spiderbiter.run_animation.layers[3],
    }
  },
}
spiderbiter.graphics_set.animation.layers[2].tint = {0.3, 0.5, 0.5}


spiderbiter.graphics_set.shadow_animation = spiderbiter.run_animation.layers[4]

spiderbiter.graphics_set.base_render_layer = "higher-object-under"
spiderbiter.graphics_set.render_layer = "higher-object-above"

spiderbiter.torso_rotation_speed = 0.6

spiderbiter.max_health = 3000

spiderbiter.factoriopedia_simulation = nil

spiderbiter.is_military_target = true
spiderbiter.subgroup = "enemies"

spiderbiter.attack_parameters = table.deepcopy(data.raw["gun"]["rocket-launcher"].attack_parameters)
spiderbiter.attack_parameters.ammo_type = table.deepcopy(data.raw["ammo"]["rocket"].ammo_type)

spiderbiter.attack_parameters.min_attack_distance = nil
spiderbiter.vision_distance = 60

table.insert(spiderbiter.resistances, {
  type = "fire",
  percent = 98,
})

table.insert(spiderbiter.resistances, {
  type = "laser",
  percent = 75,
})

spiderbiter.buildable_entities = {"spiderbiter-spawner"}

spiderbiter.healing_per_tick = 0.1

local spiderbiter_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
spiderbiter_spawner.name = "spiderbiter-spawner"
spiderbiter_spawner.result_units = {{
  unit = "spiderbiter",
  spawn_points = {{0, 1}}
}}
spiderbiter_spawner.max_health = 500

for _, animation in ipairs(spiderbiter_spawner.graphics_set.animations) do
  animation.layers[2].tint = {0.3, 0.5, 0.5}
end
spiderbiter_spawner.captured_spawner_entity = nil

local captive_spiderbiter_spawner = table.deepcopy(data.raw["assembling-machine"]["captive-biter-spawner"])
captive_spiderbiter_spawner.name = "captive-spiderbiter-spawner"
captive_spiderbiter_spawner.energy_source = {
  type = "electric",
  usage_priority = "secondary-input",
  drain = "1MW"
}
captive_spiderbiter_spawner.crafting_categories = {"captive-spawner-process"}
captive_spiderbiter_spawner.fixed_recipe = "spiderbiter-egg"
captive_spiderbiter_spawner.surface_conditions = nil
captive_spiderbiter_spawner.dying_trigger_effect.entity_name = "spiderbiter-spawner"
captive_spiderbiter_spawner.dying_trigger_effect.protected = false
captive_spiderbiter_spawner.graphics_set.animation.layers[1].tint = {0.3, 0.5, 0.5}
captive_spiderbiter_spawner.max_health = 60


data:extend{
  spiderbiter,
  spiderbiter_spawner,
  captive_spiderbiter_spawner,
  {
    type = "recipe",
    name = "spiderbiter-synthesis",
    icon = "__base__/graphics/icons/big-spitter.png",
    categories = {"organic", "chemistry"},
    subgroup = "agriculture-processes",
    order = "a[agriculture-processes]",
    auto_recycle = false,
    energy_required = 30,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "biter-egg", amount = 1},
      {type = "item", name = "copper-cable", amount = 12},
      {type = "item", name = "iron-gear-wheel", amount = 12},
      {type = "item", name = "electronic-circuit", amount = 1},
      {type = "item", name = "exoskeleton-equipment", amount = 3},
      {type = "item", name = "rocket-launcher", amount = 1},
    },
    results =
    {
      {type = "item", name = "spiderbiter-egg", amount = 1, allow_productivity = false, percent_spoiled = 0.65}
    },
    allow_productivity = false,
    allow_quality = false,
    crafting_machine_tint =
    {
      primary = {0.3, 0.5, 0.5, 1},
      secondary = {0.3, 0.5, 0.5, 1}
    },
  },
  {
    type = "recipe",
    name = "spiderbiter-egg",
    icons = {
      {
        icon = "__space-age__/graphics/icons/biter-egg.png",
        tint = {0.3, 0.5, 0.5},
      }
    },
    categories = {"captive-spawner-process"},
    order = "c[eggs]-b[biter-egg]",
    hide_from_player_crafting = true,
    auto_recycle = false,
    preserve_products_in_machine_output = true,
    energy_required = 10,
    ingredients = {},
    results =
    {
      {type = "item", name = "spiderbiter-egg", amount = 5}
    },
    enabled = false
  },
  {
    type = "recipe",
    name = "captive-spiderbiter-spawner",
    categories = {"cryogenics"},
    energy_required = 10,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "captive-biter-spawner", amount = 1},
      {type = "item", name = "uranium-235", amount = 15},
      {type = "item", name = "biochamber", amount = 1},
      {type = "item", name = "assembling-machine-3", amount = 1},
    },
    results =
    {
      {type = "item", name = "captive-spiderbiter-spawner", amount = 1, reset_freshness_on_craft = true}
    },
    auto_recycle = false,
  },
  {
    type = "recipe",
    name = "spiderbiter-egg-processing",
    order = "b[nauvis-agriculture]-e[spiderbiter-egg-processing]",
    energy_required = 10,
    enabled = false,
    categories = {"crafting-with-fluid"},
    ingredients =
    {
      {type = "item", name = "spiderbiter-egg", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 100}
    },
    results = {{type="item", name="uranium-ore", amount=50}}
  },
  {
    type = "item",
    name = "spiderbiter-egg",
    icons = {
      {
        icon = "__space-age__/graphics/icons/biter-egg.png",
        tint = {0.3, 0.5, 0.5},
      }
    },
    subgroup = "agriculture-products",
    order = "c[eggs]-b[biter-egg]-b",
    inventory_move_sound = data.raw["item"]["biter-egg"].inventory_move_sound,
    pick_sound = data.raw["item"]["biter-egg"].pick_sound,
    drop_sound = data.raw["item"]["biter-egg"].drop_sound,
    stack_size = 50,
    weight = 10 * kg,
    spoil_ticks = 5 * minute,
    spoil_to_trigger_result =
    {
      items_per_trigger = 25,
      trigger =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            {
              type = "create-entity",
              entity_name = "spiderbiter",
              affects_target = true,
              show_in_tooltip = true,
              show_details_in_tooltip = false,
              as_enemy = true,
              find_non_colliding_position = true,
              abort_if_over_space = true,
              offset_deviation = {{-1, -1}, {1, 1}},
              non_colliding_fail_result =
              {
                type = "direct",
                action_delivery =
                {
                  type = "instant",
                  source_effects =
                  {
                    {
                      type = "create-entity",
                      entity_name = "spiderbiter",
                      affects_target = true,
                      show_in_tooltip = false,
                      as_enemy = true,
                      offset_deviation = {{-1, -1}, {1, 1}},
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  {
    type = "item",
    name = "captive-spiderbiter-spawner",
    icons = {
      {
        icon = "__space-age__/graphics/icons/captive-biter-spawner.png",
        tint = {0.3, 0.5, 0.5},
      }
    },
    subgroup = "agriculture",
    order = "z[biter-nest]-b",
    inventory_move_sound = data.raw["item"]["captive-biter-spawner"].inventory_move_sound,
    pick_sound = data.raw["item"]["captive-biter-spawner"].pick_sound,
    drop_sound = data.raw["item"]["captive-biter-spawner"].drop_sound,
    place_result = "captive-spiderbiter-spawner",
    stack_size = 1,
    spoil_ticks = 15 * minute,
    spoil_to_trigger_result =
    {
      items_per_trigger = 25,
      trigger =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            {
              type = "create-entity",
              entity_name = "spiderbiter",
              affects_target = true,
              show_in_tooltip = true,
              show_details_in_tooltip = false,
              as_enemy = true,
              find_non_colliding_position = true,
              abort_if_over_space = true,
              offset_deviation = {{-1, -1}, {1, 1}},
              non_colliding_fail_result =
              {
                type = "direct",
                action_delivery =
                {
                  type = "instant",
                  source_effects =
                  {
                    {
                      type = "create-entity",
                      entity_name = "spiderbiter",
                      affects_target = true,
                      show_in_tooltip = false,
                      as_enemy = true,
                      offset_deviation = {{-1, -1}, {1, 1}},
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
}

table.insert(data.raw["technology"]["biter-egg-handling"].effects, {
  type = "unlock-recipe",
  recipe = "spiderbiter-synthesis"
})

table.insert(data.raw["technology"]["biter-egg-handling"].effects, {
  type = "unlock-recipe",
  recipe = "spiderbiter-egg-processing"
})

table.insert(data.raw["technology"]["captivity"].effects, {
  type = "unlock-recipe",
  recipe = "spiderbiter-egg"
})


table.insert(data.raw["technology"]["captive-biter-spawner"].effects, {
  type = "unlock-recipe",
  recipe = "captive-spiderbiter-spawner"
})
