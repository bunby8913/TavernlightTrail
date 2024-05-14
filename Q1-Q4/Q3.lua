-- Q3 - Fix or improve the name and the implementation of the below method

-- Re-named the function to properly reflect its purpose
function RemovePartyMemberByName(playerId, membername)
	local player = Player(playerId)
	-- check if Player is valid, report to caller if not
	if not player then
		return false, "Player not found."
	end

	-- check if part if valid, report to caller if not
	local party = player:getParty()
	if not party then
		return false, "Player is currently not in a party."
	end

	-- Boolean variable to store if the remove of the party member was successful
	local memberFound = false
	-- k can be replaced by a throwaway variable, as it is not required in the loop
	for _, member in pairs(party:getMembers()) do
		-- Since we are just comparing name of the member, we don't need to construct a player object for that
		if member:getName() == membername then
			memberFound = true
			party:removeMember(member)
			break -- Exit the loop as soon the party member is found and removed for optimization
		end
	end
	-- Return different message base on if the member has been found and removed from the party
	if not memberFound then
		return false, "Membre not found in the party."
	else
		return true, "Member removed successfully."
	end
end
