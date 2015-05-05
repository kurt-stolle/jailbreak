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


local DamageTypes = {}
DamageTypes[DMG_CRUSH] = "crush damage";
DamageTypes[DMG_BULLET] = "bullet damage";
DamageTypes[DMG_BURN] = "fire damage";
DamageTypes[DMG_VEHICLE] = "vehicular damage";
DamageTypes[DMG_FALL] = "fall damage";
DamageTypes[DMG_BLAST] = "explosion damage";
DamageTypes[DMG_DROWN] = "drown damage";
DamageTypes[DMG_POISON] = "poison damage";

local function convertTime(t)
	if t < 0 then
		t = 0;
	end

	local sec = tostring( math.Round(t - math.floor(t/60)*60));
	if string.len(sec) < 2 then
		sec = "0"..sec;
	end
	return (tostring( math.floor(t/60) )..":"..sec )
end


function JB:DamageLog_AddEntityTakeDamage( p,dmg )
	if ( IsValid(p) and p:IsPlayer() and dmg:GetDamage() ~= 0) then
		if not JB.ThisRound.Logs then
			JB.ThisRound.Logs = {};
		end

		local message={};

		local subject=p;

		table.insert(message,team.GetColor(p:Team()));
		table.insert(message,p:Nick());
		table.insert(message,JB.Color.white);
		table.insert(message," ("..p:SteamID()..")")

		local damagetype="damage"
		for k,v in pairs(DamageTypes)do
			if dmg:IsDamageType(k) then
				damagetype=v;
				break;
			end
		end

		table.insert(message," has taken "..tostring(math.ceil(dmg:GetDamage())).." "..damagetype);

		local att = dmg:GetAttacker();
		if IsValid(att) and att:IsPlayer() then
			table.insert(message," from ");
			table.insert(message,team.GetColor(att:Team()));
			table.insert(message,att:Nick());
			table.insert(message,JB.Color.white);
			table.insert(message," ("..att:SteamID()..")")
			subject=att;
		end

		local inf = dmg:GetInflictor();
		if IsValid(inf) and not (inf.IsPlayer and inf:IsPlayer()) then
			table.insert(message," by a '"..inf:GetClass().."' entity");
		end

		table.insert(message,JB.Color.white);
		table.insert(message,".");

		local timerText = (state == STATE_IDLE and "WAITING" or state == STATE_ENDED and "ENDED" or state == STATE_MAPVOTE and "MAPVOTE" or convertTime(60*(state == STATE_LASTREQUEST and 3 or 10) - (CurTime() - JB.RoundStartTime)) );

		local log={
			kind="DAMAGE",
			time=timerText,
			message=message,
			subject=subject
		}

		table.insert(JB.ThisRound.Logs,log)
	end
end
function JB:DamageLog_AddPlayerDeath(p, weapon, killer)
	if not JB.ThisRound.Logs then
		JB.ThisRound.Logs = {};
	end

	local message={};

	local subject=p;

	table.insert(message,team.GetColor(p:Team()));
	table.insert(message,p:Nick());
	table.insert(message,JB.Color.white);
	table.insert(message," ("..p:SteamID()..")")

	if IsValid(killer) and killer:IsPlayer() then
		if killer == p then
			table.insert(message," has commited suicide")
		else
			table.insert(message," was killed by ")
			table.insert(message,team.GetColor(killer:Team()));
			table.insert(message,killer:Nick());
			table.insert(message,JB.Color.white);
			table.insert(message," ("..killer:SteamID()..")")

			subject=killer;
		end
	else
		table.insert(message," has died")
	end

	table.insert(message,JB.Color.white);
	table.insert(message,".");

	local timerText = (state == STATE_IDLE and "WAITING" or state == STATE_ENDED and "ENDED" or state == STATE_MAPVOTE and "MAPVOTE" or convertTime(60*(state == STATE_LASTREQUEST and 3 or 10) - (CurTime() - JB.RoundStartTime)) );

	local log={
		kind="KILL",
		time=timerText,
		message=message,
		subject=subject
	}

	table.insert(JB.ThisRound.Logs,log)
end
function JB:DamageLog_AddPlayerPickup( p,class )
	if not JB.ThisRound.Logs then
		JB.ThisRound.Logs = {};
	end

	local message={};

	table.insert(message,team.GetColor(p:Team()));
	table.insert(message,p:Nick());
	table.insert(message,JB.Color.white);
	table.insert(message," ("..p:SteamID()..") has picked up a '"..class.."'.")

	local timerText = (state == STATE_IDLE and "WAITING" or state == STATE_ENDED and "ENDED" or state == STATE_MAPVOTE and "MAPVOTE" or convertTime(60*(state == STATE_LASTREQUEST and 3 or 10) - (CurTime() - JB.RoundStartTime)) );

	local log={
		kind="PICKUP",
		time=timerText,
		message=message,
		subject=p
	}

	table.insert(JB.ThisRound.Logs,log)
end
function JB:DamageLog_AddPlayerDrop( p,class )
	if not JB.ThisRound.Logs then
		JB.ThisRound.Logs = {};
	end

	local message={};

	table.insert(message,team.GetColor(p:Team()));
	table.insert(message,p:Nick());
	table.insert(message,JB.Color.white);
	table.insert(message," ("..p:SteamID()..") has dropped a '"..class.."'.")

	local timerText = (state == STATE_IDLE and "WAITING" or state == STATE_ENDED and "ENDED" or state == STATE_MAPVOTE and "MAPVOTE" or convertTime(60*(state == STATE_LASTREQUEST and 3 or 10) - (CurTime() - JB.RoundStartTime)) );

	local log={
		kind="DROP",
		time=timerText,
		message=message,
		subject=p
	}

	table.insert(JB.ThisRound.Logs,log)
end

util.AddNetworkString("JB.GetLogs");
local getLogs=function(p,cmd,a)
	if p.nextLogs and p.nextLogs > CurTime() then return end

	if (p:Alive() and not p:IsAdmin()) then
		p:PrintMessage(HUD_PRINTCONSOLE,"You can't receive logs while you're alive.");
		p:SendQuickNotification("You can't view logs while you're alive!");
		return;
	end

	p.nextLogs = CurTime()+1;

	local logs={};

	if cmd == "jb_logs_get_damage" then
		for k,v in ipairs(JB.ThisRound.Logs or {})do
			if v.kind =="DAMAGE" then
				table.insert(logs,v);
			end
		end
	elseif cmd == "jb_logs_get_kills" then
		for k,v in ipairs(JB.ThisRound.Logs or {})do
			if v.kind == "KILL" then
				table.insert(logs,v);
			end
		end
	elseif cmd == "jb_logs_get_damagekills" then
		for k,v in ipairs(JB.ThisRound.Logs or {})do
			if v.kind == "KILL" or v.kind == "DAMAGE" then
				table.insert(logs,v);
			end
		end
	else
		logs=JB.ThisRound.Logs;
	end

	net.Start("JB.GetLogs");
	net.WriteTable(logs or {});
	net.WriteBit(true);
	net.Send(p);
end
concommand.Add("jb_logs_get",getLogs);
concommand.Add("jb_logs_get_kills",getLogs);
concommand.Add("jb_logs_get_damage",getLogs);
concommand.Add("jb_logs_get_damagekills",getLogs);
