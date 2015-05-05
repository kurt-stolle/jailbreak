AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "ZoneEntity" )
end

function ENT:Initialize()

	local Radius = 5

	if ( SERVER ) then

		self:SetModel( "models/props_junk/watermelon01.mdl" )

		local min = Vector( 1, 1, 1 ) * Radius * -0.5
		local max = Vector( 1, 1, 1 ) * Radius * 0.5

		self:PhysicsInitBox( min, max )

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys) ) then

			phys:Wake()
			phys:EnableGravity( false )
			phys:EnableDrag( false )

		end

		self:SetCollisionBounds( min, max )
		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		self.isPositioned=false

	else

		self.GripMaterial = Material( "sprites/grip" )
		self:SetCollisionBounds( Vector( -Radius, -Radius, -Radius ), Vector( Radius, Radius, Radius ) )

	end


end

function ENT:Draw()

	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

	if ( !IsValid( wep ) ) then return end

	local weapon_name = wep:GetClass()

	if ( weapon_name ~= "weapon_physgun" ) then
		return
	end

	render.SetMaterial( self.GripMaterial )
	render.DrawSprite( self:GetPos(), 16, 16, color_white )

end

function ENT:PhysicsUpdate( physobj )

	if ( CLIENT ) then return end

	if ( !self:IsPlayerHolding() and !self:IsConstrained() ) then

		physobj:SetVelocity( Vector(0,0,0) )
		physobj:Sleep()

	end

end
