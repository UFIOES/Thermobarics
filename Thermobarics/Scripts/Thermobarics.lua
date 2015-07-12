include("Scripts/Buffs/RadiationPoisoning.lua")

-------------------------------------------------------------------------------
if Thermobarics == nil then
	Thermobarics = EternusEngine.ModScriptClass.Subclass("Thermobarics")
end

-------------------------------------------------------------------------------
function Thermobarics:Constructor()
	Thermobarics.instance = self
	self.delay = 0
end

 -------------------------------------------------------------------------------
 -- Called once from C++ at engine initialization time
function Thermobarics:Initialize()
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/Thermobaric_crafting.txt")
	if not self.contaminatedAreas then self.contaminatedAreas = {} end
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters
function Thermobarics:Enter()

end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function Thermobarics:Leave()
end

-------------------------------------------------------------------------------
-- Called from C++ every update tick
function Thermobarics:Process(dt)

	self.delay = self.delay + dt

	if self.delay > 1 then

		self.delay = 0

		for i, contamination in pairs(self.contaminatedAreas) do

			local collectedObjects = NKPhysics.SphereOverlapCollect(contamination.radius, contamination.position, {})

			if collectedObjects then
				for key,collectedObject in pairs(collectedObjects) do
					local gameobjectsInstance = collectedObject:NKGetInstance()
					if gameobjectsInstance and gameobjectsInstance:InstanceOf(Buffable) then
						gameobjectsInstance:ApplyBuff(RadiationPoisoning.new({duration = 90.0, damage = 1.5, ticksPerSecond = 0.2}))
					end
				end
			end

		end

	end

end

function Thermobarics:AddRadation(position, radius)

	table.insert(self.contaminatedAreas, {position = position, radius = radius})

end

function Thermobarics:Save(outData)

	outData.contaminatedAreas = self.contaminatedAreas

end

function Thermobarics:Restore(inData, version)

	if inData.contaminatedAreas then
		self.contaminatedAreas = inData.contaminatedAreas
	else
		self.contaminatedAreas = {}
	end

end


EntityFramework:RegisterModScript(Thermobarics)
