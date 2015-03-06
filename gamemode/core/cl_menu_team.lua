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


local color_text = Color(223,223,223,230);

local frame;
function JB.MENU_TEAM()
	if IsValid(frame) then frame:Remove()  end
	
	if timer.Exists("JB.MENU_TEAM.Update") then
		timer.Stop("JB.MENU_TEAM.Update");
		timer.Remove("JB.MENU_TEAM.Update");
	end

	frame = vgui.Create("JB.Frame");
	frame:SetTitle("Team selection");
	 
	frame:SetSize(400,50+15+128+15+32+15+32);
	
	local img = vgui.Create("DImage",frame);
	img:SetSize(128,128);
	img:SetPos(frame:GetWide()/4 * 3 - 128/2,30+15);
	img:SetMaterial("materials/jailbreak_excl/logo_prisoner.png");
	
	local img = vgui.Create("DImage",frame);
	img:SetSize(128,128);
	img:SetPos(frame:GetWide()/4 * 1 - 128/2,30+15);
	img:SetMaterial("materials/jailbreak_excl/logo_guard.png");
	
	local butGuard = vgui.Create("JB.Button",frame);
	butGuard:SetSize(math.Round(frame:GetWide()/2 - 15*1.5),32);
	butGuard:SetPos(15,frame:GetTall()-15-32-15-32);
	butGuard:SetText("Guards ( "..#team.GetPlayers(TEAM_GUARD).." / "..JB:GetGuardsAllowed().." )");
	butGuard.OnMouseReleased = function()
		if LocalPlayer():Team() == TEAM_GUARD then
			frame:Remove()
			return;
		end
	
		if JB:GetGuardsAllowed() > #team.GetPlayers(TEAM_GUARD) then
			RunConsoleCommand("jb_team_select_guard");
			frame:Remove();
		end
	end
	
	local butPrisoner = vgui.Create("JB.Button",frame);
	butPrisoner:SetSize(math.Round(frame:GetWide()/2 - 15*1.5),32);
	butPrisoner:SetPos(butGuard.x + butGuard:GetWide() + 15,frame:GetTall()-15-32-15-32);
	butPrisoner:SetText("Prisoners ( "..#team.GetPlayers(TEAM_PRISONER).." )");
	butPrisoner.OnMouseReleased = function()
		if LocalPlayer():Team() != TEAM_PRISONER then
			RunConsoleCommand("jb_team_select_prisoner");
		end
		frame:Remove();
	end
	
	local butSpec = vgui.Create("JB.Button",frame);
	butSpec:SetSize(frame:GetWide()-15-15,32);
	butSpec:SetPos(15,butPrisoner.y + butPrisoner:GetTall()+15);
	butSpec:SetText("Spectate");
	butSpec.OnMouseReleased = function()
		if LocalPlayer():Team() != TEAM_SPECTATOR then
			RunConsoleCommand("jb_team_select_spectator");
		end
		frame:Remove();
	end

	timer.Create("JB.MENU_TEAM.Update",.5,0,function()
		if not IsValid(frame) or not IsValid(butGuard) or not IsValid(butPrisoner) then 
			if timer.Exists("JB.MENU_TEAM.Update") then
				timer.Stop("JB.MENU_TEAM.Update");
				timer.Remove("JB.MENU_TEAM.Update");
			end
			return;
		end
	
		butGuard:SetText("Guards ( "..#team.GetPlayers(TEAM_GUARD).." / "..JB:GetGuardsAllowed().." )");
		butPrisoner:SetText("Prisoners ( "..#team.GetPlayers(TEAM_PRISONER).." )");
	end);
	
	frame:Center();
	frame:MakePopup();
end
