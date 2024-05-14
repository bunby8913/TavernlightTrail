-- q1 - fix or improve the implementation of the below methods
-- Remove the `local` keyword from this function as it needs to be registered with the `Event` module
function releaseStorage(player)
	player:setStorageValue(1000, -1)
end

function onLogout(player)
	-- Check if player is valid before continuing
	if player then
		if player:getStorageValue(1000) == 1 then
			addEvent(releaseStorage, 1000, player)
		end
		return true
	else
		-- If player is not valid, we should let the caller know
		return false, "Player is not valid"
	end
end
