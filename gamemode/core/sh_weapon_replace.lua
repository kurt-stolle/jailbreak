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

local reregister = {};
local function reregisterWeapon(old,new)
	reregister[old] = new;
end

reregisterWeapon("weapon_ak47","weapon_jb_ak47");
reregisterWeapon("weapon_aug","weapon_jb_m4a1");
reregisterWeapon("weapon_awp","weapon_jb_awp");
reregisterWeapon("weapon_deagle","weapon_jb_deagle");
reregisterWeapon("weapon_elite","weapon_jb_usp");
reregisterWeapon("weapon_famas","weapon_jb_famas");
reregisterWeapon("weapon_fiveseven","weapon_jb_fiveseven");
reregisterWeapon("weapon_g3sg1","weapon_jb_m4a1");
reregisterWeapon("weapon_galil","weapon_jb_galil");
reregisterWeapon("weapon_glock","weapon_jb_glock");
reregisterWeapon("weapon_m249","weapon_jb_scout");
reregisterWeapon("weapon_m3","weapon_jb_scout");
reregisterWeapon("weapon_m4a1","weapon_jb_m4a1");
reregisterWeapon("weapon_mac10","weapon_jb_mac10");
reregisterWeapon("weapon_mp5navy","weapon_jb_mp5navy");
reregisterWeapon("weapon_p228","weapon_jb_fiveseven");
reregisterWeapon("weapon_p90","weapon_jb_p90");
reregisterWeapon("weapon_scout","weapon_jb_scout");
reregisterWeapon("weapon_sg550","weapon_jb_scout");
reregisterWeapon("weapon_sg552","weapon_jb_sg552");
reregisterWeapon("weapon_tmp","weapon_jb_tmp");
reregisterWeapon("weapon_ump45","weapon_jb_ump");
reregisterWeapon("weapon_usp","weapon_jb_usp");
reregisterWeapon("weapon_xm1014","weapon_jb_scout");
reregisterWeapon("weapon_knife","weapon_jb_knife");
reregisterWeapon("weapon_hegrenade","weapon_jb_knife");
reregisterWeapon("weapon_smokegrenade","weapon_jb_knife");
reregisterWeapon("weapon_flashbang","weapon_jb_knife");

hook.Add("Initialize","JB.Initialize.ReplaceCSSWeapons",function()
	for k,v in pairs(reregister)do
		weapons.Register( {Base = v, IsDropped = true}, string.lower(k), false);
	end
end);

if SERVER then
	function JB:CheckWeaponReplacements(ply,entity)
		if reregister[entity:GetClass()] then
			ply:Give(reregister[entity:GetClass()])
			return true;
		end
		return false;
	end
end