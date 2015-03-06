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

AddCSLuaFile()

if (CLIENT) then
	scopeTex = surface.GetTextureID("scope/scope_normal")
end

SWEP.PrintName			= "M40A1"	

SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_jb_base"
SWEP.Category			= "Jailbreak Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_scout.mdl"

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_Scout.Single")
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 90
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.00001
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 1.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

function SWEP:TranslateFOV(fov)
	if self:GetNWMode() == 2 then
		return 20
	else
		return fov
	end
end



if CLIENT then

function SWEP:AdjustMouseSensitivity()
	return self:GetNWMode() == 2 and .20 or 1;
end

local scopeMat = Material("jailbreak_excl/scope.png");

function SWEP:DrawHUD()
	if self:GetNWMode() == 2 then

		local size = ScrH();

		surface.SetDrawColor(JB.Color.black)

		surface.DrawRect(0, 0, (ScrW()-size) / 2, size);
		surface.DrawRect(ScrW() - ((ScrW()-size) / 2), 0, (ScrW()-size) / 2, size);
	
		surface.DrawLine(0,ScrH()/2,ScrW(),ScrH()/2)
		surface.DrawLine(ScrW()/2,0,ScrW()/2,ScrH())
	
		surface.SetDrawColor(JB.Color.black)
		surface.SetMaterial(scopeMat)
		surface.DrawTexturedRect( (ScrW()/2) - (size/2) , 0, size, size)
	end
end

end