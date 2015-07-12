include("Scripts/Buffs/DamageDebuff.lua")

-------------------------------------------------------------------------------
if RadiationPoisoning == nil then
	RadiationPoisoning = DamageDebuff.Subclass("RadiationPoisoning")
	EternusEngine.BuffManager:RegisterBuff("RadiationPoisoning", RadiationPoisoning)
end

RadiationPoisoning.Name = "RadiationPoisoning"
DamageDebuff.Group = "Radation"
RadiationPoisoning.Emitter = "Radiation Aura Emitter"

function RadiationPoisoning:Constructor( args )

	if (args.duration == nil) then
		self.m_duration = 5.0
	end

	self.m_damage = args.damage or 1.0

	self.m_ticksPerSecond = args.ticksPerSecond or 1.0
	self.m_lastInterval = 0
	self.m_tickTimer = 0

	self.m_emitter = nil
end

function RadiationPoisoning:OnStart()
	if self.Emitter then
		self.m_emitter = Eternus.GameObjectSystem:NKCreateGameObject(self.Emitter, true)
		self.m_emitter:NKSetShouldSave(false)
		self.m_emitter:NKSetPosition(self.m_object:NKGetWorldPosition() + vec3.new(0,1.75,0))
		self.m_object:NKAddChildObject(self.m_emitter)
		self.m_emitter:NKPlaceInWorld(true, false)
		self.m_object:NKActivateEmitterByName(self.Emitter)
	end
end


return RadiationPoisoning
