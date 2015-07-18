
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermobaricShrapnel == nil then
	ThermobaricShrapnel = ThermobaricDevice.Subclass("ThermobaricShrapnel")
end

-------------------------------------------------------------------------------
function ThermobaricShrapnel:Constructor(args)

	self.fuse = 3

	self.radius = 4

	self.minDamage = 10

	self.maxDamage = 25

end

function ThermobaricShrapnel:Spawn()

	self:NKSetEmitterActive(true)

end

function ThermobaricShrapnel:Fire(velocity)

	self:NKEnableScriptProcessing(true, 1000)

	self.rigidbody = self:NKGetPhysics()
	self.rigidbody:NKActivate()
	self.rigidbody:NKSetMotionType(PhysicsComponent.DYNAMIC)
	self.rigidbody:NKSetContactEventsEnabled(true)

	self.rigidbody:NKSetVelocity(velocity, vec3.new(0,0,0))

end

function ThermobaricShrapnel:Interact(args)

	return false

end

function ThermobaricShrapnel:OnContactStart(collision)
	if not collision.contact then return end

	if collision.contact.distance > 0.2 and self.fuse < 2.5 then
		self:Explode()
	end

end

EntityFramework:RegisterGameObject(ThermobaricShrapnel)
