-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################


-- NOTE: Loosely based on the default Garry's Mod hands.

AddCSLuaFile()

SWEP.PrintName		= "Fists";

SWEP.UseHands = true;

SWEP.Author			= "Excl"
SWEP.Purpose		= ""

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= ""

SWEP.ViewModelFOV	= 52
SWEP.Slot			= 0
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

local SwingSound = Sound( "weapons/slam/throw.wav" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:PreDrawViewModel( vm, wep, ply )
	if not self:GetRaised() then
		self.Correct = true;
		render.SetBlend(0);
	else
		self.Corrent = false;
	end
end

function SWEP:PostDrawViewModel( vm, wep, ply )
	if self.Corrent then
		render.SetBlend(1);
		self.Correct = false;
	end

end

SWEP.HitDistance = 48

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 0, "Combo" )
	self:NetworkVar( "Bool", 0, "Raised" );

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() )

end

function SWEP:PrimaryAttack( right )
	if not self:GetRaised() then
		if CLIENT and IsFirstTimePredicted() and !self.Owner.DoNotNotify then
			notification.AddLegacy("Press R to raise your fists",NOTIFY_HINT);
			self:SetNextPrimaryFire( CurTime() + 1.8 )
			self:SetNextSecondaryFire( CurTime() + 1.8 )
			self.Owner.DoNotNotify = true;
		end
		return;
	end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local anim = "fists_left"
	if ( right ) then anim = "fists_right" end
	if ( self:GetCombo() >= 2 ) then
		anim = "fists_uppercut"
	end

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

	self:EmitSound( SwingSound )

	self:UpdateNextIdle()
	self:SetNextMeleeAttack( CurTime() + 0.2 )

	self:SetNextPrimaryFire( CurTime() + 0.6 )
	self:SetNextSecondaryFire( CurTime() + 0.6 )

end

function SWEP:Reload()
	if self.NextReload and self.NextReload > CurTime() then return end

	self:SetRaised(not self:GetRaised());
	if CLIENT then
		if self:GetRaised() and IsFirstTimePredicted() then
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
		end
	end
	self.NextReload = CurTime() + 1;
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack( true )
end

function SWEP:DealDamage()

	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 )
		} )
	end

	if ( tr.Hit ) then self:EmitSound( HitSound ) end

	local hit = false

	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( math.random( 8,12 ) )

		if ( anim == "fists_left" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * 49125 + self.Owner:GetForward() * 99984 ) -- Yes we need those specific numbers
		elseif ( anim == "fists_right" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * -49124 + self.Owner:GetForward() * 99899 )
		elseif ( anim == "fists_uppercut" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 51589 + self.Owner:GetForward() * 100128 )
			dmginfo:SetDamage( math.random( 10, 40 ) )
		end

		tr.Entity:TakeDamageInfo( dmginfo )
		hit = true

	end

	if ( SERVER && IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos )
		end
	end

	if ( SERVER ) then
		if ( hit && anim ~= "fists_uppercut" ) then
			self:SetCombo( self:GetCombo() + 1 )
		else
			self:SetCombo( 0 )
		end
	end

	self.Owner:LagCompensation( false )

end

function SWEP:OnRemove()

	if ( IsValid( self.Owner ) ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) end
	end

end

function SWEP:Holster( wep )

	self:OnRemove()

	return true

end

function SWEP:Deploy()

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )

	self:UpdateNextIdle()

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	self:SetRaised(false);

	return true

end

function SWEP:Think()
	if self:GetRaised() then

		local vm = self.Owner:GetViewModel()
		local curtime = CurTime()
		local idletime = self:GetNextIdle()

		if ( idletime > 0 && CurTime() > idletime ) then

			vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )

			self:UpdateNextIdle()

		end

		local meleetime = self:GetNextMeleeAttack()

		if ( meleetime > 0 && CurTime() > meleetime ) then

			self:DealDamage()

			self:SetNextMeleeAttack( 0 )

		end

		if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

			self:SetCombo( 0 )

		end

	end
end

local index;

index = ACT_HL2MP_IDLE;

SWEP.ActivityTranslateNotRaised = {}
SWEP.ActivityTranslateNotRaised [ ACT_MP_STAND_IDLE ] 				= index
SWEP.ActivityTranslateNotRaised [ ACT_MP_WALK ] 						= index+1
SWEP.ActivityTranslateNotRaised [ ACT_MP_RUN ] 						= index+2
SWEP.ActivityTranslateNotRaised [ ACT_MP_CROUCH_IDLE ] 				= index+3
SWEP.ActivityTranslateNotRaised [ ACT_MP_CROUCHWALK ] 				= index+4
SWEP.ActivityTranslateNotRaised [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
SWEP.ActivityTranslateNotRaised [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
SWEP.ActivityTranslateNotRaised [ ACT_MP_RELOAD_STAND ]		 		= index+6
SWEP.ActivityTranslateNotRaised [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
SWEP.ActivityTranslateNotRaised [ ACT_MP_JUMP ] = ACT_HL2MP_IDLE_DUEL+7
SWEP.ActivityTranslateNotRaised [ ACT_RANGE_ATTACK1 ] 				= index+8
SWEP.ActivityTranslateNotRaised [ ACT_MP_SWIM ] 						= index+9

index=ACT_HL2MP_IDLE_FIST;

SWEP.ActivityTranslateRaised = {}
SWEP.ActivityTranslateRaised [ ACT_MP_STAND_IDLE ] 				= index
SWEP.ActivityTranslateRaised [ ACT_MP_WALK ] 						= index+1
SWEP.ActivityTranslateRaised [ ACT_MP_RUN ] 						= index+2
SWEP.ActivityTranslateRaised [ ACT_MP_CROUCH_IDLE ] 				= index+3
SWEP.ActivityTranslateRaised [ ACT_MP_CROUCHWALK ] 				= index+4
SWEP.ActivityTranslateRaised [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
SWEP.ActivityTranslateRaised [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
SWEP.ActivityTranslateRaised [ ACT_MP_RELOAD_STAND ]		 		= index+6
SWEP.ActivityTranslateRaised [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
SWEP.ActivityTranslateRaised [ ACT_MP_JUMP ] 						= index+7
SWEP.ActivityTranslateRaised [ ACT_RANGE_ATTACK1 ] 				= index+8
SWEP.ActivityTranslateRaised [ ACT_MP_SWIM ] 						= index+9

index=nil;

function SWEP:TranslateActivity( act )

	if self:GetRaised() then
		if ( self.ActivityTranslateRaised[ act ] ~= nil ) then
			return self.ActivityTranslateRaised[ act ]
		end
	else
		if ( self.ActivityTranslateNotRaised[ act ] ~= nil ) then
			return self.ActivityTranslateNotRaised[ act ]
		end
	end
	return -1

end
