AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"

if SERVER then

	function ENT:Initialize()
      self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

      local min = self.min or Vector(-100,-50,-100)
      local max = self.max or Vector(100,100,100)

      self:SetMoveType(MOVETYPE_NONE)
			self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

			self:SetTrigger(true)

      self:PhysicsInitBox(min,max)
      self:SetCollisionBounds(min,max)

      local phys = self:GetPhysicsObject()
      if phys and phys:IsValid() then
				phys:Wake()
        phys:EnableMotion(false)
				phys:EnableGravity( false )
				phys:EnableDrag( false )
      end

      self.handle_min=ents.Create("jb_zone_handle")
      self.handle_min:SetPos(self:GetPos()+min)
			self.handle_min:SetZoneEntity(self)
      self.handle_min:Spawn()

      self.handle_max=ents.Create("jb_zone_handle")
      self.handle_max:SetPos(self:GetPos()+max)
			self.handle_max:SetZoneEntity(self)
      self.handle_max:Spawn()

			self.lastMin=self.handle_min:GetPos()
			self.lastMax=self.handle_max:GetPos()
  end

	local noReward={}
	function ENT:StartTouch( ply )
		if IsValid(ply) and ply:IsPlayer() and ply.GetInGuardZone then
      if not ply:GetInGuardZone() then
        ply:SendQuickNotification("You entered a guard-only zone.")
      end
      ply:SetInGuardZone(true)

      if not ply._guardZones then
        ply._guardZones={}
      end

      ply._guardZones[self:EntIndex()]=true
		end
	end

  function ENT:EndTouch( ply )
    if IsValid(ply) and ply:IsPlayer() and ply._guardZones and ply.GetInGuardZone then
      ply._guardZones[self:EntIndex()]=false

      for k,v in pairs(ply._guardZones)do
        if v then
          return
        end
      end
      ply:SetInGuardZone(false)

      if ply:Alive() then
        ply:SendQuickNotification("You left a guard-only zone.")
      end
    end
  end

	local a0=Angle(0,0,0)
	local p0=Vector(0,0,0)
	function ENT:Think()
		if self:GetAngles() ~= a0 or self:GetPos() ~= p0 then
			self:SetAngles(a0)
			self:SetPos(p0)

			local phys = self:GetPhysicsObject()
      if phys and phys:IsValid() then
				phys:Wake()
        phys:EnableMotion(false)
				phys:EnableGravity( false )
				phys:EnableDrag( false )
      end
		end

		if IsValid(self.handle_min) and IsValid(self.handle_max) and (self.lastMin ~= self.handle_min:GetPos() or self.lastMax ~= self.handle_max:GetPos()) then
			self:Resize(self.handle_min:GetPos(),self.handle_max:GetPos())
			self.lastMin=self.handle_min:GetPos()
			self.lastMax=self.handle_max:GetPos()
		end
	end

  function ENT:Resize(minWorld,maxWorld)
		local min = self:WorldToLocal( minWorld )
		local max = self:WorldToLocal( maxWorld )

    self:PhysicsInitBox(min,max)
    self:SetCollisionBounds(min,max)
  end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

elseif CLIENT then
	function ENT:Think()
		local mins,maxs=self:OBBMins(),self:OBBMaxs();
		self:SetRenderBoundsWS( mins,maxs )
	end
	local tx=Material( "color" )
  function ENT:Draw()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()

    if not IsValid(ply) or not IsValid(wep) or wep:GetClass()~="weapon_physgun" then return end

		local mins,maxs=self:OBBMins(),self:OBBMaxs();

		render.SetMaterial( tx )
		render.DrawBox( self:GetPos(),self:GetAngles(),mins,maxs,JB.Color["#FF4411AA"],true)
		render.DrawWireframeBox( self:GetPos(),self:GetAngles(),mins,maxs,JB.Color["#FFCCAAFF"],true)
	end

end
