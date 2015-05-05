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


local pmeta = FindMetaTable("Player")

--[[ PLAYER CLASS SETTING ]]
local oldSetTeam=pmeta.SetTeam;
function pmeta:SetTeam(tm)
	player_manager.SetPlayerClass( self, tm == TEAM_GUARD and "player_guard" or tm == TEAM_PRISONER and "player_prisoner" or "player_spectator");
	oldSetTeam(self,tm);
end

--[[ PRISONER STATUS ]]
function pmeta:AddRebelStatus()
	if self:Team() ~= TEAM_PRISONER or not self:Alive() then
		return
	end

	self:SetRebel(true);

	JB:BroadcastNotification(self:Nick().." is rebelling!");

	self:SetPlayerColor(Vector(1,0,0));
	self:SetWeaponColor(Vector(1,0,0));
end
function pmeta:RemoveRebelStatus()
	if not self.SetRebel then
		return
	end

	self:SetRebel(false);

    self:SetPlayerColor(Vector(.9,.9,.9));
	self:SetWeaponColor(Vector(.9,.9,.9));
end

--[[ WARDEN STATUS ]]
function pmeta:AddWardenStatus()
	if self:Team() ~= TEAM_GUARD or not self:Alive() or not IsValid(JB.TRANSMITTER) then
		return
	end

	self:SetModel("models/player/barney.mdl")
	self:SetArmor(100)
	JB.TRANSMITTER:SetJBWarden(self);

end
function pmeta:RemoveWardenStatus()
	if not self:Alive() and IsValid(JB.TRANSMITTER) then return end

	self:SetModel("models/player/police.mdl")
	JB.TRANSMITTER:SetJBWarden(NULL);
end
function pmeta:SetupHands( ply )
	if IsValid(ply) and ply ~= self then return end // we don't need in-eye spectator.

	local oldhands = self:GetHands()
	if ( IsValid( oldhands ) ) then
		oldhands:Remove()
	end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		hands:DoSetup( self, ply )
		hands:Spawn()
	end

end

--[[ NOTIFICATIONS ]]
util.AddNetworkString("JB.SendNotification");
function pmeta:SendNotification(text)
	net.Start("JB.SendNotification");
	net.WriteString(text);
	net.Send(self);
end

util.AddNetworkString("JB.SendQuickNotification");
function pmeta:SendQuickNotification(msg)
	net.Start("JB.SendQuickNotification");
	net.WriteString(msg);
	net.Send(self);
end;
