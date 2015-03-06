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



local PANEL = {}
local PlayerVoicePanels = {}
local matAva = Material("materials/jailbreak_excl/scoreboard_avatar.png");
function PANEL:Init()

	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "JBNormal" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 14, 0, 0, 0 )
	self.LabelName:SetTextColor( JB.Color.white )
	self.LabelName:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT );
	self.Avatar:SetSize( 32, 32 )


	self.Color = JB.Color["#aaa"];

	self:SetSize( 250, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 0, 6, 0, 6 )
	self:Dock( BOTTOM )

	self.SoundLines = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

	self:NoClipping(true);
end

function PANEL:Setup( ply )

	self.ply = ply
	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	self.Color.a = 50;
	
	self:InvalidateLayout()

end

local iconWarden=Material("icon16/asterisk_yellow.png");
local matGradient=Material("jailbreak_excl/gradient.png");
function PANEL:Paint( w, h )
	if ( !IsValid( self.ply ) ) then return end

	draw.RoundedBox( 0, 20, 4, w - 20, h-8, JB.Color.black )
	draw.RoundedBox( 0, 21, 5, w-2 - 20, h-10, JB.Color["#111"] )

	self.Color.a = 2
	surface.SetDrawColor(self.Color);
	surface.SetMaterial(matGradient);
	surface.DrawTexturedRectRotated(20 + (w-20)/2,h/2,w-2 - 20, h-10,180);

	for i=1,60 do
		self.Color.a = (30 - (math.sin(math.pi/2 - (i/30 * math.pi)) * 30));
		surface.SetDrawColor(self.Color);
		surface.DrawRect(w-(3*i),h/2-(self.SoundLines[i]*24/2),1,1+self.SoundLines[i]*24);
	end

	if self.ply.GetWarden and self.ply:GetWarden() then
		surface.SetDrawColor(JB.Color.white);
		surface.SetMaterial(iconWarden);
		surface.DrawTexturedRect(w - 16 - (h-16)/2, (h-16)/2, 16, 16);
	end
end
function PANEL:PaintOver()
	if not IsValid(self.ply) or not IsValid(self.Avatar) then return end

	local w,h = self.Avatar:GetSize();

	local col = team.GetColor(self.ply:Team());
	if not self.ply:Alive() then
		col.r = math.Clamp(col.r *.6,0,255);
		col.g = math.Clamp(col.g *.6,0,255);
		col.b = math.Clamp(col.b *.6,0,255);
	end
		
	if self.ply == LocalPlayer() then
		local add = math.abs(math.sin(CurTime() * 1) * 30);
		col.r = math.Clamp(col.r +add,0,255);
		col.g = math.Clamp(col.g +add,0,255);
		col.b = math.Clamp(col.b +add,0,255);
	end
		
	surface.SetDrawColor(col);
	surface.SetMaterial(matAva);
	surface.DrawTexturedRectRotated(self.Avatar.x + h/2,self.Avatar.y + h/2,64,64,0);
end

function PANEL:Think( )
	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end

	if not IsValid(self.ply) then return end

	if not self.nextLine or self.nextLine <= CurTime() then
		self.nextLine = CurTime() + 1/60 -- This will make the effect cap at 60 fps.

		local vol = (self.ply == LocalPlayer()) and math.Rand(0,1) or self.ply:VoiceVolume();



		table.insert(self.SoundLines,1,Lerp(0.4,self.SoundLines[1],vol));
		table.remove(self.SoundLines,61);
	end
end

function PANEL:FadeOut( anim, delta, data )
	if ( anim.Finished ) then
	
		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil
			return
		end
		
	return end
			
	self:SetAlpha( 255 - (255 * delta) )
end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

function GM:PlayerStartVoice( ply )

	if ( !IsValid( g_VoicePanelList ) ) then return end
	
	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )


	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

		if ( PlayerVoicePanels[ ply ].fadeAnim ) then
			PlayerVoicePanels[ ply ].fadeAnim:Stop()
			PlayerVoicePanels[ ply ].fadeAnim = nil
		end

		PlayerVoicePanels[ ply ]:SetAlpha( 255 )

		return;

	end

	if ( !IsValid( ply ) ) then return end

	local pnl = g_VoicePanelList:Add( "VoiceNotify" )
	pnl:Setup( ply )
	
	PlayerVoicePanels[ ply ] = pnl
end

timer.Create( "JB.VoiceClean", 10, 0, function()
	for k, v in pairs( PlayerVoicePanels ) do
		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end
	end
end )
timer.Remove("VoiceClean");

function JB.Gamemode:PlayerEndVoice( ply )
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end

		PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
		PlayerVoicePanels[ ply ].fadeAnim:Start( .1 )
	end
end

hook.Add( "InitPostEntity", "JB.InitPostEntity.CreateVoiceVGUI", function()

	g_VoicePanelList = vgui.Create( "DPanel" )

	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetPos( ScrW() - 250, 50 )
	g_VoicePanelList:SetSize( 250, ScrH() - 100 )
	g_VoicePanelList:SetDrawBackground( false )

end )
hook.Remove("InitPostEntity","CreateVoiceVGUI");