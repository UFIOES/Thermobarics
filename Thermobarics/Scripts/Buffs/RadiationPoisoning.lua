include("Scripts/Buffs/Buff.lua")

-------------------------------------------------------------------------------
if RadiationPoisoning == nil then
	RadiationPoisoning = Buff.Subclass("RadiationPoisoning")
	EternusEngine.BuffManager:RegisterBuff("RadiationPoisoning", RadiationPoisoning)
end

RadiationPoisoning.Name = "RadiationPoisoning"
RadiationPoisoning.Group = "Radation"
RadiationPoisoning.EmitterNames = {
	"Radiation Aura 1 Emitter",
	"Radiation Aura 2 Emitter",
	"Radiation Aura 3 Emitter",
	"Radiation Aura 4 Emitter",
	"Radiation Aura 5 Emitter",
	"Radiation Aura 6 Emitter"
}

function RadiationPoisoning:Constructor(args)

	self.m_duration = 1.0
	self.m_infinite = true

	self.lastEmitter = ""

	self.dose = args.dose

	self.time = 0

	self.delay = 10 * math.exp((1-self.dose)*0.00392)

end

function RadiationPoisoning:GetEmitter()

	return self.EmitterNames[math.max(math.min(math.floor(self.dose/200 + 1), 6), 1)]

end

function RadiationPoisoning:SwitchEmitter()

	self.m_object:NKDeactivateEmitterByName(self.lastEmitter)

	self.lastEmitter = self:GetEmitter()

	self.m_object:NKActivateEmitterByName(self.lastEmitter)

end

-------------------------------------------------------------------------------
function RadiationPoisoning:OnStart()
	if self.EmitterNames then

		self.emitters = {}

		for i = 1, 6 do

			self.emitters[i] = Eternus.GameObjectSystem:NKCreateGameObject(self.EmitterNames[i], true)

			self.emitters[i]:NKSetShouldSave(false)

			self.emitters[i]:NKSetPosition(self.m_object:NKGetWorldPosition() + vec3.new(0,1.75,0))

			self.m_object:NKAddChildObject(self.emitters[i])

			self.emitters[i]:NKPlaceInWorld(true, false)

			self.m_object:NKDeactivateEmitterByName(self.EmitterNames[i])

		end

		self.lastEmitter = self:GetEmitter()

		self.m_object:NKActivateEmitterByName(self.lastEmitter)

	end
end

function RadiationPoisoning:OnStop()

	RadiationPoisoning.__super.OnStop(self)

	if self.EmitterNames then

		self.m_object:NKDeactivateEmitterByName(self.lastEmitter)

		for i = 1, 6 do

			self.m_object:NKRemoveChildObject(self.emitters[i])

			self.emitters[i]:NKDeleteMe()

		end

	end
end
-------------------------------------------------------------------------------
function RadiationPoisoning:ConflictsWith( otherBuff, ret )
	RadiationPoisoning.__super.ConflictsWith(self, otherBuff, ret)
	if (ret.val ~= EternusEngine.EBuffConflict.eMatch and self.Group and otherBuff.Group == self.Group) then
		ret.val = EternusEngine.EBuffConflict.eConflict
	end
end

-------------------------------------------------------------------------------
function RadiationPoisoning:Reapply(newBuff)
	self.dose = self.dose + newBuff.dose
end

-------------------------------------------------------------------------------
function RadiationPoisoning:Update(dt, finished)

	RadiationPoisoning.__super.Update(self, dt, finished)

	if not (Eternus.IsServer and self.m_object) then return end

	if self.m_object:IsDead() or self.dose < 1 then

		finished.val = true

	elseif not finished.val then

		self.time = self.time + dt

		self.dose = self.dose * math.exp(-0.0693 * dt)

		if self.time >= self.delay then

			self:SwitchEmitter()

			self.time = self.time - self.delay

			self.delay = 10.0 * math.exp((1-self.dose)*0.00392)

			if self.m_object.ServerEvent_TakeDamage then

				local damage = 20.0 * math.exp((self.dose-1000)*0.00530)

				self.m_object:ApplyDamage({damage = damage, category = "Debuff"})

			end

			if self.m_object.DropLoot and self.m_object.GetHitPoints and self.m_object:GetHitPoints()<=0 and self.m_object:IsDead() and not self.m_object.m_deleteMe then
				self.m_object:DropLoot(true)
			end
		end
	end
end


return RadiationPoisoning
