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


local LR = JB.CLASS_LR();
LR:SetName("Airborne Battle");
LR:SetDescription("The guard and the prisoner both get a Famas rifle and knife, but they can only fire if they are in the air, so they will have to either jump from fall in order to fire.");
LR:SetStartCallback(function(prisoner,guard)
	for _,ply in ipairs{prisoner,guard} do
		ply:StripWeapons();
		ply:Give("weapon_jb_famas");
		ply:Give("weapon_jb_knife");
		ply:GiveAmmo(899,"SMG1");
		ply:SetHealth(100);
		ply:SetArmor(0);
	end
end)
LR:SetIcon(Material("icon16/flag_green.png"))
local this = LR();

hook.Add("PlayerBindPress", "JB.PlayerBindPress.LR.Airborne", function(pl, bind, pressed) // Not the safest way, but it requires the least amount of touching code outside of this file (without using nasty hacky methods)
	if JB.LastRequest == this and table.HasValue(JB.LastRequestPlayers,pl) and pl:IsOnGround() and string.find( bind,"+attack" ) then
		return true;
	end
end)