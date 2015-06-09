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



--------------------------------------------------------------------------------------
--
--
--   REGARDING CUSTOM MAPVOTE SYSTEMS:
--
--   _________________________
--
--
--   If you want to code your own mapvote, hook the JailBreakStartMapvote hook,
--   start your own mapvote here. Remember to return true in order to stop the
--   round system for a while, while you run your mapvote.
--
--   _________________________
--
--
--   You might want to use the following functions as well if you're writing a
--   custom mapvote:
--
--   JB:Mapvote_ExtendCurrentMap()
--   JB:Mapvote_StartMapVote()
--
--
--------------------------------------------------------------------------------------


/*

Compatability hooks - implement these in your admin mods

*/

function JB.Gamemode.JailBreakStartMapvote(rounds_passed,extentions_passed) // hook.Add("JailBreakStartMapvote",...) to implement your own mapvote. NOTE: Remember to return true!
	return false // return true in your own mapvote function, else there won't be a pause between rounds!
end

/*

State chaining

*/
local function chainState(state,stateTime,stateCallback)
	JB.State = state;

	if timer.Exists("JB.StateTimer") then
		timer.Remove("JB.StateTimer");
	end

	timer.Create("JB.StateTimer",stateTime,1,stateCallback);
end

/*

Utility functions

*/
local ententionsDone = 0;
function JB:Mapvote_ExtendCurrentMap() 		// You can call this from your own admin mod/mapvote if you want to extend the current map.
	JB.RoundsPassed = 0;
	ententionsDone = ententionsDone+1;
	chainState(STATE_ENDED,5,function()
		JB:NewRound();
	end);
end
function JB:Mapvote_StartMapVote()			// You can call this from your admin mod/mapvote to initiate a mapvote.
	if hook.Call("JailBreakStartMapvote",JB.Gamemode,JB.RoundsPassed,ententionsDone) then
		JB.State = STATE_MAPVOTE;
		return true;
	end
	return false;
end

/*

Enums

*/
STATE_IDLE = 1; -- when the map loads, we wait for everyone to join
STATE_SETUP = 2; -- first few seconds of the round, when everyone can still spawn and damage is disabled
STATE_PLAYING = 3; -- normal playing
STATE_LASTREQUEST = 4; -- last request taking place, special rules apply
STATE_ENDED = 5; -- round ended, waiting for next round to start
STATE_MAPVOTE = 6; -- voting for a map, will result in either a new map loading or restarting the current without reloading

/*

Network strings

*/
if SERVER then
	util.AddNetworkString("JB.LR.GetReady");
	util.AddNetworkString("JB.SendRoundUpdate");
end

/*

Special days

*/
local function resetSpecial()
	if SERVER then
		game.ConsoleCommand("sv_gravity 600;\n")
		game.ConsoleCommand("sv_friction 8;\n")
	elseif CLIENT then

	end
end

if SERVER then
	JB.SpecialDays = {
		["Low-Gravity Knife Party"] = function()
			game.ConsoleCommand("sv_gravity 200;\n")
			game.ConsoleCommand("sv_friction 3;\n")

			for k,v in ipairs(team.GetPlayers(TEAM_PRISONER))do
				v:SetJumpPower(400)
				v:StripWeapons()
				v:Give("weapon_jb_knife")
			end

			for k,v in ipairs(team.GetPlayers(TEAM_GUARD))do
				v:SetJumpPower(400)
				v:StripWeapons()
				v:Give("weapon_jb_knife")
			end

			for k,v in ipairs(ents.GetAll())do
				if IsValid(v) and v.GetClass and string.Left(v:GetClass(),string.len("weapon_jb_")) == "weapon_jb_" and v:GetClass() ~= "weapon_jb_knife" then
					v:Remove()
				end
			end

			for k,v in ipairs(ents.FindByClass("func_door"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_door_rotating"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_movelinear"))do
				v:Fire("Open",1)
			end
		end,
		["Guns for everyone"] = function()
			for k,v in ipairs(team.GetPlayers(TEAM_PRISONER))do
				v:Give("weapon_jb_deagle")
				v:SelectWeapon("weapon_jb_deagle")
			end

			for k,v in ipairs(ents.FindByClass("func_door"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_door_rotating"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_movelinear"))do
				v:Fire("Open",1)
			end
		end,
		["Super heros"] = function()
			for k,v in ipairs(team.GetPlayers(TEAM_PRISONER))do
				v:SetRunSpeed(600)
				v:SetWalkSpeed(270)
				v:SetJumpPower(400)
			end

			for k,v in ipairs(ents.FindByClass("func_door"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_door_rotating"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_movelinear"))do
				v:Fire("Open",1)
			end
		end,
		["Slow guards"] = function()
			for k,v in ipairs(team.GetPlayers(TEAM_GUARD))do
				v:SetRunSpeed(100)
				v:SetWalkSpeed(100)
			end

			for k,v in ipairs(ents.FindByClass("func_door"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_door_rotating"))do
				v:Fire("Open",1)
			end
			for k,v in ipairs(ents.FindByClass("func_movelinear"))do
				v:Fire("Open",1)
			end
		end
	}
end

/*

Round System

*/
JB.ThisRound = {};
local wantStartup = false;
function JB:NewRound(rounds_passed)
	rounds_passed = rounds_passed or JB.RoundsPassed;
	collectgarbage("collect");

	JB.ThisRound = {};

	if SERVER then
		game.CleanUpMap();

		rounds_passed = rounds_passed + 1;
		JB.RoundsPassed = rounds_passed;
		JB.RoundStartTime = CurTime();

		chainState(STATE_SETUP,tonumber(JB.Config.setupTime),function()
			JB:DebugPrint("Setup finished, round started.")
			chainState(STATE_PLAYING,(10*60) - tonumber(JB.Config.setupTime),function()
				JB:EndRound();
			end);

			if not IsValid(JB:GetWarden()) then
				JB:DebugPrint("No warden after setup time; Freeday!")
				JB:BroadcastNotification("Today is a freeday");
			end
		end);

		if JB.RoundsPassed == 1 then
			local count=table.Count(JB.SpecialDays)
			local which=math.random(1,count)
			count=0;
			for k,v in pairs(JB.SpecialDays)do
				count=count+1
				if count == which then
					which=k;
					break;
				end
			end


			if JB.SpecialDays[which] then
				JB:BroadcastNotification("First round: "..which)
				JB.SpecialDays[which]();
				JB.ThisRound.IsSpecialRound = true;
			end
		end

		if IsValid(JB.TRANSMITTER) then
			JB.TRANSMITTER:SetJBWarden_PVPDamage(false);
			JB.TRANSMITTER:SetJBWarden_ItemPickup(false);
			JB.TRANSMITTER:SetJBWarden_PointerType("0");
			JB.TRANSMITTER:SetJBWarden(NULL);
		end

		JB:BalanceTeams()

		JB.Util.iterate(player.GetAll()):SetRebel(false):Spawn();
		timer.Simple(1,function()
			JB.Util.iterate(player.GetAll()):Freeze(false);
		end)

		net.Start("JB.SendRoundUpdate"); net.WriteInt(STATE_SETUP,8); net.WriteInt(rounds_passed,32); net.Broadcast();
	elseif CLIENT and IsValid(LocalPlayer()) then
		notification.AddLegacy("Round "..rounds_passed,NOTIFY_GENERIC);

		LocalPlayer():ConCommand("-voicerecord");
	end

	hook.Call("JailBreakRoundStart",JB.Gamemode,JB.RoundsPassed);
end
function JB:EndRound(winner)
	if JB.ThisRound.IsSpecialRound then
		resetSpecial()
	end

	if SERVER then
		if JB.RoundsPassed >= tonumber(JB.Config.roundsPerMap) and JB:Mapvote_StartMapVote() then
			return; // Halt the round system; we're running a custom mapvote!
		end

		chainState(STATE_ENDED,5,function()
			JB.Util.iterate(player.GetAll()):Freeze(true);
			JB:NewRound();
		end);

		net.Start("JB.GetLogs");
		net.WriteTable(JB.ThisRound and JB.ThisRound.Logs or {});
		net.WriteBit(true);
		net.Broadcast(p);

		net.Start("JB.SendRoundUpdate"); net.WriteInt(STATE_ENDED,8); net.WriteInt(winner or 0, 8); net.Broadcast();
	elseif CLIENT then
		notification.AddLegacy(winner == TEAM_PRISONER and "Prisoners win" or winner == TEAM_GUARD and "Guards win" or "Draw",NOTIFY_GENERIC);
	end

	hook.Call("JailBreakRoundEnd",JB.Gamemode,JB.RoundsPassed);
end

if CLIENT then
	net.Receive("JB.SendRoundUpdate",function()
		local state = net.ReadInt(8);
		if state == STATE_ENDED then
			JB:EndRound(net.ReadInt(8));
		elseif state == STATE_SETUP then
			JB:NewRound(net.ReadInt(32));
		end
	end);
elseif SERVER then
	timer.Create("JB.Time.RoundEndLogic",1,0,function()
		if JB.State == STATE_IDLE and wantStartup then
			if #team.GetPlayers(TEAM_GUARD) >= 1 and #team.GetPlayers(TEAM_PRISONER) >= 1 then
				JB:DebugPrint("State is currently idle, but people have joined; Starting round 1.")
				JB:NewRound();
			end
		end

		if (JB.State ~= STATE_PLAYING and JB.State ~= STATE_SETUP and JB.State ~= STATE_LASTREQUEST) or #team.GetPlayers(TEAM_GUARD) < 1 or #team.GetPlayers(TEAM_PRISONER) < 1 then return end

		local count_guard = JB:AliveGuards();
		local count_prisoner = JB:AlivePrisoners();

		if count_prisoner < 1 and count_guard < 1 then
			JB:EndRound(0); -- both win!
		elseif count_prisoner < 1 then
			JB:EndRound(TEAM_GUARD);
		elseif count_guard < 1 then
			JB:EndRound(TEAM_PRISONER);
		end
	end);
end

/*

Transmission Entity

*/
JB.TRANSMITTER = JB.TRANSMITTER or NULL;
hook.Add("InitPostEntity","JB.InitPostEntity.SpawnStateTransmit",function()
	if SERVER and not IsValid(JB.TRANSMITTER) then
		JB.TRANSMITTER = ents.Create("jb_transmitter_state");
		JB.TRANSMITTER:Spawn();
		JB.TRANSMITTER:Activate();

		chainState(STATE_IDLE,tonumber(JB.Config.joinTime),function()
			wantStartup = true; -- request a startup.
		end);
	elseif CLIENT then
		timer.Simple(0,function()
			notification.AddLegacy("Welcome to Jail Break 7",NOTIFY_GENERIC);
			if JB.State == STATE_IDLE then
				notification.AddLegacy("The round will start once everyone had a chance to join",NOTIFY_GENERIC);
			elseif JB.State == STATE_PLAYING or JB.State == STATE_LASTREQUEST then
				notification.AddLegacy("A round is currently in progress",NOTIFY_GENERIC);
				notification.AddLegacy("You will spawn when the current ends",NOTIFY_GENERIC);
			elseif JB.State == STATE_MAPVOTE then
				notification.AddLegacy("A mapvote is currently in progress",NOTIFY_GENERIC);
			end
		end);
	end
end);

if CLIENT then
	hook.Add("OnEntityCreated","JB.OnEntityCreated.SelectTransmitter",function(ent)
		if ent:GetClass() == "jb_transmitter_state" and not IsValid(JB.TRANSMITTER) then
			JB.TRANSMITTER = ent;
			JB:DebugPrint("Transmitter found (OnEntityCreated)");
		end
	end)

	timer.Create("JB.CheckOnStateTransmitter",10,0,function()
		if not IsValid(JB.TRANSMITTER) then
			JB:DebugPrint("Panic! State Transmitter not found!");
			local trans=ents.FindByClass("jb_transmitter_state");
			if trans and trans[1] and IsValid(trans[1]) then
				JB.TRANSMITTER=trans[1];
				JB:DebugPrint("Automatically resolved; Transmitter relocated.");
			else
				JB:DebugPrint("Failed to locate transmitter - contact a developer!");
			end
		end
	end);
end

/*

Index Callback methods

*/


// State
JB._IndexCallback.State = {
	get = function()
		return IsValid(JB.TRANSMITTER) and JB.TRANSMITTER.GetJBState and JB.TRANSMITTER:GetJBState() or STATE_IDLE;
	end,
	set = function(state)
		if SERVER and IsValid(JB.TRANSMITTER) then
			JB.TRANSMITTER:SetJBState(state or STATE_IDLE);
			JB:DebugPrint("State changed to: "..state)
		else
			Error("Can not set state!")
		end
	end
}

// Round-related methods.
JB._IndexCallback.RoundsPassed = {
	get = function()
		return IsValid(JB.TRANSMITTER) and JB.TRANSMITTER.GetJBRoundsPassed and JB.TRANSMITTER:GetJBRoundsPassed() or 0;
	end,
	set = function(amount)
		if SERVER and IsValid(JB.TRANSMITTER) then
			JB.TRANSMITTER:SetJBRoundsPassed(amount > 0 and amount or 0);
		else
			Error("Can not set rounds passed!");
		end
	end
}
JB._IndexCallback.RoundStartTime = {
	get = function()
		return IsValid(JB.TRANSMITTER) and JB.TRANSMITTER.GetJBRoundStartTime and  JB.TRANSMITTER:GetJBRoundStartTime() or 0;
	end,
	set = function(amount)
		if SERVER and IsValid(JB.TRANSMITTER) then
			JB.TRANSMITTER:SetJBRoundStartTime(amount > 0 and amount or 0);
		else
			Error("Can not set round start time!");
		end
	end
}

// Last Request-related methods.
JB._IndexCallback.LastRequest = {
	get = function()
		return (JB.State == STATE_LASTREQUEST) and JB.TRANSMITTER:GetJBLastRequestPicked() or "0";
	end,
	set = function(tab)
		if not IsValid(JB.TRANSMITTER) or not SERVER then return end

		if not tab or type(tab) ~= "table" or not tab.type or not JB.ValidLR(JB.LastRequestTypes[tab.type]) or not IsValid(tab.prisoner) or not IsValid(tab.guard) then
			JB.TRANSMITTER:SetJBLastRequestPicked("0");
			if not pcall(function() JB:DebugPrint("Attempted to select invalid LR: ",tab.type," ",tab.prisoner," ",tab.guard," ",type(tab)); end) then JB:DebugPrint("Unexptected LR sequence abortion!"); end
			return
		end

		JB.TRANSMITTER:SetJBLastRequestPrisoner(tab.prisoner);
		JB.TRANSMITTER:SetJBLastRequestGuard(tab.guard);
		JB.TRANSMITTER:SetJBLastRequestPicked(tab.type);

		chainState(STATE_LASTREQUEST,180,function() JB:EndRound() end)

		JB.RoundStartTime = CurTime();

		JB:BroadcastNotification(tab.prisoner:Nick().." requested a "..JB.LastRequestTypes[tab.type]:GetName(),{tab.prisoner,tab.guard})

		JB:DebugPrint("LR Initiated! ",tab.prisoner," vs ",tab.guard);

		local players={tab.guard,tab.prisoner};
		JB.Util.iterate (players) : Freeze(true) : StripWeapons() : GodEnable() : SetHealth(100) : SetArmor(0);

		if not JB.LastRequestTypes[tab.type].setupCallback(tab.prisoner,tab.guard) then
			net.Start("JB.LR.GetReady");
			net.WriteString(tab.type);
			net.Send(players);

			timer.Simple(7,function()
				if not JB.Util.isValid(tab.prisoner,tab.guard) then return end
				JB.Util.iterate (players) : Freeze(false) : GodDisable();
				timer.Simple(.5,function()
					if not JB.Util.isValid(tab.prisoner,tab.guard) then return end
					JB.LastRequestTypes[tab.type].startCallback(tab.prisoner,tab.guard);
				end);
			end)
		end
	end
}
JB._IndexCallback.LastRequestPlayers = {
	get = function()
		return JB.State == STATE_LASTREQUEST and {JB.TRANSMITTER:GetJBLastRequestGuard() or NULL, JB.TRANSMITTER:GetJBLastRequestPrisoner() or NULL} or {NULL,NULL};
	end,
	set = function()
		Error("Tried to set LR players through invalid methods!");
	end
}

/*

Prevent Cleanup

*/
local old_cleanup = game.CleanUpMap;
function game.CleanUpMap(send,tab)
	if not tab then tab = {} end
	table.insert(tab,"jb_transmitter_state");
	old_cleanup(send,tab);
end
