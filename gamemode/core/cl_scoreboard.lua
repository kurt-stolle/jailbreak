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

-- Support for admin mods below
(FindMetaTable("Player"))._jbGetRank = function(self)
	if ES then -- This server uses ExcLServer
		return (self:ESGetRank():GetPower() > 0 and self:ESGetRank():GetPrettyName()) or "";
	else -- This server uses an unknown admin mod
		return self:GetUserGroup() or ""
	end
end

-- Scoreboard
local scoreboard;
local matEdge = Material("materials/jailbreak_excl/scoreboard_edge.png");
local matMiddle = Material("materials/jailbreak_excl/scoreboard_middle.png");
local matAva = Material("materials/jailbreak_excl/scoreboard_avatar.png");
local color_faded = Color(0,0,0,100)
vgui.Register("JBScoreboard.PlayerRow",{
	Init = function( self )

		self.Avatar		= vgui.Create( "AvatarImage", self )
		self.Avatar:SetSize( 32,32 )
		self.Avatar:SetMouseInputEnabled( false )

		self:Dock( TOP )
		self:SetHeight(64)
		self:DockMargin( 8,0,-24,-12 )

	end,
	PerformLayout = function(self)
		if not IsValid(self.Player) then return end

		local w,h = self:GetWide(), self:GetTall();
		self.Avatar:SetPos(h/2 - self.Avatar:GetTall()/2, h/2 - self.Avatar:GetTall()/2);
	end,
	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl, 32 )

		self:Think();
		self:PerformLayout();

	end,
	OnCursorEntered = function(self)
		self.hover = true;
	end,
	OnCursorExited = function(self)
		self.hover = false;
	end,
	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:MakeInvalid()
			return
		end

		if ( !self.Player:Alive() ) then
			self:SetZPos( 1000 )
		else
			self:SetZPos(0);
		end

	end,
	MakeInvalid = function(self)
		self:SetZPos(2000);
		self:Remove();
	end,
	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--rank
		if self.Player:_jbGetRank() ~= "" then
			local x = 70;
			surface.SetFont("JBExtraSmall")
			local w,h = surface.GetTextSize(self.Player:_jbGetRank())
			draw.RoundedBoxEx(6,x,2,w+12,h+4,JB.Color.black,true,true,false,false)
			draw.RoundedBoxEx(4,x+1,3,w+10,h+4,JB.Color["#222"],true,true,false,false)
			draw.SimpleText(self.Player:_jbGetRank(),"JBExtraSmall",x+6,8,white,0,1)
		end


		surface.SetDrawColor(self.Player:Alive() and JB.Color.white or JB.Color["#AAA"]);

		surface.SetMaterial(matEdge);
		surface.DrawTexturedRectRotated(w-h/2,h/2,64,64,180);

		surface.SetMaterial(matMiddle);
		surface.DrawTexturedRectRotated(math.Round(w/2) - 16,h/2,math.Round(w - 64 - 32),64,0);

	end,
	OnMouseReleased=function(self)
		if LocalPlayer():IsAdmin() then

			local m = DermaMenu()

			m:AddOption( "Force swap", function() RunConsoleCommand("jb_admin_swap",self.Player:SteamID() or "0"); end )
			m:AddOption( "Make spectator", function() RunConsoleCommand("jb_admin_swap_spectator",self.Player:SteamID() or "0"); end )
			m:AddOption( "Revive", function() RunConsoleCommand("jb_admin_revive",self.Player:SteamID() or "0"); end )

			m:Open()

			JB:DebugPrint("Opened admin menu.");
		else
			JB:DebugPrint("Failed to open admin menu. Not an admin.");
		end
	end,
	PaintOver = function(self,w,h)
		if ( !IsValid( self.Player ) ) then
			return
		end

		local col = team.GetColor(self.Player:Team());
		if not self.Player:Alive() then
			col.r = math.Clamp(col.r *.6,0,255);
			col.g = math.Clamp(col.g *.6,0,255);
			col.b = math.Clamp(col.b *.6,0,255);
		end

		if self.Player == LocalPlayer() then
			local add = math.abs(math.sin(CurTime() * 1) * 50);
			col.r = math.Clamp(col.r +add,0,255);
			col.g = math.Clamp(col.g +add,0,255);
			col.b = math.Clamp(col.b +add,0,255);
		end

		surface.SetDrawColor(col);
		surface.SetMaterial(matAva);
		surface.DrawTexturedRectRotated(h/2,h/2,64,64,0);

		local white = self.Player:Alive() and JB.Color.white or JB.Color["#BBB"]

		--Name
		local name=(self.hover and (self.Player:Deaths().." rounds" or "")..(ES and ", "..math.floor(tonumber(self.Player:ESGetNetworkedVariable("playtime",0))/60).." hours playtime" or "")) or self.Player:Nick();
		draw.SimpleText(name,"JBSmallShadow",self.Avatar.x + self.Avatar:GetWide() + 16,h/2 - 1,JB.Color.black,0,1);
		draw.SimpleText(name,"JBSmall",self.Avatar.x + self.Avatar:GetWide() + 16,h/2 - 1,white,0,1);

		--Ping
		draw.SimpleText(self.Player:Ping(),"JBSmallShadow",self:GetWide() - 32 - 24,h/2 - 1,JB.Color.black,1,1);
		draw.SimpleText(self.Player:Ping(),"JBSmall",self:GetWide() - 32 - 24,h/2 - 1,white,1,1);

		--score
		surface.SetDrawColor(color_faded)
		surface.DrawRect(self:GetWide()-64-42,16,36,32)
		local score=self.Player:Frags()..":"..self.Player:Deaths();
		draw.SimpleText(score,"JBSmallShadow",self:GetWide() - 64-24,h/2 - 1,JB.Color.black,1,1);
		draw.SimpleText(score,"JBSmall",self:GetWide() - 64-24,h/2 - 1,white,1,1);

		--status
		if self.Player.GetWarden and self.Player:GetWarden() then
			draw.SimpleText("Warden","JBLargeBold",self:GetWide()/2 + 26,26,color_faded,1)
		elseif self.Player.GetRebel and self.Player:GetRebel() then
			draw.SimpleText("Rebel","JBLargeBold",self:GetWide()/2 + 30,26,color_faded,1)
		end
	end
},"Panel");

vgui.Register("JBScoreboard.PlayerRow.Spectator",{
	Init = function( self )

		self.Avatar		= vgui.Create( "AvatarImage", self )
		self.Avatar:SetSize( 32,32 )
		self.Avatar:SetMouseInputEnabled( false )

		self:SetSize(64,64)
	end,
	PerformLayout = function(self)
		if not IsValid(self.Player) then return end

		local w,h = self:GetWide(), self:GetTall();
		self.Avatar:SetPos(w/2 - self.Avatar:GetTall()/2, h/2 - self.Avatar:GetTall()/2);

	end,
	Setup = function( self, pl )
		self.Player = pl

		self.Avatar:SetPlayer( pl, 32 )

		self:Think();
		self:PerformLayout();
	end,

	Think = function( self )
		if ( !IsValid( self.Player ) ) then
			self:MakeInvalid()
			return
		end
	end,
	MakeInvalid = function(self)
		self:Remove();
	end,
	OnCursorEntered = function(self)
		if scoreboard.y < 0 then return end

		local xSc,ySc = self:LocalToScreen( self:GetWide()/2,self:GetTall()/2 );
		self.namePanel = vgui.Create("Panel");
		self.namePanel:SetSize(900,24+8);
		self.namePanel:NoClipping(false);
		self.namePanel.ColorText = Color(255,255,255,0);
		self.namePanel.PaintOver = function(this,w,h)
			if not IsValid(self.Player) then return end

				local w2=math.floor(this.wMv or 0);


				surface.SetDrawColor(JB.Color.black);
				draw.NoTexture();
				surface.DrawPoly{
					{x=w/2 - 4, y = h-8},
					{x=w/2 + 4, y = h-8},
					{x=w/2, y=h}
				}

			h=h-8;


			draw.RoundedBox(2,w/2 -w2/2,0,w2,h,JB.Color.black);
			draw.RoundedBox(4,w/2 -w2/2 + 2,2,w2-4,h-4,JB.Color["#111"]);

			this.ColorText.a = Lerp(FrameTime()*1,this.ColorText.a,255);

			w = JB.Util.drawSimpleShadowText(self.Player:Nick(),"JBSmall",w/2,h/2,this.ColorText,1,1);
			this.wMv = Lerp(FrameTime()*18,this.wMv or 8,w + 12);

		end
		self.namePanel.Think = function(this)
			if not IsValid(self) or not self:IsVisible() or not IsValid(scoreboard) or not scoreboard.Expand or not scoreboard:IsVisible() or ( IsValid(this) and not IsValid(self.namePanel) ) then this:Remove(); end
		end
		self.namePanel:SetPos(xSc - self.namePanel:GetWide()/2,ySc - 44 - self.namePanel:GetTall()/2);
	end,
	OnCursorExited = function(self)
		if IsValid(self.namePanel) then
			self.namePanel:Remove();
		end
		self.namePanel = nil;
	end,
	PaintOver = function(self,w,h)
		if ( !IsValid( self.Player ) ) then
			return
		end

		local col = team.GetColor(self.Player:Team());

		if self.Player == LocalPlayer() then
			local add = math.abs(math.sin(CurTime() * 1) * 50);
			col.r = math.Clamp(col.r +add,0,255);
			col.g = math.Clamp(col.g +add,0,255);
			col.b = math.Clamp(col.b +add,0,255);
		end

		surface.SetDrawColor(col);
		surface.SetMaterial(matAva);
		surface.DrawTexturedRectRotated(w/2,h/2,64,64,0);
	end
},"Panel");

local color_text = Color(255,255,255,0);
local color_shadow = Color(0,0,0,0);
local color_hidden = Color(0,0,0,0);
vgui.Register("JBScoreboard",{
	Init = function( self )
		self.Expand = true;

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )
		self.Header:DockMargin(0,0,0,20)

		self.Footer = self:Add( "Panel" )
		self.Footer:Dock( BOTTOM )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "JBExtraExtraLarge" )
		self.Name:SetTextColor( color_text )
		self.Name:Dock( TOP )
		self.Name:SizeToContents();
		self.Name:SetContentAlignment( 5 )
		self.Name:SetText("Jail Break 7");

		self.Spectators = self.Footer:Add( "DLabel" )
		self.Spectators:SetFont("JBNormal");
		self.Spectators:SetTextColor( color_text );
		self.Spectators:Dock(TOP);
		self.Spectators:SetContentAlignment( 5 )
		self.Spectators:SetText("Spectators");
		self.Spectators:SizeToContents();
		self.Spectators:DockMargin(0,3,0,0);


		self.ScoresSpectators = self.Footer:Add("Panel");
		self.ScoresSpectators:Dock(TOP);
		self.ScoresSpectators.Think = function(this)
			if not self:IsVisible() then return end

			local count=#this:GetChildren()
			local perRow=math.floor(this:GetWide()/64);
			local rows=math.ceil(count/perRow);

			local row_current = 1;
			local lastRowCount = count - (perRow*(rows-1));
			local x = this:GetWide()/2 - (perRow*64)/2;
			local y = 8;
			local isFirst= true;
			for k,v in ipairs(this:GetChildren())do
				if not IsValid(v) then continue end

				x=x+64;
				if x > perRow*64 then
					x=this:GetWide()/2 - (perRow*64)*2;
					row_current=row_current+1;
					isFirst = true;
					y=y+64+4;
				end

				if row_current == rows and isFirst then
					x= this:GetWide()/2 - (lastRowCount*64)/2 + 32;
				end

				v.x = x - 32;
				v.y = y;

				isFirst = false;
			end
		end

		self.Host = self.Header:Add( "DLabel" )
		self.Host:SetFont("JBNormal");
		self.Host:SetTextColor( color_text );
		self.Host:Dock(TOP);
		self.Host:SetContentAlignment( 5 )
		self.Host:SetText("A gamemode by Excl, hosted by "..JB.Config.website);
		self.Host:SizeToContents();

		self.ScoresGuards = self:Add( "DScrollPanel" )
		self.ScoresGuards:Dock( LEFT )

		self.ScoresPrisoners = self:Add( "DScrollPanel" )
		self.ScoresPrisoners:Dock( RIGHT )


		self:SetSize( 700, ScrH() - 200 )
		self.y = -self:GetTall();
		self.x = ScrW()/2 - self:GetWide()/2;

		self.ySmooth = self.y;
	end,

	PerformLayout = function( self )
		self.ScoresGuards:SetWide(self:GetWide()/2 - 8);
		self.ScoresPrisoners:SetWide(self:GetWide()/2 - 8);
		self.Host:SetWide(self:GetWide());

		self.ScoresGuards:PerformLayout();
		self.ScoresPrisoners:PerformLayout();

		self.ScoresSpectators:SetSize(self.Footer:GetWide(),math.ceil(#self.ScoresSpectators:GetChildren()/(self.ScoresSpectators:GetWide()/64))*64+8*2);

		self.Header:SetHeight( self.Name:GetTall()+20 )
		local max = 0;
		for k,v in pairs(self.Footer:GetChildren())do
			if v.y + v:GetTall() > max then
				max = v.y + v:GetTall();
			end
		end

		self.Footer:SetHeight(max);
	end,

	Paint = function( self, w, h )
		//DrawToyTown(2,ScrH());
	end,

	Think = function( self  )

		local w,h = self:GetWide(),self:GetTall();

		if not self.Expand then
			if math.floor(self.y) > -h then
				color_text.a = Lerp(FrameTime()*12,color_text.a,0);
				color_shadow.a = color_text.a * .8;

				if math.floor(color_text.a) <= 1 then
					self.ySmooth = Lerp(FrameTime()*3,self.ySmooth,-h);
					self.y = math.Round(self.ySmooth);
				end

				self.Name:SetTextColor( color_text )
				self.Host:SetTextColor( color_text );
				self.Name:SetExpensiveShadow( 2, color_shadow )
				self.Host:SetExpensiveShadow( 1, color_shadow )

				if #self.ScoresSpectators:GetChildren() <= 0 then
					self.Spectators:SetTextColor( color_hidden );
					self.Spectators:SetExpensiveShadow( 1, color_hidden )
				else
					self.Spectators:SetTextColor( color_text );
					self.Spectators:SetExpensiveShadow( 1, color_shadow )
				end
			elseif self:IsVisible() and not self.Expand and math.floor(self.ySmooth) <= -h + 1 then
				self:Hide();
				color_text.a = 0;
				JB:DebugPrint("Scoreboard hidden");
			end

			return
		end

		local target = (ScrH()/2 - h/2);

		self.ySmooth = Lerp(FrameTime()*10,self.ySmooth,target);
		self.y = math.Round(self.ySmooth);

		if math.ceil(self.ySmooth) >= target then
			color_text.a = Lerp(FrameTime()*2,color_text.a,255);
			color_shadow.a = color_text.a * .8;

			self.Name:SetTextColor( color_text )
				self.Host:SetTextColor( color_text );

				if #self.ScoresSpectators:GetChildren() <= 0 then
					self.Spectators:SetTextColor( color_hidden );
					self.Spectators:SetExpensiveShadow( 1, color_hidden )
				else
					self.Spectators:SetTextColor( color_text );
					self.Spectators:SetExpensiveShadow( 1, color_shadow )
				end
				self.Name:SetExpensiveShadow( 2, color_shadow )
				self.Host:SetExpensiveShadow( 1, color_shadow )

		end

		for id, pl in pairs( player.GetAll() ) do
			if ( IsValid( pl.ScoreEntry ) ) then
				if (pl:Team() ~= pl.ScoreEntry.Team or (not IsValid(pl.ScoreEntry.scoreboard)) or pl.ScoreEntry.scoreboard ~= self) then
					JB:DebugPrint("Removed invalid score panel");
					pl.ScoreEntry:MakeInvalid();
				else
					continue;
				end
			end

			if pl:Team() == TEAM_GUARD or pl:Team() == TEAM_PRISONER then

				pl.ScoreEntry = vgui.Create("JBScoreboard.PlayerRow" );
				pl.ScoreEntry:Setup( pl );


				if pl:Team() == TEAM_PRISONER then
					self.ScoresPrisoners:AddItem( pl.ScoreEntry );
					pl.ScoreEntry.scoreboard = self;
					pl.ScoreEntry.Team = TEAM_PRISONER;
				elseif pl:Team() == TEAM_GUARD then
					self.ScoresGuards:AddItem( pl.ScoreEntry );
					pl.ScoreEntry.scoreboard = self;
					pl.ScoreEntry.Team = TEAM_GUARD;
				end
			elseif pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED then
				pl.ScoreEntry = self.ScoresSpectators:Add("JBScoreboard.PlayerRow.Spectator");
				pl.ScoreEntry:Setup(pl);
				pl.ScoreEntry.scoreboard = self;
				pl.ScoreEntry.Team = pl:Team();
			end
		end

	end,
},"Panel");

timer.Create("JB.Scoreboard.UpdateLayout",1,0,function()
	if IsValid(scoreboard) then
		scoreboard:PerformLayout();
	end
end);


JB.Gamemode.ScoreboardShow = function()
	if ( !IsValid( scoreboard ) ) then
		scoreboard = vgui.Create("JBScoreboard");
	end

	if ( IsValid( scoreboard ) ) then
		scoreboard.Expand = true;
		scoreboard:Show()
		//scoreboard:MakePopup()
		gui.EnableScreenClicker(true);
		scoreboard:SetKeyboardInputEnabled( false )

		JB:DebugPrint("Scoreboard shown");
	end
end

JB.Gamemode.ScoreboardHide = function()
	if ( IsValid( scoreboard ) ) then
		scoreboard.Expand = false;
		gui.EnableScreenClicker(false);
	end
end
