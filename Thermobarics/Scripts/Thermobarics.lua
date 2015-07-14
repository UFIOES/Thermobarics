include("Scripts/Buffs/RadiationPoisoning.lua")
include("Scripts/Buffs/Buffable.lua")

function Buffable:ApplyBuff( newBuff )
	if (not Eternus.IsServer) then
		return
	end

	-- Veryify that we received a buff.
	if not newBuff:InstanceOf(Buff) then
		return
	end

	-- Set its object so it knows what to affect.
	-- If the buff has a modifier, it will check to make sure we have the
	-- appropriate stat and return success or failure here.
	local canBeApplied = {val = true}-- Assume true since some buffs might not affect stats.
	newBuff:SetObject(self, canBeApplied)

	-- If the buff couldn't find the stat, it can't be applied.
	if (not canBeApplied.val) then
		NKPrint("The buff couldn't find the appropriate stat to affect, bailing!")
		return
	end

	-- We've verified that the buff CAN be added, now send a message to clients
	-- to add this buff.
	-- TODO: NEED TO MAKE THIS PULL THE ACTUAL CLASS NAME
	self:RaiseClientEvent("ClientEvent_AddBuff", {name = newBuff.Name, duration = newBuff.m_duration, target = self.object})

	-- Found the appropriate stat, check for conflicting buffs and remove them.
	for key, buff in pairs(self.m_buffs) do
		local conflictFound = {val = EternusEngine.EBuffConflict.eNone}
		newBuff:ConflictsWith(buff, conflictFound)
		-- If there was a conflict, check what type.
		if (conflictFound.val ~= EternusEngine.EBuffConflict.eNone) then
			-- If the buffs conflict with one another, remove the existing buff.
			if (conflictFound.val == EternusEngine.EBuffConflict.eConflict) then
				buff:OnStop()
				self.m_buffs[key] = nil
				self:RaiseClientEvent("ClientEvent_RemoveBuff", {name = buff.Name})
			-- If the new buff is already applied to the target, reapply it and
			-- return.  Let the buff decide what to do on reapplication.
			elseif (conflictFound.val == EternusEngine.EBuffConflict.eMatch) then
				buff:Reapply(newBuff)
				return
			end
		end
	end

	-- Insert it into the list.
	table.insert(self.m_buffs, newBuff)

	newBuff:OnStart()
end

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

	for i, contamination in pairs(self.contaminatedAreas) do

		local tau = 6.283185

		local theta = tau * math.random()

		local phi = tau * (math.random() - 0.5)/2.0

		local radius = contamination.radius * math.exp((math.random() - 1) * 1.5)

		local position = vec3.new(radius * math.cos(theta)*math.cos(phi), radius * math.sin(phi), radius * math.sin(theta)*math.cos(phi)) + contamination.position

		Eternus.ParticleSystem:NKPlayWorldEmitter(position, "Temp Radiation Aura Emitter")

		if self.delay > 1 then

			local collectedObjects = NKPhysics.SphereOverlapCollect(contamination.radius, contamination.position, {})

			if collectedObjects then
				for key,collectedObject in pairs(collectedObjects) do
					local gameobjectsInstance = collectedObject:NKGetInstance()
					if gameobjectsInstance and gameobjectsInstance:InstanceOf(Buffable) then

						local distance = (gameobjectsInstance:NKGetPosition() - contamination.position):NKLength()

						local dose = 100.0 * math.exp(-distance * 0.0599)

						gameobjectsInstance:ApplyBuff(RadiationPoisoning.new({dose = dose}))

					end
				end
			end

		end

	end

	if self.delay > 1 then self.delay = 0 end

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
