-- Q2 - Fix or improve the implementation of the below method

function printSmallGuildNames(memberCount)
	-- this method is supposed to print names of all guilds that have less than memberCount max members
	local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
	-- Updated the variable names to better reflect its purpose
	-- Here we execute the query and store the result
	local resultGuilds = db.storeQuery(string.format(selectGuildQuery, memberCount))
	-- First check if there are any results
	if resultGuilds ~= false then
		-- Iterate through every result using the repeat loop
		repeat
			-- Fixed the getString function parameters, get the guild name from the current row
			local guildName = result.getString(resultGuilds, "name")
			print(guildName)
		-- Get the next row of data, stop when the next is no longer valid (reach the end of the query)
		until not result.next(resultGuilds)
	else
		-- Let the caller know if there are no valid result
		print("No guild that have less than " .. memberCount .. " max members")
	end
	-- Finally, make sure to free any external resources as it is not garbage collected by Lua.
	result.free(resultGuilds)
end
