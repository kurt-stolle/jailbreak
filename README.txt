========================================
Jail Break 7 server operator information
========================================

#
#	GAMEMODE CONFIG
#   format: convar (value) :: explaination
#

jb_config_debug 1/0                    	## Debug mode, you might want to set this to 0 to reduce annoying console messages 
jb_config_font fontname              	## The gamemode's font. I disrecommend changing this; may cause everything to go weird!
jb_config_website example.com        	## the URL of your website. This URL will be displayed as a form of advertising your site.
jb_config_jointime 20 (minimum: 10)   	## (seconds) period when the map just loaded and people are given a chance to join.
jb_config_setuptime 60 (minimum: 10)  	## (seconds) period at the start of the round when guards may claim warden.
jb_config_guards_allowed 30 (minimum: 1) ## percentage of players allowed to be guard
jb_config_guards_playtime 120			## (minutes) playtime required to be guard (admins bypass this)
jb_config_rebel_sensitivity 0-2			## 2 = prisoner becomes rebel on killing a guard, 1 = prisoner becomes rebel on damaging a guard, 0 = prisoner never becomes rebel.
jb_config_prisoners_namechange 1/0		## 1 = use fake names for prisoners (ex. Prisoner 192346), 0 = use normal nicknames for prisoners
jb_config_warden_control_enabled 1/0	## toggles whether warden control should be enabled or not. (recommended: always 1);
jb_config_prisoner_special_chance		## chance a prisoner will get a random weapon. Chance = random(1,var)==1;
jb_config_max_warden_rounds				## maximum amount of rounds a player can be warden in a row. 
jb_config_knives_are_concealed			## conceal knives - they won't draw on the player's tigh if this is set to 1.
jb_config_rounds_per_map				## rounds until mapvote - ONLY SET THIS IF YOU HAVE A MAPVOTE SYSTEM ON YOUR SERVER/COMMUNITY
jb_config_notify_lastguard 1/0			## send the "last guard kills all" notification

(put these values in your server.cfg)

========================================
Jail Break 7 server operator information
========================================

#
#   LAST REQUESTS
#	This is how last requests are added. LR files have to put put in the lastrequests folder.
#

	-- Initialize a new LR class
	local LR = JB.CLASS_LR();

	-- Give it a name and description
	LR:SetName("Knife Battle");
	LR:SetDescription("The guard and the prisoner both get a knife, all other weapons are stripped, and they must fight eachother until one of the two dies");

	-- Give it an Icon for in the LR-menu
	LR:SetIcon(Material("icon16/flag_blue.png"))

	-- Setup what happens after somebody picks this Last Request
	LR:SetStartCallback(function(prisoner,guard)
		for _,ply in ipairs{prisoner,guard} do
			ply:StripWeapons();
			ply:Give("weapon_jb_knife");
			ply:Give("weapon_jb_fists");
			
			ply:SetHealth(100);
			ply:SetArmor(0);
		end
	end)

	-- Tell JailBreak that this LR is ready for use.
	LR();

__________________________________

# 
#	GAMEMODE HOOKS
#	format: hookname ( arguments[, optional argument] ) -> return
#	

JailBreakRoundStart 			( rounds_passed )							-> nil
JailBreakRoundEnd				( rounds_passed )							-> nil
JailBreakStartMapvote 			( rounds_passed, extentions_passed ) 		-> true: Use custom mapvote system, false: Use default system (no mapvote).
JailBreakClaimWarden			( player, warden_rounds_in_a_row )			-> nil
JailBreakWardenControlChanged	( player, option, value )					-> nil
JailBreakWardenSpawnProp		( player, type[, model] )					-> nil
JailBreakWardenPlacePointer		( player, type, position )					-> nil
JailBreakPlayerSwitchTeam		( player, team )							-> nil

