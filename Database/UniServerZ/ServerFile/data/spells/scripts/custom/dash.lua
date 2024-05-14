-- This is my attempt in creating the player trail effect
-- The idea behind of using a combatEffectType that is not valid is as follow
-- Since we want to render player sprites behind the player during the dash, the best way to determine where the dash sprite should go is to use combat area
-- This way, the tiles are marked and can be rendered as a effect
-- The idea is when the client code detect this effect type, instead of rendering a effect on that tile, it will execute the code to render a player sprite there
-- And once the effect is finished, the player sprite will disappear
local combatEffectType = 77
--local combatEffectType = CONST_ME_YALAHARIGHOST
-- We create 4 different combat object, since the combat area for each spell can only be set on construction
-- Each spell represent a dash towards different direction, they are selected base on player direction
local upDash = Combat()
upDash:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
upDash:setParameter(COMBAT_PARAM_EFFECT, combatEffectType)

local downDash = Combat()
downDash:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
downDash:setParameter(COMBAT_PARAM_EFFECT, combatEffectType)

local leftDash = Combat()
leftDash:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
leftDash:setParameter(COMBAT_PARAM_EFFECT, combatEffectType)

local rightDash = Combat()
rightDash:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
rightDash:setParameter(COMBAT_PARAM_EFFECT, combatEffectType)

-- This is a list of tiles that the player cannot traverse through, if any of those tiles are detected, the dash should stop
local unwanted_tilestates = {
	TILESTATE_PROTECTIONZONE,
	TILESTATE_HOUSE,
	TILESTATE_FLOORCHANGe,
	TILESTATE_TELEPORT,
	TILESTATE_BLOCKSOLID,
	TILESTATE_BLOCKPATH,
}
-- Store the dash direction outside any function, so it can be accessed by multiple function
local DashDirection = 0
-- They might look the opposite, but it seems like combat area in game are mirrored
-- The combat area is used in this case to determine where the effect (player sprite) should be drawn
local DownTrail = {
	{ 0, 0, 2, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
}

local UpTrail = {
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 2, 0, 0 },
}

local LeftTrail = {
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
	{ 1, 1, 1, 1, 2 },
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
}

local RightTrail = {
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
	{ 2, 1, 1, 1, 1 },
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
}
-- Create and assign combat area for each spell
local upDashArea = createCombatArea(UpTrail)
upDash:setArea(upDashArea)

local downDashArea = createCombatArea(DownTrail)
downDash:setArea(downDashArea)

local leftDashArea = createCombatArea(LeftTrail)
leftDash:setArea(leftDashArea)

local rightDashArea = createCombatArea(RightTrail)
rightDash:setArea(rightDashArea)

-- These variable determines how far the player can dash and how far each dash should be
-- We use variable to allow spell to be easily adjustable
local range = 8
local initialRange = 4
local creaturnRef = nil
local variantRef = nil

-- This is the main function which determines if the path in front of the player is clear and the player can dash forward
function playerDash(dashCount)
	--Use addEvent to keep executing until dash count reaches 0
	if dashCount > 0 then
		-- x and y value used to show which direction the player is moving towards
		local x, y = 0, 0
		-- This updates every time the player takes a step forward, very useful when the full range of the dash cannot be completed
		local stepTook = 0
		-- Here we get the reference of the player and store its current position and its current direction
		local player = Player(creaturnRef)
		local targetPos = player:getPosition()
		local currentPos = Position(player:getPosition())
		local targetDirection = player:getDirection()
		-- loop should abort as soon we detect a obstruction on the path
		local abortLoop = false

		-- 0 = North / Up, 1 = East/ Right, 2 = South / Down, 3 = West / Left
		-- Use player direction to determine +- x and y value each iteration
		if targetDirection == 0 then
			DashDirection = 0
			y = 1
		elseif targetDirection == 1 then
			DashDirection = 1
			x = 1
		elseif targetDirection == 2 then
			DashDirection = 2
			y = -1
		elseif targetDirection == 3 then
			DashDirection = 3
			x = -1
		end

		-- Now go through each tile between the end location and the current location, determine if any blockage
		for _ = 1, initialRange do
			-- Update the current position
			currentPos.x = currentPos.x + x
			currentPos.y = currentPos.y + y
			-- if the position is valid and we can find a tile at that position
			local tile = currentPos and Tile(currentPos)
			if not tile then
				-- If no tile found at position, abort loop
				abortLoop = true
				break
			end
			for _, tileState in pairs(unwanted_tilestates) do
				-- If any of the tiles in the way is part of the unwanted tile, return false
				-- If the tile is any of the types we mentioned above, we don't want to continue, should abort loop
				if tile:hasFlag(tileState) then
					abortLoop = true
					break
				else
				end
			end
			if abortLoop then
				break
			end
			-- If all well, add another step
			stepTook = stepTook + 1
		end

		-- Here we set where the next position the player base on the calculation earlier
		targetPos:getNextPosition(player:getDirection(), stepTook)
		-- Teleport the player there
		player:teleportTo(targetPos)
		-- Call for execution of a spell base on player direction
		if DashDirection == 0 then
			upDash:execute(creaturnRef, variantRef)
		elseif DashDirection == 1 then
			rightDash:execute(creaturnRef, variantRef)
		elseif DashDirection == 2 then
			downDash:execute(creaturnRef, variantRef)
		elseif DashDirection == 3 then
			leftDash:execute(creaturnRef, variantRef)
		end
		-- Recursively call this function until count reaches 0
		addEvent(playerDash, 50, dashCount - 1)
	end
end

function onCastSpell(creature, variant)
	-- Save the creature and variant to execute spell outside `onCastSpell`
	creaturnRef = creature
	variantRef = variant
	-- Dynamically determine how many time the dash function should be called
	playerDash(range / initialRange)
	-- Execute the dash spell base on player direction
	if DashDirection == 0 then
		return upDash:execute(creaturnRef, variantRef)
	elseif DashDirection == 1 then
		return rightDash:execute(creaturnRef, variantRef)
	elseif DashDirection == 2 then
		return downDash:execute(creaturnRef, variantRef)
	elseif DashDirection == 3 then
		return leftDash:execute(creaturnRef, variantRef)
	end
end
