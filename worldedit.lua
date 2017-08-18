


function InitializeIntegration(a_Plugin)
	return cPluginManager:CallPlugin(
		"WorldEdit",
		"AddHook",
		"OnAreaChanging",
		a_Plugin:GetName(),
		"PreventVandalism")
end


function PreventVandalism(a_Cuboid, a_Player)
	Areas = g_PlayerAreas[a_Player:GetUniqueID()]
	a_Cuboid:Sort()
	local allow_vandalism = true

	Areas:ForEachArea(function( area_Cuboid, is_allowed )
		if a_Cuboid:DoesIntersect(area_Cuboid) then -- The World Edit selection is in one of our areas!
			allow_vandalism = is_allowed
		end
	end)

	if not(allow_vandalism) then
		a_Player:SendMessageFailure("You cannot use WorldEdit in areas that you don't have access to!")
	end
	return not(allow_vandalism)
end