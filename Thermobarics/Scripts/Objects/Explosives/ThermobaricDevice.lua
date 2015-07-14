
include("Scripts/Objects/Equipable.lua")

-------------------------------------------------------------------------------
if ThermobaricDevice == nil then
	ThermobaricDevice = Equipable.Subclass("ThermobaricDevice")
end

ThermobaricDevice.RegisterScriptEvent("ClientEvent_Explode",
	{
	}
)

-------------------------------------------------------------------------------
function ThermobaricDevice:Constructor(args)

	self.fuse = 5

end

function ThermobaricDevice:Spawn()

	self:NKSetEmitterActive(false)

end
--[[
function ThermobaricDevice:Save(outData)

	if self.deleteMeLater then self:NKDeleteMe() end

end
]]
-------------------------------------------------------------------------------

function ThermobaricDevice:PrimaryAction(args)

	if args.player:InHoldingStance() then

		local offset = vec3.new(0, 0, 1.2)
		local facingRot = GLM.Angle(args.direction * vec3.new(1, 0, 1), NKMath.Right)
		local temp = offset:mul_quat(facingRot)

		local projectile = Eternus.GameObjectSystem:NKCreateNetworkedGameObject(args.player.m_equippedItem:NKGetName(), true, true)

		projectile:NKSetPosition(args.positionW + temp)
		projectile:NKSetOrientation(GLM.Angle(args.direction, NKMath.Right))

		projectile:NKPlaceInWorld(false, false)
		projectile:NKSetShouldRender(true, true)

		projectile.rigidbody = projectile:NKGetPhysics()
		projectile.rigidbody:NKActivate()
		projectile.rigidbody:NKSetMotionType(PhysicsComponent.DYNAMIC)

		projectile.rigidbody:NKSetVelocity(args.direction:mul_scalar(40), vec3.new(0,0,0))

		projectile:NKEnableScriptProcessing(true, 1000)

		projectile:NKSetEmitterActive(true)

		args.player:RemoveHandItem(1)

	end

end

function ThermobaricDevice:Interact(args)

	--if args.heldItem and args.heldItem:NKGetName() == "Firestone Shard" then

		self:NKEnableScriptProcessing(true, 1000)

		self:RaiseClientEvent("ClientEvent_PlayObjectSound", {soundName = "Click1", loop = false, offset = vec3.new(0,0,0), minDist = 10, maxDist = 15 })

		self:NKSetEmitterActive(true)

		return true

	--end

	--return false

end

function ThermobaricDevice:Update(dt)

	if self.deleteMeLater then

		self.deleteMeLater = self.deleteMeLater - dt

		if self.deleteMeLater < 0 then

			self:NKDeleteMe()

		end

		return

	end

	self.fuse = self.fuse - dt

	if self.fuse <= 0 then

		self:Explode()

	end

end

function ThermobaricDevice:Explode()

	local collectedObjects = NKPhysics.SphereOverlapCollect(4, self:NKGetPosition(), {self.object})

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

	--self:NKDeleteMe()

	self.deleteMeLater = 5

	self:NKSetShouldRender(false)
	self:NKSetEmitterActive(false)

	self:NKEnableScriptProcessing(true, 1000)

end

function ThermobaricDevice:ClientEvent_Explode(args)
	self:NKGetSound():NKPlay3DSound("FireballExplosion", false, vec3.new(0, 0, 0), 10.0, 100.0)
end

EntityFramework:RegisterGameObject(ThermobaricDevice)
