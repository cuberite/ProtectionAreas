 --[[
 Integrate with WorldEdit plugin
 WorldEdit will call PreventVandalism when it is about to change blocks in the world;
 If enabled, ProtectionAreas will check to see if the player trying to make the
 changes is allowed to make changes in any areas intersecting the World Edit selection.
]]--

function InitializeIntegration(a_Plugin)
	if cConfig.m_IntegrateWorldEdit then
		return cPluginManager:CallPlugin(
			"WorldEdit",
			"AddHook",
			"OnAreaChanging",
			a_Plugin:GetName(),
			"PreventVandalism")
	else
		return true
	end
end


function PreventVandalism(we_Cuboid, we_Player)
	local Areas = g_PlayerAreas[we_Player:GetUniqueID()]
	we_Cuboid:Sort()
	local denied_Areas = {}

	-- Return a table of areas the player cannot interact with
	Areas:ForEachArea(function(area_Cuboid, is_Allowed)
		if not(is_Allowed) then
			table.insert(denied_Areas, area_Cuboid)
		end
	end)
	-- Check if the WorldEdit selection intersects with the player's denied areas
	-- If so, let the player know, and return
	for _, area_Cuboid in pairs(denied_Areas) do
		if we_Cuboid:DoesIntersect(area_Cuboid) then
			we_Player:SendMessageFailure("You cannot use WorldEdit in areas that you don't have access to!")
			return true
		end
	end
end
