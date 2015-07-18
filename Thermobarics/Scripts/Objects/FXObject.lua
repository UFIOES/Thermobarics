include("Scripts/Objects/PlaceableObject.lua")

-------------------------------------------------------------------------------
if FXObject == nil then
	FXObject = PlaceableObject.Subclass("FXObject")
end

-------------------------------------------------------------------------------
function FXObject:Constructor(args)

	self.lifeSpan = args.lifeSpan or 5

end

function FXObject:Spawn()

	self:NKSetShouldRender(false)

	self:NKGetPhysics():NKActivate()

	self:NKGetSound():NKPlay3DSound("ThermobaricExplosion", false, vec3.new(0, 0, 0), 25.0, 50.0)

	Eternus.ParticleSystem:NKPlayWorldEmitter(self:NKGetWorldPosition(), "Small Explosion Emitter")

	self:NKEnableScriptProcessing(true, 1000)

end

function FXObject:Update(dt)

	self.lifeSpan = self.lifeSpan - dt

	if self.lifeSpan < 0 then

		self:NKDeleteMe()

	end

end

EntityFramework:RegisterGameObject(FXObject)
