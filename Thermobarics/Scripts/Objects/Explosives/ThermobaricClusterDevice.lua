
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermobaricClusterDevice == nil then
	ThermobaricClusterDevice = ThermobaricDevice.Subclass("ThermobaricClusterDevice")
end

-------------------------------------------------------------------------------

function ThermobaricClusterDevice:Explode()

	self:DamageObjects()

	self:DamageTerrain()

	self:SpawnFX()

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

	self:NKDeleteMe()

end

EntityFramework:RegisterGameObject(ThermobaricClusterDevice)
