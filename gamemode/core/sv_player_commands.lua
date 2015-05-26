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


local undroppableWeapons = {"weapon_physcannon", "weapon_physgun", "gmod_camera", "gmod_tool", "weapon_jb_fists"}
local drop = function( ply, cmd, args )
	if  (table.HasValue(JB.LastRequestPlayers,ply) and JB.LastRequestTypes[JB.LastRequest] and not JB.LastRequestTypes[JB.LastRequest]:GetCanDropWeapons() )  then return end

	JB:DebugPrint(ply:Nick().." dropped his/her weapon");

	local weapon = ply:GetActiveWeapon()

	for k, v in pairs(undroppableWeapons) do
		if IsValid(weapon) then
			if v == weapon:GetClass() then return false end
		end
	end

	if IsValid(weapon) then
		JB:DamageLog_AddPlayerDrop( ply,weapon:GetClass() )

		weapon.IsDropped = true;
		weapon.BeingPickedUp = false;
		ply:DropWeapon(weapon)
	end
end
concommand.Add("jb_dropweapon", drop)
JB.Util.addChatCommand("drop",drop);

local pickup = function(p)
	local e = p:GetEyeTrace().Entity

	if (table.HasValue(JB.LastRequestPlayers,p) and JB.LastRequestTypes[JB.LastRequest] and not JB.LastRequestTypes[JB.LastRequest]:GetCanPickupWeapons() ) then
		return;
	end

	if IsValid(e) and p:Alive() and p:CanPickupWeapon( e )  then
		e.BeingPickedUp = p;
	end

	JB:DamageLog_AddPlayerPickup( p,e:GetClass() )
end
concommand.Add("jb_pickup",pickup)
JB.Util.addChatCommand("pickup",pickup);

local function teamSwitch(p,cmd)
	if !IsValid(p) then return end

	if cmd == "jb_team_select_guard" and JB:GetGuardsAllowed() > #team.GetPlayers(TEAM_GUARD) and p:Team() ~= TEAM_GUARD then
		p:SetTeam(TEAM_GUARD);
		p:KillSilent();
		p:SendNotification("Switched to guards");

		hook.Call("JailBreakPlayerSwitchTeam",JB.Gamemode,p,p:Team());

		p:SetFrags(0);
		p:SetDeaths(0);
	elseif cmd == "jb_team_select_prisoner" and p:Team() ~= TEAM_PRISONER then
		p:SetTeam(TEAM_PRISONER);
		p:KillSilent();
		p:SendNotification("Switched to prisoners");

		hook.Call("JailBreakPlayerSwitchTeam",JB.Gamemode,p,p:Team());

		p:SetFrags(0);
		p:SetDeaths(0);
	elseif cmd == "jb_team_select_spectator" and p:Team() ~= TEAM_SPECTATOR then
		p:SetTeam(TEAM_SPECTATOR);
		p:Spawn();
		p:SendNotification("Switched to spectator mode");

		hook.Call("JailBreakPlayerSwitchTeam",JB.Gamemode,p,p:Team());

		p:SetFrags(0);
		p:SetDeaths(0);
	end


end
concommand.Add("jb_team_select_prisoner",teamSwitch);
concommand.Add("jb_team_select_guard",teamSwitch);
concommand.Add("jb_team_select_spectator",teamSwitch);
JB.Util.addChatCommand("guard",function(p)
	p:ConCommand("jb_team_select_guard");
end);
JB.Util.addChatCommand("prisoner",function(p)
	p:ConCommand("jb_team_select_prisoner");
end);
JB.Util.addChatCommand("spectator",function(p)
	p:ConCommand("jb_team_select_spectator");
end);

local teamswap = function(p)
	if p:Team() == TEAM_PRISONER then
		p:ConCommand("jb_team_select_guard");
	else
		p:ConCommand("jb_team_select_prisoner");
	end
end
JB.Util.addChatCommand("teamswap",teamswap);
JB.Util.addChatCommand("swap",teamswap);
JB.Util.addChatCommand("swapteam",teamswap);

concommand.Add("jb_admin_swap",function(p,c,a)

	if not IsValid(p) or not p:IsAdmin() then return end

	local steamid = a[1];

	if not steamid then return end

	for k,v in ipairs(player.GetAll())do
		if v:SteamID() == steamid then
			if v:Team() == TEAM_GUARD then
				v:SetTeam(TEAM_PRISONER);
				v:KillSilent();
				v:SendNotification("Forced to prisoners");

				hook.Call("JailBreakPlayerSwitchTeam",JB.Gamemode,p,p:Team());
			else
				v:SetTeam(TEAM_GUARD);
				v:KillSilent();
				v:SendNotification("Forced to guards");

				hook.Call("JailBreakPlayerSwitchTeam",JB.Gamemode,p,p:Team());
			end

			for k,it in ipairs(player.GetAll())do
				it:ChatPrint(p:Nick().." has force swapped "..v:Nick()..".");
			end

			return;
		end
	end

	p:ChatPrint("User not found! " ..steamid)
end)
concommand.Add("jb_admin_swap_spectator",function(p,c,a)

	if not IsValid(p) or not p:IsAdmin() then return end

	local steamid = a[1];

	if not steamid then return end

	for k,v in ipairs(player.GetAll())do
		if v:SteamID() == steamid then
			v:SetTeam(TEAM_SPECTATOR)
			v:Kill()
			for k,it in ipairs(player.GetAll())do
				it:ChatPrint(p:Nick().." has made "..v:Nick().." a spectator.");
			end
			return;
		end
	end

	p:ChatPrint("User not found! "..steamid)
end)
concommand.Add("jb_admin_revive",function(p,c,a)

	if not IsValid(p) or not p:IsAdmin() then return end

	local steamid = a[1];

	if not steamid then return end

	for k,v in ipairs(player.GetAll())do
		if v:SteamID() == steamid then
			v._jb_forceRespawn=true
			v:Spawn()

			for k,it in ipairs(player.GetAll())do
				it:ChatPrint(p:Nick().." has revived "..v:Nick()..".")
			end

			return;
		end
	end

	p:ChatPrint("User not found! "..steamid)
end)
