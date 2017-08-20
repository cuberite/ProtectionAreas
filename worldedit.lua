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

	-- Make sure that the relevant areas are loaded
    if not we_Cuboid:IsCompletelyInside(Areas.m_SafeCuboid) then
        we_Player:SendMessageFailure(g_Msgs.ErrWESelectionTooLarge)
        return true
    end

    local Allowed = false
    local Denied = false
	-- Return a table of areas the player cannot interact with
	Areas:ForEachArea(function(area_Cuboid, is_Allowed)
        area_Cuboid:Sort()
		if is_Allowed then
            if we_Cuboid:IsCompletelyInside(area_Cuboid) then
            	Allowed = true
                return true
            end
        elseif we_Cuboid:DoesIntersect(area_Cuboid) then
	        Denied = true
		end
	end)

	--[[This could be simplified by doing
	return not(Allowed or not Denied)
	But that would not allow the error message to be sent.]]--
    if Allowed or not Denied then
        return false
    end
 
    we_Player:SendMessageFailure(g_Msgs.ErrWENotAllowed)
    return true
end
