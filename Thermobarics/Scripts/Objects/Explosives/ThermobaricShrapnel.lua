
include("Scripts/Objects/Explosives/ThermobaricDevice.lua")

-------------------------------------------------------------------------------
if ThermobaricShrapnel == nil then
	ThermobaricShrapnel = ThermobaricDevice.Subclass("ThermobaricShrapnel")
end

-------------------------------------------------------------------------------
function ThermobaricShrapnel:Constructor(args)

	self.fuse = 3

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

function ThermobaricShrapnel:Explode()

	local collectedObjects = NKPhysics.SphereOverlapCollect(4, self:NKGetPosition(), {self.object} )

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

	self.deleteMeLater = 2

	self:NKSetShouldRender(false)
	self:NKSetEmitterActive(false)

	self:NKEnableScriptProcessing(true, 1000)

end

EntityFramework:RegisterGameObject(ThermobaricShrapnel)
