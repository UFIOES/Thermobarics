include("Scripts/Objects/PlaceableObject.lua")
include("Scripts/Buffs/RadiationPoisoning.lua")

-------------------------------------------------------------------------------
if RadioactiveWaste == nil then
	RadioactiveWaste = PlaceableObject.Subclass("RadioactiveWaste")
end

-------------------------------------------------------------------------------
function RadioactiveWaste:Constructor(args)

end

function RadioactiveWaste:Fire(velocity)

	self:NKEnableScriptProcessing(true, 500)

	self.rigidbody = self:NKGetPhysics()
	self.rigidbody:NKActivate()
	self.rigidbody:NKSetMotionType(PhysicsComponent.DYNAMIC)

	self.rigidbody:NKSetVelocity(velocity, vec3.new(0,0,0))

end

function RadioactiveWaste:Update(dt)

	local collectedObjects = NKPhysics.SphereOverlapCollect(5, self:NKGetPosition(), {self.object})

	if collectedObjects then
		for key,collectedObject in pairs(collectedObjects) do
			local gameobjectsInstance = collectedObject:NKGetInstance()
			if gameobjectsInstance and gameobjectsInstance:InstanceOf(BaseCharacter) then
				gameobjectsInstance:ApplyBuff(BuffManager:CreateBuff("RadiationPoisoning", {duration = 90.0, damage = 1.5, ticksPerSecond = 5.0}))
			end
		end
	end

end

EntityFramework:RegisterGameObject(RadioactiveWaste)
