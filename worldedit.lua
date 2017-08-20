 --[[
 Integrate with WorldEdit plugin
 WorldEdit will call PreventVandalism when it is about to change blocks in the world;
 If enabled, ProtectionAreas will check to see if the player trying to make the
 changes is allowed to make changes in any areas intersecting the World Edit selection.

 Thanks to bearbin for reviewing and helping with the logic.
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
	local ret = true

	-- Make sure that the relevant areas are loaded
    if not we_Cuboid:IsCompletelyInside(Areas.m_SafeCuboid) then
        we_Player:SendMessageFailure("WorldEdit selection too large for ProtectionAreas.")
        return true
    end

	Areas:ForEachArea(function(area_Cuboid, is_Allowed)
		area_Cuboid:Sort()
		if not(is_Allowed) then
			if we_Cuboid:DoesIntersect(area_Cuboid) then
				we_Player:SendMessageFailure("You cannot use WorldEdit in areas that you don't have access to!")
				ret = true
			end
		elseif is_Allowed then
			ret = we_Cuboid:IsCompletelyInside(area_Cuboid)
		end
	end)
	return ret
end
