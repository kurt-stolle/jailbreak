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


/*

	These are the variables you may edit to add new guns:

*/
SWEP.Primary.NumShots		= 1;												// Number of bullets per shot fired, could be used to make a shotgun pellet effect.
SWEP.Primary.Automatic		= true												// Automatic firing mode
SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" );					// Weapon sound. Always precache this using the Sound function!
SWEP.Primary.Ammo			= "SMG1";											// ammo type, SMG1 for all primary weapons, pistol for secondary; we don't want complicated ammo systems in this gamemode!
SWEP.Primary.Recoil			= 1.2;												// recoil
SWEP.Primary.Damage			= 40;												// damage taken when a bullet is fired into a player's chest area (hitting head makes for more damage, limbs makes for less)
SWEP.Primary.Cone			= 0.05;												// spread
SWEP.Primary.MaxCone		= 0.06; 											// maximum spread
SWEP.Primary.ShootConeAdd	= 0.005;											// how much should be added to the spread for every shot fired
SWEP.Primary.IronConeMul 	= 0.25;												// accuracy multiplier when aiming down sights or zoomed
SWEP.Primary.CrouchConeMul 	= 0.8;												// accuracy multiplier when crouched
SWEP.Primary.ClipSize		= 27;												// weapon clip size
SWEP.Primary.Delay			= 0.13;												// weapon delay
SWEP.Primary.IronShootForce = 2;												// added force when aiming down the sights - for dramatic effect
SWEP.Primary.Burst 			= -1;												// number of bursts, should be -1 if the weapon isn't a burst-fire weapon
SWEP.HoldType 				= "melee2"											// should be smg1, ar2 or revolver
--SWEP.ReloadSequenceTime 	= 1.85; 											// for rechamber -  Don't set this if you don't know it. Use the ModelViewer in SourceSDK to find out what the right time is.
SWEP.Primary.Range 			= WEAPON_SNIPER										// sniper, smg, rifle or pistol effective range
SWEP.FakeIronSights			= false												// for weapons without proper ironsights, such as the M4A1

SWEP.Positions 				= {
	 								{pos = Vector(0,0,0), ang = Vector(0,0,0)}, // Viewmodel positions in IDLE mode
	 								{pos = Vector(0,0,0), ang = Vector(0,0,0)}, // Viewmodel positions in AIM mode
	 								{pos = Vector(0,0,0), ang = Vector(0,0,0)}  // Viewmodel positions in SPRINT mode
							};

/*

	Anything below this line you shouldn't have to read or touch!

*/

AddCSLuaFile()
AddCSLuaFile("client.lua");

local cvarAimToggle;

if SERVER then
	include("server.lua");

	SWEP.AutoSwitchTo = true;

	cvarAimToggle = {};
	function cvarAimToggle:GetBool(ply)
		return tobool(ply:GetInfoNum( "jb_cl_option_toggleaim", "0" ))
	end
end

if CLIENT then
	include("client.lua");

	cvarAimToggle = CreateClientConVar( "jb_cl_option_toggleaim", "0", true, true )
end

SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize; -- See: gamemode/core/sh_weapon_hack.lua
SWEP.IsDropped = false;
SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";
SWEP.Author			= "Excl";
SWEP.Contact		= "info@casualbananas.com";
SWEP.Purpose		= "For use in the Jail Break 7 gamemode.";
SWEP.Instructions	= "Left click to shoot, R to reload.";
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= true
SWEP.Category		= "Jail Break 7";
SWEP.UseHands = true;

local EffectiveRangeTable = {}
EffectiveRangeTable	[WEAPON_SMG] = 1200;
EffectiveRangeTable	[WEAPON_RIFLE] = 3000;
EffectiveRangeTable	[WEAPON_SNIPER] = 10000;
EffectiveRangeTable	[WEAPON_PISTOL] = 500;



local MODE_NORMAL = 1;
local MODE_AIM = 2;
local MODE_SPRINT = 3;

AccessorFunc(SWEP,"reloading","Reloading",FORCE_BOOL);

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "NWLastShoot" );
	self:NetworkVar( "Int", 0, "NWMode" );
end

function SWEP:Initialize()
	if IsValid(self) and self.SetWeaponHoldType then
		self:SetWeaponHoldType(self.HoldType);
	end

	if CLIENT then
		if not IsValid(self.ViewModelReference) then
			self.ViewModelReference = ClientsideModel(self.ViewModel, RENDERGROUP_BOTH)
			if not IsValid(self.ViewModelReference) then return end
			self.ViewModelReference:SetNoDraw(true)
		end
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire(CurTime() + 1);

	self:SetNWMode(1);
	self:SetReloading(false);

	timer.Destroy(self.Owner:SteamID().."ReloadTimer")

	self.originalWalkSpeed = IsValid(self.Owner) and self.Owner:GetWalkSpeed() or 260;

	return true;
end

function SWEP:Holster()
	//self.OldAmmo = self:Clip1();
	//self:SetClip1(1);

	self:SetNWLastShoot(0);

	if self.Owner.SteamID and self.Owner:SteamID() then
		timer.Destroy(self.Owner:SteamID().."ReloadTimer")
	end

	if SERVER then
		self.Owner:SetFOV(0,0.6)
		self.Owner:SetWalkSpeed(self.originalWalkSpeed)
	end
	return true;
end

SWEP.NextReload = CurTime();
local timeStartReload;
function SWEP:Reload()
	if self.NextReload > CurTime() or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 or self:GetNWMode() == MODE_SPRINT or self:GetNWMode() == MODE_AIM or !IsFirstTimePredicted()  then return end

	self:SetNWMode(MODE_NORMAL);
	self:SendWeaponAnim(ACT_VM_RELOAD);
	self.Owner:SetAnimation(PLAYER_RELOAD);

	self.NextReload = CurTime()+4;



	local clip = self:Clip1();
	local dur;
	if clip > 0 then
		self.Rechamber = false;
		self:SetClip1(1);

		dur = self.Owner:GetViewModel():SequenceDuration();
	else
		self.Rechamber = true;

		dur = self.ReloadSequenceTime or self.Owner:GetViewModel():SequenceDuration();
	end

	self:SetNextPrimaryFire(CurTime()+dur);
	timer.Create(self.Owner:SteamID().."ReloadTimer", dur,1,function()
		if not self or not IsValid(self) or not self.Owner or not IsValid(self.Owner) then return end

		amt = math.Clamp(self.Owner:GetAmmoCount(self.Primary.Ammo),0,self.Primary.ClipSize);
		self.Owner:RemoveAmmo(amt,self.Primary.Ammo);

		if not self.Rechamber then
			if SERVER then
				self:SetClip1(amt+1);
			end
		else
			if SERVER then
				self:SetClip1(amt);
			end
			self:SendWeaponAnim(ACT_VM_DRAW);
			self:SetNextPrimaryFire(CurTime()+.2);
		end


		self:SetReloading(false);
	end)
	self:SetReloading(true);

	self:SetNWLastShoot(0);
end

SWEP.AddCone = 0;
SWEP.LastShoot = CurTime();
SWEP.oldMul = 0.5;

SWEP.originalWalkSpeed = 260;

local speed;
function SWEP:Think()
	if CLIENT and IsValid(self) then
			speed= self.Owner:GetVelocity():Length();

			if speed > self.Owner:GetWalkSpeed() + 20 and self.Owner:KeyDown(IN_SPEED) and self:GetNWMode() ~= MODE_SPRINT then
				self:SetNWMode(MODE_SPRINT);
			elseif speed <= 10 and self.Owner:KeyDown(IN_SPEED) and self:GetNWMode() == MODE_SPRINT then
				self:SetNWMode(MODE_NORMAL);
			end

			if self:GetNWMode() == MODE_SPRINT and (!self.Owner:KeyDown(IN_SPEED) or speed < self.Owner:GetWalkSpeed()) then
				self:SetNWMode(MODE_NORMAL);
			end
	elseif SERVER and IsValid(self) then
		if IsFirstTimePredicted() then
			speed= self.Owner:GetVelocity():Length();
			local mul = 1;
			if self.Owner:Crouching() and speed < 30 then
				mul = self.Primary.CrouchConeMul;
			elseif speed > self.Owner:GetWalkSpeed() + 20 then
				mul = 2;
				if self.Owner:KeyDown(IN_SPEED) then
					self:SetNWMode(MODE_SPRINT);
				end
			elseif speed > 120 then
				mul = 1.5;
			end

			if self:GetNWMode() == MODE_AIM then
				mul = mul * self.Primary.IronConeMul;
			end

			if self:GetNWMode() == MODE_SPRINT and (!self.Owner:KeyDown(IN_SPEED) or speed < self.Owner:GetWalkSpeed()) then
				self:SetNWMode(MODE_NORMAL);
			end

			self.oldMul = Lerp(0.5,self.oldMul,mul);

			if self.LastShoot+0.2 < CurTime() then
				self.AddCone = self.AddCone-(self.Primary.ShootConeAdd/5);
				if self.AddCone < 0 then
					self.AddCone=0;
				end
			end

			self:SetNWLastShoot(math.Clamp((self.Primary.Cone+self.AddCone)*self.oldMul, 0.002, 0.12));
		end
	end

	if SERVER and self:GetNWMode() == MODE_AIM and self.Owner:GetWalkSpeed() ~= self.originalWalkSpeed*.65 then
		self.Owner:SetWalkSpeed(self.originalWalkSpeed*.65)
	elseif SERVER and self:GetNWMode() ~= MODE_AIM and self.Owner:GetWalkSpeed() ~= self.originalWalkSpeed then
		self.Owner:SetWalkSpeed(self.originalWalkSpeed)
	end

	if self.nextBurst and self.nextBurst <= CurTime() and self.burstLeft and self.burstLeft >= 1 then
		self.burstLeft = self.burstLeft - 1;
		self.nextBurst=CurTime()+self.Primary.Delay;

		if self:Clip1() <= 0 then
			self:EmitSound( "Weapon_Pistol.Empty" )
			return;
		end

		self:JB_ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetNWLastShoot(), self.Primary.NumShots)

		self.AddCone = math.Clamp(self.AddCone+self.Primary.ShootConeAdd,0,self.Primary.MaxCone)
		self.LastShoot = CurTime();


		if SERVER then
			self.Owner:EmitSound(self.Primary.Sound, 100, math.random(95, 105))
		end

		self:TakePrimaryAmmo(1);
	end
end

function SWEP:OnDrop()
	if CLIENT or not IsValid(self.Owner) then return end

	self.Owner:SetWalkSpeed(self.originalWalkSpeed)
end



function SWEP:PrimaryAttack()
	if self:GetNWMode() == MODE_SPRINT then return end

	local delay = self.Primary.Burst > 0 and self.Primary.Delay * (self.Primary.Burst + 1) or self.Primary.Delay;

	if self:Clip1() <= 0 then
		self:SetNextPrimaryFire(CurTime()+delay);
		self:EmitSound( "Weapon_Pistol.Empty" )
		return;
	end

	self:SetNextPrimaryFire(CurTime()+delay);

	self:JB_ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetNWLastShoot(), self.Primary.NumShots)

	if IsFirstTimePredicted() and self.Primary.Burst > 0 then
		self.nextBurst=CurTime()+self.Primary.Delay;
		self.burstLeft=self.Primary.Burst-1;
	end

	self.AddCone = math.Clamp(self.AddCone+self.Primary.ShootConeAdd,0,self.Primary.MaxCone)
	self.LastShoot = CurTime();

	if SERVER then
		self.Owner:EmitSound(self.Primary.Sound, 100, math.random(95, 105))
	end

	self:TakePrimaryAmmo(1);
end

function SWEP:SecondaryAttack()
	if self:GetNWMode() == MODE_SPRINT or self:GetReloading() or (SERVER and not IsFirstTimePredicted()) then return end

	self:SetNWMode(cvarAimToggle:GetBool(self.Owner) and (self:GetNWMode() == MODE_AIM and MODE_NORMAL or MODE_AIM) or MODE_AIM);

	self:SetNextSecondaryFire(CurTime() + .3);
end
hook.Add("KeyRelease", "jbWepBaseHandleUnAim", function(p,k)
	if IsValid(p) and k and k == IN_ATTACK2 and !cvarAimToggle:GetBool(p) then
		local wep = p:GetActiveWeapon();
		if IsValid(wep) and wep.GetNWMode and wep:GetNWMode() == MODE_AIM then
			wep:SetNWMode(MODE_NORMAL);
		end
	end
end)

SWEP.Markers = {};
function SWEP:JB_ShootBullet( dmg, recoil, numbul, cone )
	if IsFirstTimePredicted() then
		local bullet = {
			Num 		= numbul;
			Src 		= self.Owner:GetShootPos();
			Dir 		= ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward();
			Spread 	= Vector( cone, cone, 0 );
			Tracer	= 3;
			Force	= (dmg/4)*3;
			Damage	= dmg;
			Callback = function(attacker, tr, dmginfo)
			  if tr.HitWorld and tr.MatType == MAT_METAL then
			      local eff = EffectData()
			      eff:SetOrigin(tr.HitPos)
			      eff:SetNormal(tr.HitNormal)
			      util.Effect("cball_bounce", eff)
			   end

			   if tr.Entity and IsValid(tr.Entity) and tr.Entity:IsPlayer() then

			      table.insert(self.Markers,{
			         pos = tr.HitPos, alpha = 255
			      })
			   end
			 end
		}

		self.Owner:FireBullets(bullet)
	end

	if self:GetNWMode() == MODE_NORMAL or (self:GetNWMode() == MODE_AIM and self.FakeIronSights) then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	end
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self.Owner:MuzzleFlash();


	if CLIENT then
		self:FireCallback();

		if  IsFirstTimePredicted() then
			local eyeang = self.Owner:EyeAngles()
			eyeang.pitch = eyeang.pitch - (recoil * 1 * 0.3)*2
			eyeang.yaw = eyeang.yaw - (recoil * math.random(-1, 1) * 0.3)
			self.Owner:SetEyeAngles( eyeang )
		end
	end
end

local ActivityTranslateHipFire = {}
ActivityTranslateHipFire [ ACT_MP_STAND_IDLE ] 					= ACT_HL2MP_IDLE_SHOTGUN;
ActivityTranslateHipFire [ ACT_MP_WALK ] 						= ACT_HL2MP_IDLE_SHOTGUN+1;
ActivityTranslateHipFire [ ACT_MP_RUN ] 						= ACT_HL2MP_IDLE_SHOTGUN+2;
ActivityTranslateHipFire [ ACT_MP_CROUCH_IDLE ] 				= ACT_HL2MP_IDLE_SHOTGUN+3;
ActivityTranslateHipFire [ ACT_MP_CROUCHWALK ] 					= ACT_HL2MP_IDLE_SHOTGUN+4;
ActivityTranslateHipFire [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_SMG1+5;
ActivityTranslateHipFire [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_SMG1+5;
ActivityTranslateHipFire [ ACT_MP_RELOAD_STAND ]		 		= ACT_HL2MP_IDLE_SMG1+6;
ActivityTranslateHipFire [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_IDLE_SMG1+6;
ActivityTranslateHipFire [ ACT_MP_JUMP ] 						= ACT_HL2MP_IDLE_SHOTGUN+7;
ActivityTranslateHipFire [ ACT_RANGE_ATTACK1 ] 					= ACT_HL2MP_IDLE_SMG1+8;
ActivityTranslateHipFire [ ACT_MP_SWIM ] 						= ACT_HL2MP_IDLE_SHOTGUN+9;

local ActivityTranslatePistolNoAim = {}
ActivityTranslatePistolNoAim [ ACT_MP_STAND_IDLE ] 					= ACT_HL2MP_IDLE_PISTOL;
ActivityTranslatePistolNoAim [ ACT_MP_WALK ] 						= ACT_HL2MP_IDLE_PISTOL+1;
ActivityTranslatePistolNoAim [ ACT_MP_RUN ] 						= ACT_HL2MP_IDLE_PISTOL+2;
ActivityTranslatePistolNoAim [ ACT_MP_CROUCH_IDLE ] 				= ACT_HL2MP_IDLE_PISTOL+3;
ActivityTranslatePistolNoAim [ ACT_MP_CROUCHWALK ] 					= ACT_HL2MP_IDLE_PISTOL+4;
ActivityTranslatePistolNoAim [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_PISTOL+5;
ActivityTranslatePistolNoAim [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_PISTOL+5;
ActivityTranslatePistolNoAim [ ACT_MP_RELOAD_STAND ]		 		= ACT_HL2MP_IDLE_PISTOL+6;
ActivityTranslatePistolNoAim [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_IDLE_PISTOL+6;
ActivityTranslatePistolNoAim [ ACT_MP_JUMP ] 						= ACT_HL2MP_IDLE_PISTOL+7;
ActivityTranslatePistolNoAim [ ACT_RANGE_ATTACK1 ] 					= ACT_HL2MP_IDLE_PISTOL+8;
ActivityTranslatePistolNoAim [ ACT_MP_SWIM ] 						= ACT_HL2MP_IDLE_PISTOL+9;

local ActivityTranslateSprintRifle = {}
ActivityTranslateSprintRifle [ ACT_MP_STAND_IDLE ] 					= ACT_HL2MP_IDLE_PASSIVE;
ActivityTranslateSprintRifle [ ACT_MP_WALK ] 						= ACT_HL2MP_IDLE_PASSIVE+1;
ActivityTranslateSprintRifle [ ACT_MP_RUN ] 							= ACT_HL2MP_IDLE_PASSIVE+2;
ActivityTranslateSprintRifle [ ACT_MP_CROUCH_IDLE ] 					= ACT_HL2MP_IDLE_PASSIVE+3;
ActivityTranslateSprintRifle [ ACT_MP_CROUCHWALK ] 					= ACT_HL2MP_IDLE_PASSIVE+4;
ActivityTranslateSprintRifle [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_PASSIVE+5;
ActivityTranslateSprintRifle [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE_PASSIVE+5;
ActivityTranslateSprintRifle [ ACT_MP_RELOAD_STAND ]		 			= ACT_HL2MP_IDLE_PASSIVE+6;
ActivityTranslateSprintRifle [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_IDLE_PASSIVE+6;
ActivityTranslateSprintRifle [ ACT_MP_JUMP ] 						= ACT_HL2MP_IDLE_PASSIVE+7;
ActivityTranslateSprintRifle [ ACT_RANGE_ATTACK1 ] 					= ACT_HL2MP_IDLE_PASSIVE+8;
ActivityTranslateSprintRifle [ ACT_MP_SWIM ] 						= ACT_HL2MP_IDLE_PASSIVE+9;

local ActivityTranslateSprintPistol = {}
ActivityTranslateSprintPistol [ ACT_MP_STAND_IDLE ] 					= ACT_HL2MP_IDLE;
ActivityTranslateSprintPistol [ ACT_MP_WALK ] 						= ACT_HL2MP_IDLE+1;
ActivityTranslateSprintPistol [ ACT_MP_RUN ] 							= ACT_HL2MP_IDLE+2;
ActivityTranslateSprintPistol [ ACT_MP_CROUCH_IDLE ] 					= ACT_HL2MP_IDLE+3;
ActivityTranslateSprintPistol [ ACT_MP_CROUCHWALK ] 					= ACT_HL2MP_IDLE+4;
ActivityTranslateSprintPistol [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE+5;
ActivityTranslateSprintPistol [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] 	= ACT_HL2MP_IDLE+5;
ActivityTranslateSprintPistol [ ACT_MP_RELOAD_STAND ]		 			= ACT_HL2MP_IDLE+6;
ActivityTranslateSprintPistol [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_IDLE+6;
ActivityTranslateSprintPistol [ ACT_MP_JUMP ] 						= ACT_HL2MP_IDLE_DUEL+7;
ActivityTranslateSprintPistol [ ACT_RANGE_ATTACK1 ] 					= ACT_HL2MP_IDLE+8;
ActivityTranslateSprintPistol [ ACT_MP_SWIM ] 						= ACT_HL2MP_IDLE+9;

function SWEP:TranslateActivity( act )

	local holdtype = string.lower(self.HoldType);

	if ( holdtype == "ar2" or holdtype=="smg" ) then
		if self:GetNWMode() == MODE_NORMAL and ActivityTranslateHipFire[ act ] ~= nil  then
			return ActivityTranslateHipFire[ act ]
		elseif self:GetNWMode() == MODE_SPRINT and ActivityTranslateSprintRifle[ act ] ~= nil then
			return ActivityTranslateSprintRifle[act];
		end
	end

	if ( holdtype == "revolver" or holdtype=="pistol") then
		if self:GetNWMode() == MODE_NORMAL and holdtype == "revolver" and ActivityTranslatePistolNoAim[ act ] ~= nil  then
			return ActivityTranslatePistolNoAim[ act ]
		elseif self:GetNWMode() == MODE_SPRINT and ActivityTranslateSprintPistol[ act ] ~= nil  then
			return ActivityTranslateSprintPistol[ act ]
		end
	end

	if ( self.ActivityTranslate[ act ] ~= nil ) then
		return self.ActivityTranslate[ act ]
	end

	return -1

end
