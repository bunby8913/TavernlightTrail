-- this variable represent how many the spell will execute
local executionCounter = 10
-- Create a combat object to be executed
local combat = Combat()
-- Set the type of damage and the effect being played
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
-- Store reference of creature and variant, this allow us to re-execute combat outside the `onCastSpell` function
local creatureRef = nil
local variantRef = nil
-- Design for the effect combat area for this spell
local diamondArea = {
	{ 0, 0, 0, 0, 1, 0, 0, 0, 0 },
	{ 0, 0, 1, 1, 0, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 2, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 0, 1, 1, 0, 1, 1, 0, 0 },
	{ 0, 0, 0, 0, 1, 0, 0, 0, 0 },
}
-- Create the combat area and assign it to the combat object
local spellArea = createCombatArea(diamondArea)
combat:setArea(spellArea)
-- This is the new way to determine the min and max damage the spell can deal
function onGetFormulaValues(player, level, maglevel)
	local min = (level / 5) + (maglevel * 5.5) + 25
	local max = (level / 5) + (maglevel * 11) + 50
	return -min, -max
end

-- This function calls itself repeatedly to execute the spell multiple times
function repeatCombatExecute(count)
	if count > 0 then
		combat:execute(creatureRef, variantRef)
		-- Calls itself to execute spell every 300 ms
		addEvent(repeatCombatExecute, 300, count - 1)
	end
end
-- set the callback to use the function we created to calculate damage
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	-- Set creature and variant, allow spell to be executed outside of here
	creatureRef = creature
	variantRef = variant
	-- Call the function to repeatedly to execute the spell
	repeatCombatExecute(executionCounter)
	return combat:execute(creature, variant)
end
