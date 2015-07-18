include("Scripts/Thermobarics.lua")
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermonuclearDevice == nil then
	ThermonuclearDevice = ThermobaricDevice.Subclass("ThermonuclearDevice")
end

function ThermonuclearDevice:Constructor(args)

	self.fuse = 12

	self.radius = 50

	self.minDamage = 750

	self.maxDamage = 5000

end

function ThermonuclearDevice:Spawn()

	self:NKSetEmitterActive(false)

	self:NKGetNet():NKForceGlobalRelevancy(true)

end
-------------------------------------------------------------------------------

function ThermonuclearDevice:DamageObjects()

	local collectedObjects = NKPhysics.SphereOverlapCollect(self.radius - 0.5, self:NKGetWorldPosition(), {self.object})

	if collectedObjects then
		for key,collectedObject in pairs(collectedObjects) do
			if collectedObject:NKGetInstance() then
				local gameobjectsInstance = collectedObject:NKGetInstance()
				if gameobjectsInstance:InstanceOf(AICharacter) then
					gameobjectsInstance:NKDeleteMe()
				elseif gameobjectsInstance:InstanceOf(BasePlayer) then
					gameobjectsInstance:ApplyBuff(RadiationPoisoning.new({dose = self:CalculateDamage(gameobjectsInstance:NKGetWorldPosition())}))
				elseif gameobjectsInstance:InstanceOf(EternusEngine.GameObjectClass) then
					gameobjectsInstance:NKDeleteMe()
				end
			end
		end
	end

end

function ThermonuclearDevice:DamageTerrain()

	local player = Eternus.GameState:GetLocalPlayer()

	local modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Remove"]
	local brushType = EternusEngine.Terrain.EVoxelBrushShapesStrings["Cube"]

	local position = self:NKGetWorldPosition()

	local dimensions = vec3.new(4.0,4.0,4.0)

	local object = nil

	if player and player.object then object = player.object end

	for x = -self.radius, self.radius, 4 do
		for y = -self.radius, self.radius, 4 do
			for z = -self.radius, self.radius, 4 do

				if x*x + y*y + z*z <= self.radius*self.radius then

					--build the table for the voxel removal
					local input = {
						modificationType = modificationType,
						materialID = 0,
						position = position + vec3.new(x, y, z),
						dimensions = dimensions,
						radius = 4,
						brushType = brushType,
						player = object,
						userdata1 = self:NKGetNetId()
					}

					pcall(Eternus.Terrain.NKModifyWorld, Eternus.Terrain, input)

				end

			end
		end
	end

end

function ThermonuclearDevice:Explode()

	self:NKGetNet():NKForceGlobalRelevancy(true)

	self:DamageObjects()

	self:DamageTerrain()

	--Thermobarics.instance:AddRadation(self:NKGetWorldPosition(), self.radius * 1.5)

--[[
	for u = 0, 9 do
		for v = 1, 3 do

			local tau = 6.283185

			local theta = tau * u/10 + v

			local phi = v/3

			local velocity = vec3.new(math.cos(theta) * phi, math.cos(phi * tau/4.0), math.sin(theta) * phi)

			local waste = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Radioactive Waste", true, true):NKGetInstance()

			waste:NKSetPosition(self:NKGetPosition() + velocity)

			waste:NKPlaceInWorld(false, false)
			waste:NKSetShouldRender(true, true)

			waste:Fire(velocity:mul_scalar(10)+vec3.new(0, 20, 0))

		end
	end
]]

	--self:NKDeleteMe()

	self.deleteMeLater = 300

	self:NKSetShouldRender(false, true)
	self:NKRemoveFromWorld(false, true)

	self:NKEnableScriptProcessing(true, 1000)

end

function ThermonuclearDevice:VoxelsModifiedCallback(voxels, modificationType, modifyingPlayer, userdata1)

end

EntityFramework:RegisterGameObject(ThermonuclearDevice)
