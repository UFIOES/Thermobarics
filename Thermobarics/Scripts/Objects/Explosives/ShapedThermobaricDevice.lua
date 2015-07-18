
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ShapedThermobaricDevice == nil then
	ShapedThermobaricDevice = ThermobaricDevice.Subclass("ShapedThermobaricDevice")
end

-------------------------------------------------------------------------------

function ShapedThermobaricDevice:OnPlace()

	local orientation = quat.new(1.0,0.0,0.0,0.0)

	local player = Eternus.World:NKGetLocalWorldPlayer()

	GLM.Rotate(orientation, math.deg(player:NKGetPhi()), vec3.new(0, 0, -1))
	GLM.Rotate(orientation, math.deg(player:NKGetTheta()) + 90, NKMath.Up)

	self:NKSetOrientation(orientation)

end

function ShapedThermobaricDevice:DamageTerrain()

	local modificationType = EternusEngine.Terrain.EVoxelOperationsStrings["Remove"]
	local brushType = EternusEngine.Terrain.EVoxelBrushShapesStrings["Sphere"]

	local direction = vec3.new(-1, 0, 0):mul_quat(self:NKGetOrientation())

	local player = Eternus.GameState:GetLocalPlayer()

	local object = nil

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

EntityFramework:RegisterGameObject(ShapedThermobaricDevice)
