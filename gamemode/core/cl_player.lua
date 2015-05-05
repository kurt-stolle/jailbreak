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

local cvarAlwaysSpectator = CreateClientConVar( "jb_cl_option_always_spectate", "0", true, false )
hook.Add("Initialize","JB.AutomateSpectatorSpawn",function()
  if cvarAlwaysSpectator:GetBool() then
    RunConsoleCommand("jb_team_select_spectator");
  end
end)

function JB.Gamemode:KeyPress( ply, key )
   if ( not IsFirstTimePredicted() ) then return end
   if ( not IsValid( ply ) or ply ~= LocalPlayer() ) then return end
end

local fovSmooth;
local mulSpeed,angRightSmooth,angUpSmooth = 0,0,0;
local count=0;
function JB.Gamemode:CalcView( ply, pos, ang, fov, nearZ, farZ )
	local ragdoll =  LocalPlayer():GetRagdollEntity();
    if IsValid(ragdoll) and LocalPlayer():GetObserverMode() == OBS_MODE_NONE then
        local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );

		if not eyes then return end

	    local view = {
	        origin = eyes.Pos,
	        angles = eyes.Ang,
			fov = 90,
	    };

	    return view;
	end

	if not fovSmooth then fovSmooth = fov end

	mulSpeed=Lerp(FrameTime()*5,mulSpeed,math.Clamp((math.Clamp(ply:GetVelocity():Length(),ply:GetWalkSpeed(),ply:GetRunSpeed()) - ply:GetWalkSpeed())/(ply:GetRunSpeed() - ply:GetWalkSpeed()),0,1));

	if ply:KeyDown(IN_SPEED) then
		count=count+(FrameTime()*8)*mulSpeed;
		fovSmooth= Lerp(FrameTime()*5,fovSmooth,(fov + mulSpeed * 10 ));
		angRightSmooth= -math.abs(math.sin(count)*1);
		angUpSmooth= math.sin(count)*1.5;
	else
		fovSmooth= Lerp(FrameTime()*20,fovSmooth,fov);
		angRightSmooth= Lerp(FrameTime()*10,angRightSmooth,0);
		angUpSmooth= Lerp(FrameTime()*10,angUpSmooth,0);
		mulSpeed=0;
		count=0;
	end

	ang:RotateAroundAxis(ang:Right(),angRightSmooth * 2);
	ang:RotateAroundAxis(ang:Up(),angUpSmooth * 2);

	return JB.Gamemode.BaseClass.CalcView(self,ply,pos,ang,fovSmooth, nearZ, farZ);
end

hook.Add( "PreDrawHalos", "JB.PreDrawHalos.AddHalos", function()
	if JB.LastRequest ~= "0" and JB.LastRequestPlayers then
		for k,v in pairs(JB.LastRequestPlayers)do
			if not IsValid(v) or LocalPlayer() == v then continue; end

			halo.Add({v},team.GetColor(v:Team()),1,1,2,true,true);
		end
	end
end )

local colorRm = 0;
local approachOne = 1;
local lastHealth = 0;
local ft;
hook.Add( "RenderScreenspaceEffects", "JB.RenderScreenspaceEffects.ProcessHealthEffects", function()
	if LocalPlayer():GetObserverMode() == OBS_MODE_NONE then
		local ft = FrameTime();

		if lastHealth ~= LocalPlayer():Health() then
			approachOne = 0;
		end
		lastHealth = LocalPlayer():Health();

		approachOne = Lerp(ft*5,approachOne,1);

		colorRm = Lerp(ft/4 * 3,colorRm,(math.Clamp(LocalPlayer():Health(),0,40)/40)*0.8);

		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = -.05 + approachOne*.05
		tab[ "$pp_colour_contrast" ] = 1.1 - approachOne*.1
		tab[ "$pp_colour_colour" ] = 1 - (.8 - colorRm)
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0

		DrawColorModify( tab )

	end
end)

local cvarCrouchToggle = CreateClientConVar( "jb_cl_option_togglecrouch", "0", true, false )
local cvarWalkToggle = CreateClientConVar( "jb_cl_option_togglewalk", "0", true, false )
local walking = false;
hook.Add("PlayerBindPress", "JB.PlayerBindPress.KeyBinds", function(pl, bind, pressed)
	if string.find( bind,"+menu_context" ) then
		// see cl_context_menu.lua
	elseif string.find( bind,"+menu" ) then
		if pressed then
			RunConsoleCommand("jb_dropweapon")
		end
		return true;
	elseif string.find( bind,"+use" ) and pressed then
		local tr = LocalPlayer():GetEyeTrace();
		if tr and IsValid(tr.Entity) and tr.Entity:IsWeapon() then
			RunConsoleCommand("jb_pickup");
			return true;
		end
	elseif string.find( bind,"gm_showhelp" ) then
		if pressed then
			JB.MENU_HELP_OPTIONS();
		end
		return true;
	elseif string.find( bind,"gm_showteam" ) then
		if pressed then
			JB.MENU_TEAM();
		end
		return true;
	elseif string.find( bind,"gm_showspare2" ) then
		if pressed then
			if LocalPlayer():Team() == TEAM_PRISONER then
				JB.MENU_LR();
			elseif LocalPlayer():Team() == TEAM_GUARD then
				JB.MENU_WARDEN()
			end
		end
		return true;
	elseif string.find( bind,"warden" ) then
		return true;
	elseif cvarCrouchToggle:GetBool() and pressed and string.find( bind,"duck" ) then
		if pl:Crouching() then
			pl:ConCommand("-duck");
		else
			pl:ConCommand("+duck");
		end
		return true;
	elseif cvarWalkToggle:GetBool() and pressed and string.find( bind,"walk" ) then
		if walking then
			pl:ConCommand("-walk");
		else
			pl:ConCommand("+walk");
		end
		walking=!walking;
		return true;
	elseif string.find(bind,"+voicerecord") and pressed and ((pl:Team() == TEAM_PRISONER and (CurTime() - JB.RoundStartTime) < 30) or (not pl:Alive())) then
		JB:DebugPrint("You can't use voice chat - you're dead or the round isn't 30 seconds in yet.");
		return true;
	end
end)
