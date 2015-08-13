
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermobaricImplosionDevice == nil then
	ThermobaricImplosionDevice = ThermobaricDevice.Subclass("ThermobaricImplosionDevice")
end

-------------------------------------------------------------------------------
function ThermobaricImplosionDevice:DamageObjects()

	local collectedObjects = NKPhysics.SphereOverlapCollect(self.radius, self:NKGetWorldPosition(), {self.object})

	if collectedObjects then
		for key,collectedObject in pairs(collectedObjects) do
			if collectedObject:NKGetInstance() then
				local gameobjectsInstance = collectedObject:NKGetInstance()
				if gameobjectsInstance:InstanceOf(BaseCharacter) then
					gameobjectsInstance:RaiseServerEvent("ServerEvent_TakeDamage", {damage = self:CalculateDamage(gameobjectsInstance:NKGetWorldPosition()), category = "Undefined"})

					local push = gameobjectsInstance:NKGetWorldPosition() - self:NKGetWorldPosition()

					push = push:NKNormalize():mul_scalar(self.radius - push:NKLength())

					gameobjectsInstance:NKGetCharacterController():NKApplyImpulse(push:mul_scalar(10))

				elseif gameobjectsInstance:InstanceOf(EternusEngine.GameObjectClass) then
					gameobjectsInstance:NKDeleteMe()
				end
			end
		end
	end

end

function ThermobaricImplosionDevice:DamageTerrain()

	--build the table for the voxel removal
	local input = {
		modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Swap"],
		materialID = NKTerrainGetMaterialID("Obsidian"),
		position = self:NKGetWorldPosition(),
		dimensions = vec3.new(1.0,1.0,1.0),
		radius = 5,
		brushType = EternusEngine.Terrain.EVoxelBrushShapesStrings["Sphere"],
		player = nil,
		userdata1 = self:NKGetNetId()
	}

	Eternus.Terrain:NKModifyWorld(input)

	input.modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Place"]

	Eternus.Terrain:NKModifyWorld(input)

end

function ThermobaricImplosionDevice:SpawnFX()

	local fx = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Implosion FXObject", true, true)

	fx:NKSetPosition(self:NKGetWorldPosition())

	fx:NKPlaceInWorld(false, false)
	fx:NKSetShouldRender(false)

end

EntityFramework:RegisterGameObject(ThermobaricImplosionDevice)
