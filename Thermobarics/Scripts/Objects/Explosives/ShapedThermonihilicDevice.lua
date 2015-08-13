
include("Scripts/Objects/Explosives/ShapedThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ShapedThermonihilicDevice == nil then
	ShapedThermonihilicDevice = ShapedThermobaricDevice.Subclass("ShapedThermonihilicDevice")
end

-------------------------------------------------------------------------------

function ShapedThermonihilicDevice:DamageTerrain()

	local modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Remove"]
	local brushType = EternusEngine.Terrain.EVoxelBrushShapesStrings["Sphere"]

	local direction = vec3.new(-1, 0, 0):mul_quat(self:NKGetOrientation())

	local player = Eternus.GameState:GetLocalPlayer()

	local object = nil

	if player and player.object then object = player.object end

	for i = 1, 20 do

		--build the table for the voxel removal
		local input = {
			modificationType = modificationType,
			materialID = 0,
			position = self:NKGetPosition() + direction:mul_scalar(i),
			dimensions = vec3.new(1.0,1.0,1.0),
			radius = 5,
			brushType = brushType,
			player = object,
			userdata1 = self:NKGetNetId()
		}

		Eternus.Terrain:NKModifyWorld(input)

	end

end

EntityFramework:RegisterGameObject(ShapedThermonihilicDevice)
