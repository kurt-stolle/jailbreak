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



local color_text = Color(230,230,230,200);

local frame;
function JB.MENU_WARDEN()
	if IsValid(frame) then frame:Remove() end
	
	if LocalPlayer().GetWarden and LocalPlayer():GetWarden() and tobool(JB.Config.wardenControl) then
		frame = vgui.Create("JB.Frame");
		frame:SetTitle("Warden controls");
		frame:SetWide(320);
		
		local yBottom = 30;
		
		local lbl = Label("Game options",frame);
				lbl:SetFont("JBLarge");
				lbl:SetColor(JB.Color["#EEE"]);
				lbl:SizeToContents();
				lbl:SetPos(15,yBottom + 15);
		
		yBottom = lbl.y + lbl:GetTall();
		
		local function addButton(toggle,name,click)
			if not toggle then
				local btn = frame:Add("JB.Button");
				btn:SetPos(15,yBottom+15);
				btn:SetSize(frame:GetWide() - 30, 32);
				btn:SetText(name);
				btn.OnMouseReleased = click;
				
				yBottom = btn.y + btn:GetTall();
			else
				local lbl = Label(name,frame);
				lbl:SetFont("JBNormal");
				lbl:SetColor(color_text);
				lbl:SizeToContents();
				lbl:SetPos(15+8,yBottom+15+32/2 - lbl:GetTall()/2);
			
				local btn = frame:Add("JB.Button");
				btn:SetPos(frame:GetWide()-15-64,yBottom+15);
				btn:SetSize(64, 32);
				btn:SetText(tobool(toggle) == true and "ON" or "OFF");
				btn.OnMouseReleased = function()
					btn:SetText(btn:GetText() == "OFF" and "ON" or "OFF");
					click();
				end
				
				yBottom = btn.y + btn:GetTall();
			end
		end
		
		
		
		addButton(tostring(IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_PVPDamage()),"Friendlyfire for prisoners",function() RunConsoleCommand("jb_warden_changecontrol","PVP",tostring(not (IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_PVPDamage()))) end);
		addButton(tostring(IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_ItemPickup()),"Item pickup",function() RunConsoleCommand("jb_warden_changecontrol","Pickup",tostring(not (IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_ItemPickup()))); end);
		
		yBottom = yBottom+16;
		local lbl = Label("Object spawning",frame);
				lbl:SetFont("JBLarge");
				lbl:SetColor(JB.Color["#EEE"]);
				lbl:SizeToContents();
				lbl:SetPos(15,yBottom + 15);
		
		yBottom = lbl.y + lbl:GetTall();
		
		addButton(false,"Spawn ammo box",function() RunConsoleCommand("jb_warden_spawn","AmmoBox") end);
		addButton(false,"Spawn breakable crate",function() RunConsoleCommand("jb_warden_spawn","Crate") end);
		addButton(false,"Spawn blockade",function() RunConsoleCommand("jb_warden_spawn","Blockade") end);
		
		
		frame:SetTall(yBottom+15);
		frame:Center();
		frame:MakePopup();
	elseif JB.State == STATE_SETUP and not IsValid(JB:GetWarden()) then
		frame = vgui.Create("JB.Frame");
		frame:SetTitle("Claim warden");
		
		local lbl = Label("Do not claim warden if you don't own a microphone or can't use your microphone.\nDistorted microphone owners and children ('squeekers') are not allowed to claim warden.",frame);
		lbl:SetFont("JBSmall");
		lbl:SetColor(color_text);
		lbl:SizeToContents();
		lbl:SetPos(15,30+15);
		
		local btn = frame:Add("JB.Button");
		btn:SetSize(math.Round(lbl:GetWide()),32);
		btn:SetText("Claim Warden");
		
		btn:SetPos(15,lbl.y + lbl:GetTall() + 15);
		
		btn.OnMouseReleased = function()
			RunConsoleCommand("jb_claim_warden");
			frame:Remove();
		end	
		
		frame:SetSize(lbl:GetWide() + 30,btn.y + btn:GetTall() + 15);
		
		local setupTime;
		local timeLeft;
		frame.Think = function()
			setupTime = tonumber(JB.Config.setupTime);
			timeLeft = math.ceil(math.Clamp(setupTime - math.abs(CurTime() - JB.RoundStartTime),0,setupTime) );
			if timeLeft <= 0 or IsValid(JB:GetWarden()) then
				frame:Remove();
				JB.MENU_WARDEN();
				
				return;
			end
			
			frame:SetTitle("Claim Warden ("..timeLeft.." s)");			
		end
		
		frame:Center();
		frame:MakePopup();
	else
		frame = vgui.Create("JB.Frame");
		frame:SetTitle("Claim warden");

		local lbl = Label("You can only claim warden if it's the start of the round and there is no warden yet.",frame);
		lbl:SetFont("JBSmall");
		lbl:SetColor(color_text);
		lbl:SizeToContents();
		lbl:SetPos(15,30+15);
		frame:SetSize(lbl:GetWide() + 30,30+15+lbl:GetTall()+15);
		
		frame:Center();
		frame:MakePopup();
	end
end
