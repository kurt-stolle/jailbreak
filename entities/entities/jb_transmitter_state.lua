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

AddCSLuaFile();

ENT.Base 				="base_point"
ENT.Type				="point"
ENT.PrintName 			="JB State Transmitter"

function ENT:Initialize()
	JB.TRANSMITTER = self;
	JB:DebugPrint("Setup State Transmitter!");
	//self:SetPredictable(true);
end
function ENT:Think()
	if not IsValid(JB.TRANSMITTER) and IsValid(self) then // there is no registered transmitter and yet we're here. What's going on? Let's assume that we are the transmitter that is being looked for.
		JB.TRANSMITTER = self;
	end
end
function ENT:SetupDataTables()
	self:NetworkVar( "Int",	0, "JBState" );
	self:NetworkVar( "Int",	1, "JBRoundsPassed" );
	
	self:NetworkVar( "Vector", 0, "JBWarden_PointerPos")

	self:NetworkVar( "String", 0, "JBLastRequestPicked" );
	self:NetworkVar( "String", 1, "JBWarden_PointerType");
		
	self:NetworkVar( "Float", 0, "JBRoundStartTime" );
		
	self:NetworkVar( "Entity", 0, "JBLastRequestPrisoner" );
	self:NetworkVar( "Entity", 1, "JBLastRequestGuard" );
	self:NetworkVar( "Entity", 2, "JBWarden" );

	self:NetworkVar ( "Bool", 0, "JBWarden_PVPDamage");
	self:NetworkVar ( "Bool", 1, "JBWarden_ItemPickup");
		
	if ( SERVER ) then
		self:SetJBRoundStartTime(0);
		self:SetJBState(STATE_IDLE);
		self:SetJBRoundsPassed(0);
		self:SetJBWarden_PointerType("0");
		self:SetJBWarden_PointerPos(Vector(0,0,0));
	end
end
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end
function ENT:KeyValue( key, value )
	if ( self:SetNetworkKeyValue( key, value ) ) then
		return
	end
end
function ENT:CanEditVariables( ply )
	return false;
end