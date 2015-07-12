
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermobaricClusterDevice == nil then
	ThermobaricClusterDevice = ThermobaricDevice.Subclass("ThermobaricClusterDevice")
end

-------------------------------------------------------------------------------

function ThermobaricClusterDevice:Explode()

	local collectedObjects = NKPhysics.SphereOverlapCollect(4, self:NKGetPosition(), {self.object} )

	if collectedObjects then
		for key,collectedObject in pairs(collectedObjects) do
			if collectedObject:NKGetInstance() then
				local gameobjectsInstance = collectedObject:NKGetInstance()
				if gameobjectsInstance:InstanceOf(ThermobaricDevice) and gameobjectsInstance.fuse and not (gameobjectsInstance.fuse <= 0) then
					gameobjectsInstance.fuse = 0
					gameobjectsInstance:Explode()
				elseif gameobjectsInstance:InstanceOf(AICharacter) then
					gameobjectsInstance:OnHit(self, 20)
				elseif gameobjectsInstance:InstanceOf(BasePlayer) then
					gameobjectsInstance:RaiseServerEvent("ServerEvent_TakeDamage", {damage = 20, category = "Undefined"})
				elseif gameobjectsInstance:InstanceOf(EternusEngine.GameObjectClass) then
					gameobjectsInstance:ModifyHitPoints(-100)
				end
			end
		end
	end

	self:RaiseClientEvent("ClientEvent_Explode", {})

	local modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Remove"]
	local brushType = EternusEngine.Terrain.EVoxelBrushShapesStrings["Sphere"]

	local player = Eternus.GameState:GetLocalPlayer()

	local object = nil

	--build the table for the voxel removal
	local input = {
		modificationType = modificationType,
		materialID = 0,
		position = self:NKGetPosition(),
		dimensions = vec3.new(1.0,1.0,1.0),
		radius = 5,
		brushType = brushType,
		player = object,
		userdata1 = self:NKGetNetId()
	}

	Eternus.Terrain:NKModifyWorld(input)

	for u = 0, 7 do
		for v = 1, 3 do

			local tau = 6.283185

			local theta = tau * u/8 + v

			local phi = v/3

			local velocity = vec3.new(math.cos(theta) * phi, math.cos(phi * tau/4.0), math.sin(theta) * phi)

			local shrapnel = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Thermobaric Shrapnel", true, true):NKGetInstance()

			shrapnel:NKSetPosition(self:NKGetPosition() + velocity)

			shrapnel:NKPlaceInWorld(false, false)
			shrapnel:NKSetShouldRender(true, true)

			shrapnel:Fire(velocity:mul_scalar(15)+vec3.new(0, 7.5, 0))

		end
	end

--[[
	for i = 1, 20 do

		local tau = 6.283185

		local theta = tau * math.random()

		local phi = tau/4 * math.random()

		local velocity = vec3.new(math.cos(theta) * phi, math.cos(phi * tau/4.0), math.sin(theta) * phi)

		local shrapnel = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Thermobaric Shrapnel", true, true):NKGetInstance()

		shrapnel:NKSetPosition(self:NKGetPosition())

		shrapnel:NKPlaceInWorld(false, false)
		shrapnel:NKSetShouldRender(true, true)

		shrapnel:Fire(velocity:mul_scalar(15)+vec3.new(0, 5 + math.random(0, 5), 0))

	end
]]
	--self:NKDeleteMe()

	self.deleteMeLater = 5

	self:NKSetShouldRender(false)
	self:NKSetEmitterActive(false)

	self:NKEnableScriptProcessing(true, 1000)

end

EntityFramework:RegisterGameObject(ThermobaricClusterDevice)
