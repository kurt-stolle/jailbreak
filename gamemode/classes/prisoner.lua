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


DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Prisoner"
PLAYER.WalkSpeed 			= 260
PLAYER.RunSpeed				= 310
PLAYER.CrouchedWalkSpeed 	= 0.4
PLAYER.DuckSpeed			= 0.3
PLAYER.UnDuckSpeed			= 0.3
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight     = false
PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100
PLAYER.StartArmor			= 50
PLAYER.DropWeaponOnDie		= false
PLAYER.AvoidPlayers			= false

function PLAYER:Spawn()
	self.Player:SetPlayerColor(Vector(.9,.9,.9));
	self.Player:SetWeaponColor(Vector(.9,.9,.9));

	self.Player:SetRebel(false);

	self.Player:GiveAmmo( 50, "Pistol", true )
	self.Player:GiveAmmo( 100, "SMG1", true )
end

local randomSpecialWeapon = {
	"weapon_jb_knife",
}
function PLAYER:Loadout()
	self.Player:Give("weapon_jb_fists");

	if math.random(1,JB.Config.prisonerSpecialChance) == 1 then
		self.Player:Give(table.Random(randomSpecialWeapon)); -- give the player a rando waeapon from our table.
	end
end

function PLAYER:SetupDataTables()
	self.Player:NetworkVar( "Bool", 0, "Rebel" );

	self.Player:NetworkVar( "Bool", 1, "InGuardZone" );
end

local prisonerModels = {

-- Black models (we add these a few times, so it increases the chance of a player being black, which makes the atmosphere of the game more "criminal")
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),
	Model("models/player/Group01/female_03.mdl"),
	Model("models/player/Group01/female_05.mdl"),
	Model("models/player/Group01/male_01.mdl"),
	Model("models/player/Group01/male_03.mdl"),

-- Normal 'white' models
	Model("models/player/Group01/female_02.mdl"),
	Model("models/player/Group01/female_01.mdl"),
	Model("models/player/Group01/female_04.mdl"),
	Model("models/player/Group01/female_06.mdl"),
	Model("models/player/Group01/male_02.mdl"),
	Model("models/player/Group01/male_04.mdl"),
	Model("models/player/Group01/male_05.mdl"),
	Model("models/player/Group01/male_06.mdl"),
	Model("models/player/Group01/male_07.mdl"),
	Model("models/player/Group01/male_08.mdl"),
	Model("models/player/Group01/male_09.mdl"),
}
function PLAYER:SetModel()
	self.Player:SetModel( string.lower(table.Random(prisonerModels)) )
end

player_manager.RegisterClass( "player_prisoner", PLAYER, "player_default" )
