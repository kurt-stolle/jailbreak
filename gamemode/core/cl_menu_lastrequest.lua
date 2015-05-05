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
local matGradient = Material("materials/jailbreak_excl/gradient.png"); 
local frame;
function JB.MENU_LR()
	if IsValid(frame) then frame:Remove() end
	
	frame = vgui.Create("JB.Frame");
	frame:SetTitle("Last Request");
	
	if (JB.State ~= STATE_PLAYING and JB.State ~= STATE_SETUP and JB.State ~= STATE_LASTREQUEST) or JB.AlivePrisoners() > 1 or JB:AliveGuards() < 1 or not LocalPlayer():Alive() then
		
		local lbl = Label("A last request is a last chance for the prisoner team to win the round if all rebelling attempts failed.\nIt will consist of a small game the prisoner doing the request can play against a guard of his choice.\n\nYou can only start a Last Request if you're the last prisoner alive and the round is in progress.",frame);
		lbl:SetFont("JBSmall");
		lbl:SetColor(color_text);
		lbl:SizeToContents();
		lbl:SetPos(15,30+15);
		frame:SetSize(lbl:GetWide() + 30,30+15+lbl:GetTall()+15);
	else
		frame:SetWide(620);
		local left = frame:Add("JB.Panel");
		left:SetSize(math.Round(frame:GetWide() * .35) - 15,412);
		left:SetPos(10,40);

		local right = frame:Add("JB.Panel");
		right:SetSize(math.Round(frame:GetWide() * .65) - 15,412);
		right:SetPos(left:GetWide() + left.x + 10,40);

		frame:SetTall(math.Round(right:GetTall() + 50))


		-- populate right panel
		local lr_selected;
		local lbl_LRName = Label("",right);
		lbl_LRName:SetPos(20,20);
		lbl_LRName:SetFont("JBLarge");
		lbl_LRName:SizeToContents();
		lbl_LRName:SetColor(color_text);

		local lbl_LRDetails = Label("",right);
		lbl_LRDetails:SetPos(20,lbl_LRName.y + lbl_LRName:GetTall() + 16);
		lbl_LRDetails:SetColor(color_text);
		lbl_LRDetails:SetFont("JBSmall");
		lbl_LRDetails:SetSize(right:GetWide() - 40,right:GetTall() - lbl_LRDetails.y - 30-30-32);
		lbl_LRDetails:SetWrap(true);
		lbl_LRDetails:SizeToContents();

		local btn_accept = right:Add("JB.Button");
		btn_accept:SetSize(right:GetWide() - 60,32);
		btn_accept:SetPos(30,right:GetTall() - 30 - btn_accept:GetTall());
		btn_accept:SetText("Start Last Request");
		btn_accept.OnMouseReleased = (function()
			local Menu = DermaMenu()

			for k,v in pairs(team.GetPlayers(TEAM_GUARD))do
				if not IsValid(v) then continue end
				
				local btn = Menu:AddOption( v:Nick() or "Unknown guard",function() 
					RunConsoleCommand("jb_lastrequest_start",lr_selected:GetID(),v:EntIndex());
					if IsValid(frame) then frame:Remove() end
				end)
				if v.GetWarden and v:GetWarden() then
					btn:SetIcon( "icon16/star.png" )
				end
			end

			Menu:AddSpacer()
			Menu:AddOption( "Random guard",function()
				local tab = {};
				for k,v in ipairs(team.GetPlayers(TEAM_GUARD))do
					if v:Alive() then 
						table.insert(tab,v);
					end					
				end

				RunConsoleCommand("jb_lastrequest_start",lr_selected:GetID(),(table.Random(tab)):EntIndex());
				if IsValid(frame) then frame:Remove() end
			end ):SetIcon( "icon16/lightbulb.png" )
			Menu:Open();
		end);
		btn_accept:SetVisible(false);

		--populate left panel
		local function selectLR(lr)
			if not JB.ValidLR(lr) then return end


			btn_accept:SetVisible(true);

			lbl_LRName:SetText(lr:GetName());
			lbl_LRName:SizeToContents();

			lbl_LRDetails:SetPos(20,lbl_LRName.y + lbl_LRName:GetTall() + 16);
			lbl_LRDetails:SetSize(right:GetWide() - 40,right:GetTall() - lbl_LRDetails.y - 30-30-32);
			lbl_LRDetails:SetText(lr:GetDescription());
			lbl_LRDetails:SetWrap(true);

			lr_selected = lr;
		end

		left:DockMargin(0,0,0,0);

		for k,v in pairs(JB.LastRequestTypes)do
			local pnl = vgui.Create("JB.Panel",left);
			pnl:SetTall(26);
			pnl:Dock(TOP);
			pnl:DockMargin(6,6,6,0);
			pnl.a = 80;
			pnl.Paint = function(self,w,h)
				draw.RoundedBox(4,0,0,w,h,JB.Color["#777"]);
				
				self.a = Lerp(0.1,self.a,self.Hover and 140 or 80);

				surface.SetMaterial(matGradient);
				surface.SetDrawColor(Color(0,0,0,self.a));
				surface.DrawTexturedRectRotated(w/2,h/2,w,h,180);

				surface.SetDrawColor(JB.Color.white);
				surface.SetMaterial(v:GetIcon());
				surface.DrawTexturedRect(5,5,16,16);

				draw.SimpleText(v:GetName(),"JBNormal",28,h/2,JB.Color.white,0,1);
			end

			local dummy = vgui.Create("Panel",pnl);
			dummy:SetSize(pnl:GetWide(),pnl:GetTall());
			dummy:SetPos(0,0);
			dummy.OnMouseReleased = function()
				selectLR(v);
			end
			dummy.OnCursorEntered = function()
				pnl.Hover = true;
			end
			dummy.OnCursorExited=function()
				pnl.Hover = false;
			end

			pnl.PerformLayout = function(self)
				dummy:SetSize(self:GetWide(),self:GetTall());
			end
		end
		
	

	end
	
	
	frame:Center();
	frame:MakePopup();
end
