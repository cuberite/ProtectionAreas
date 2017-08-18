


function InitializeIntegration(a_Plugin)
	return cPluginManager:CallPlugin(
		"WorldEdit",
		"AddHook",
		"OnAreaChanging",
		a_Plugin:GetName(),
		"PreventVandalism")
end


function PreventVandalism(a_Cuboid, a_Player)
	local Areas = g_PlayerAreas[a_Player:GetUniqueID()]
	a_Cuboid:Sort()
	local allow_Vandalism = true

	Areas:ForEachArea(function( area_Cuboid, is_Allowed )
		if a_Cuboid:DoesIntersect(area_Cuboid) then -- The World Edit selection is in one of our areas!
			allow_vandalism = is_Allowed
		end
	end)

	if not(allow_Vandalism) then
		a_Player:SendMessageFailure("You cannot use WorldEdit in areas that you don't have access to!")
	end
	return not(allow_Vandalism)
end