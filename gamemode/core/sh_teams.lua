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

local team, table = team, table

TEAM_GUARD 		= 2;
TEAM_PRISONER 	= 1;

JB.Gamemode.CreateTeams = function()
	team.SetUp( TEAM_GUARD, "Guards", JB.Color["#0066FF"]	)
	team.SetUp( TEAM_PRISONER, "Prisoners", JB.Color["#E31100"] )

	team.SetSpawnPoint( TEAM_GUARD,"info_player_counterterrorist" );
	team.SetSpawnPoint( TEAM_PRISONER,"info_player_terrorist" );
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" ) 
end

-- Utility functions
function team.HasPlayers(tm, amount)
	if not isnumber(amount) or amount < 2 then 
		for k, v in ipairs(player.GetAll()) do 
			if v:Team() == tm then return true end
		end
		return false
	else
		local i = 0
		for k, v in ipairs(player.GetAll()) do 
			if v:Team() == tm then 
				i = i + 1 
				if i >= amount then 
					return true
				end
			end
		end
		return false
	end
end

function team.GetAllPlayers()
	local t = {}
	for k, v in pairs(team.GetAllTeams()) do
		t[k] = {}
	end
	for k, v in ipairs(player.GetAll()) do 
		table.insert(t[v:Team()], v)
	end
	return t
end

function team.GetPlayers(tm) -- ran between 1.5x-2x faster in my test. (Ran with JIT enabled)
	local t = {}
	for k, v in pairs(player.GetAll()) do
		if v:Team() == tm then
			table.insert(t, v)
		end
	end
	return t
end

function JB:GetGuardsAllowed()
	local t = team.GetAllPlayers()
    if #t[TEAM_GUARD] < 1 then
        return 1;
    end
    return math.ceil((#t[TEAM_GUARD] + #t[TEAM_PRISONER]) * (tonumber(JB.Config.guardsAllowed)/100));
end

function JB:BalanceTeams()
	local t = team.GetAllPlayers()
	if ( #t[TEAM_GUARD] + #t[TEAM_PRISONER] ) <= 1 then return end

	local balls = {};
	
	if #t[TEAM_GUARD] > JB:GetGuardsAllowed() then
		for i=1, (#t[TEAM_GUARD] - JB:GetGuardsAllowed()) do
			local ply = table.Random(t[TEAM_GUARD]);
			ply:SetTeam(TEAM_PRISONER);
			ply:ChatPrint("You were moved to Prisoners to make the game more fair.");
			balls[#balls+1] = ply;
		end
	end
	
	return balls;
end

local count;
function JB:AliveGuards()
	count=0;
	for _,v in ipairs(player.GetAll())do
		if v:Alive() and v:Team() == TEAM_GUARD then
			count = count+1;
		end
	end
	return count;
end

function JB:AlivePrisoners()
	count=0;
	for _,v in ipairs(player.GetAll())do
		if v:Alive() and v:Team() == TEAM_PRISONER then
			count = count+1;
		end
	end
	return count;
end

--Useless gooks
function GM:PlayerJoinTeam() return false end
function GM:PlayerRequestTeam() return false end