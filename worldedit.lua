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


function PreventVandalism(a_Cuboid, a_Player)
	local Areas = g_PlayerAreas[a_Player:GetUniqueID()]
	a_Cuboid:Sort()
	local allow_Vandalism = true
	local denied_Areas = {}
	for _, Area in pairs(Areas) do
		if not(Area.m_IsAllowed) then
			table.insert(denied_Areas, Area.m_Cuboid)
		end
	end

	-- is_Allowed covers overlapping areas & interactions in non protected places
	Areas:ForEachArea(function(area_Cuboid, is_Allowed)
		if a_Cuboid:DoesIntersect(area_Cuboid) then -- The World Edit selection is in one of our areas!
			if is_Allowed then
				-- Check to make sure we're not in an overlapping area
				for _, a_Cuboid in pairs(denied_Areas) do
					if area_Cuboid:DoesIntersect(a_Cuboid) then
						allow_Vandalism = false
					end
				end
			end
			allow_Vandalism = is_Allowed
		end
	end)

	if not(allow_Vandalism) then
		a_Player:SendMessageFailure("You cannot use WorldEdit in areas that you don't have access to!")
	end
	return not(allow_Vandalism)
end
