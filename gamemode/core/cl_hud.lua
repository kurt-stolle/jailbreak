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



/* HINTS FOR THE SPECTATOR HUD (up here for easy access) */
local Hints = {
	"To initiate a last request, the last remaining prisoner can press F4 and choose from a number of different requests.",
	"The last guard alive may kill all prisoners, unless at the point he becomes last guard there are under three prisoners alive.",
	"The warden is the only guard who is allowed to give complicated commands, normal guards may only give simple commands (e.g. 'Move', 'Drop your weapon')",
	"At the start of each round, the guards can claim the warden rank from the F4 menu.",
	"The warden can hold C to place markers around the map.",
	"Jail Break for Garry's Mod was created by Excl. Visit the developer's website at CasualBananas.com!",
	"The warden can spawn various items and control certain options via the F4 menu.",
	"Markers placed by the warden expire two minutes after being placed.",
	"Respect your warden! Insulting your warden or disobeying orders will probably make him have you executed.",
	"You are playing the official Jail Break for Garry's Mod, version 7, a complete remake of the gamemode we all have come to love.",
	"Guards can run a little bit faster than prisoners. Make sure you only make your escape when nobody is looking!",
};

/* LIBRARIES */
local allPlayers=player.GetAll

local rad=math.rad;
local sin=JB.Util.memoize(math.sin);
local cos=JB.Util.memoize(math.cos);
local clamp=math.Clamp;
local round=math.Round;
local floor=math.floor;
local approach=math.Approach;

local noTexture=draw.NoTexture;
local roundedBox=draw.RoundedBox;
local drawText = draw.DrawText

local teamGetPlayers = team.GetPlayers;

local tableHasValue = table.HasValue;

local inputLookupBinding = input.LookupBinding;

local setDrawColor = surface.SetDrawColor;
local setMaterial = surface.SetMaterial;
local drawTexturedRect = surface.DrawTexturedRect;
local drawTexturedRectRotated = surface.DrawTexturedRectRotated;
local setFont = surface.SetFont;
local getTextSize = surface.GetTextSize;
local drawRect = surface.DrawRect;

local drawSimpleShadowText = JB.Util.drawSimpleShadowText;


/* VARIABLES */
local wardenMarkers = {}
wardenMarkers["generic"] = {text="Move",icon=Material("jailbreak_excl/pointers/generic.png")}
wardenMarkers["exclamation"] = {text="Attack",icon=Material("jailbreak_excl/pointers/exclamation.png")}
wardenMarkers["question"] = {text="Check out",icon=Material("jailbreak_excl/pointers/question.png")}
wardenMarkers["line"] = {text="Line up",icon=Material("jailbreak_excl/pointers/line.png")}
wardenMarkers["cross"] = {text="Avoid",icon=Material("jailbreak_excl/pointers/cross.png")}

local x,y,width,height; -- reusables;
local ply,dt,state,scrW,scrH; --predefined variables for every HUD loop

local yRestricted=-64;

// MATERIALS
local matHealth = Material("materials/jailbreak_excl/hud_health.png");
local matHealthBottom = Material("materials/jailbreak_excl/hud_health_bottom.png");
local matWarden = Material("materials/jailbreak_excl/hud_warden_bar.png");
local matTime = Material("materials/jailbreak_excl/hud_time.png");
local matLR = Material("materials/jailbreak_excl/lastrequest.png");
local matHint = Material("materials/jailbreak_excl/pointers/pointer_background.png");
local matQuestion = Material("materials/jailbreak_excl/pointers/question.png");
local matRestricted = Material("materials/jailbreak_excl/hud_restricted.png")

// COLORS
local color_marker = Color(255,255,255,0);
local color_marker_dark = Color(0,0,0,0);

// WARDEN PANEL
local warden;
vgui.Register("JBHUDWardenFrame",{
	Init = function(self)
		self:SetSize(256,64);
		self:SetPos(ScrW() - self:GetWide() - 16,32);
		self.Player = NULL;

		self.Avatar = vgui.Create( "AvatarImage", self )
		self.Avatar:SetSize( 32,32 )
		self.Avatar:SetPos( 13,16 )

	end,
	SetPlayer = function(self,ply)
		if not IsValid(ply) then return end

		self.Player = ply
		self.Avatar:SetPlayer( ply, 32 )
	end,
	PaintOver = function(self,w,h)
		setDrawColor(JB.Color.white);
		setMaterial(matWarden);
		drawTexturedRect(0,0,256,64);

		if IsValid(self.Player) then
			//draw.SimpleText(self.Player:Nick(),"JBNormalShadow",62,h/2,JB.Color.black,0,1);
			drawSimpleShadowText(self.Player:Nick(),"JBNormal",62,h/2,JB.Color.white,0,1);
		end
	end,
},"Panel");
hook.Add("Think","JB.Think.PredictWardenFrame",function()
	if IsValid(warden) and (not IsValid(JB:GetWarden()) or warden.Player ~= JB:GetWarden()) then
		warden:Remove();
		warden=nil;
	end

	if IsValid(JB:GetWarden()) and not IsValid(warden) then
		warden=vgui.Create("JBHUDWardenFrame");
		warden:SetPlayer(JB:GetWarden());

		notification.AddLegacy(warden.Player:Nick().." is the warden",NOTICE_GENERIC);
	end
end);

// UTILITY FUNCTIONS
local r;
local function drawHealth(x,y,w,radius,amt)
	for a = amt, amt + 180 * amt / 100 do
		r=rad(a)* 2
		drawTexturedRectRotated(x / 2 + cos(r) * radius, y / 2 - sin(r) * radius, w,10, a * 2)
	end
end
local function convertTime(t)
	if t < 0 then
		t = 0;
	end

	local sec = tostring( round(t - floor(t/60)*60));
	if string.len(sec) < 2 then
		sec = "0"..sec;
	end
	return (tostring( floor(t/60) ).." : "..sec )
end

// Health and ammo
local healthMemory = 0;
local health = 0;
local wide_hp_1,wide_hp_2,height_hp;
local activeWeapon;
local text_ammo;
local drawAmmoHealth = function()
	health= clamp(ply:Health(),0,100);
	healthMemory = approach(healthMemory,health,dt*50);
	health=tostring(health);

	setDrawColor(JB.Color.white);
	setMaterial(matHealthBottom);
	drawTexturedRect(0,0,256,256);

	noTexture();
	setDrawColor(JB.Color["#CF1000"]);

	drawHealth(256,256,24,86,healthMemory);

	setFont("JBExtraLarge");
	wide_hp_1,height = getTextSize(health);
	setFont("JBSmall");
	wide_hp_2 = getTextSize(" %\n HP");

	activeWeapon = ply:GetActiveWeapon();

	if IsValid(activeWeapon) and activeWeapon:Clip1() ~= -1 and activeWeapon:GetClass() ~= "weapon_gravgun" then
		y = 64+32+12;

		drawSimpleShadowText(health,"JBExtraLarge",128-(wide_hp_1 + wide_hp_2)/2,y-height/2 - 6,JB.Color["#DCDCDC"],0,0);
		drawText(" %\n HP ","JBSmallShadow",128-(wide_hp_1 + wide_hp_2)/2 + wide_hp_1,y-height/2,JB.Color.black,0,0);
		drawText(" %\n HP ","JBSmall",128-(wide_hp_1 + wide_hp_2)/2 + wide_hp_1,y-height/2,JB.Color["#DCDCDC"],0,0);

		setDrawColor(JB.Color["#DCDCDC"]);
		drawRect(128-40,128-2,1 + clamp(79 * (tonumber(ply:GetActiveWeapon():Clip1())/tonumber(ply:GetActiveWeapon().Primary and ply:GetActiveWeapon().Primary.ClipSize or 10)),0,79),4);

		y = 128+16;
		text_ammo = ply:GetActiveWeapon():Clip1() .. "/" .. ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType());

		drawSimpleShadowText("AMMO","JBExtraSmall",128-40,y,JB.Color["#DCDCDC"],0,1);
		drawSimpleShadowText(text_ammo,"JBNormal",128+40,y,JB.Color["#DCDCDC"],2,1);
	else
		drawSimpleShadowText(health,"JBExtraLarge",128-(wide_hp_1 + wide_hp_2)/2,128-height/2 - 6,JB.Color["#DCDCDC"],0,0);
		drawText(" %\n HP ","JBSmallShadow",128-(wide_hp_1 + wide_hp_2)/2 + wide_hp_1,128-height/2,JB.Color.black,0,0);
		drawText(" %\n HP ","JBSmall",128-(wide_hp_1 + wide_hp_2)/2 + wide_hp_1,128-height/2,JB.Color["#DCDCDC"],0,0);
	end

	setDrawColor(JB.Color.white);
	setMaterial(matHealth);
	drawTexturedRect(0,0,256,256);
end

// Spectator
local specPosScreen,plySpec,players;
local hint;
local color_hint_questionmark = Color(255,255,255,0);
local colorHintMakeZero = false;
local newHint = function()
	setFont("JBSmall");
	hint=string.Explode("\n",JB.Util.formatLine(Hints[math.random(1,#Hints)],512-(128-16)),false);
	colorHintMakeZero=true;
end
newHint();
local drawSpectatorHUD = function()
	players=allPlayers();

	for i=1, #players do
		plySpec=players[i];
		if plySpec:Alive() and (plySpec:Team() == TEAM_GUARD or plySpec:Team() == TEAM_PRISONER) then
			specPosScreen = (plySpec:EyePos() + Vector(0,0,20)):ToScreen();
			x,y=specPosScreen.x,specPosScreen.y;
			specPosScreen = nil;

			local alpha = 50;
			if ply:EyePos():Distance( plySpec:GetPos() ) < 1000 then
				alpha = 255;
			end

			drawSimpleShadowText(plySpec:Nick(),"JBNormal",x,y,Color(255,255,255,alpha),1,1);

			local col = table.Copy(JB.Color["#CF1000"]);
			col.a = alpha;

			roundedBox(2,x - 30,y + 10,60,4,Color(0,0,0,alpha));
			roundedBox(0,x - 30 + 1,y + 10 + 1,(60-2)*clamp(plySpec:Health()/100,0,1),2,col);
			roundedBox(0,x - 30 + 1,y + 10 + 1,(60-2)*clamp(plySpec:Health()/100,0,1),1,Color(255,255,255,15 * alpha/255));
		end
	end

	//hint
	x,y=scrW/2 - 256,scrH-128;

	setDrawColor(JB.Color.white);
	setMaterial(matHint);
	drawTexturedRect(x,y,128,128);

	color_hint_questionmark.a = Lerp(colorHintMakeZero and dt*20 or dt*5,color_hint_questionmark.a,colorHintMakeZero and 0 or 255);
	if colorHintMakeZero and color_hint_questionmark.a < 1 then
		colorHintMakeZero = false;
	end
	setDrawColor(color_hint_questionmark);
	setMaterial(matQuestion);
	drawTexturedRect(x+32+16,y+32+16,32,32);

	x,y = x+128-8,y+30;
	width,height = drawSimpleShadowText("Did you know?","JBNormal",x,y,JB.Color.white,0,0);
	y=y+height+2;

	for i=1,#hint do
		width,height=drawSimpleShadowText(hint[i],"JBSmall",x,y,JB.Color["#eee"],0,0);
		y=y+height;
	end
end
timer.Create("JB.HUD.NewHint",8,0,newHint);

// TIMER
local drawTimer = function()
	y = 32;
	if IsValid(warden) then
		y = warden.y + warden:GetTall();
	end

	setDrawColor(JB.Color.white);
	setMaterial(matTime);
	drawTexturedRect(scrW-16-128,y,128,64);

	local timerText = state == STATE_IDLE and "WAITING" or state == STATE_ENDED and "ENDED" or state == STATE_MAPVOTE and "MAPVOTE" or
	convertTime(60*(state == STATE_LASTREQUEST and 3 or 10) - (CurTime() - JB.RoundStartTime));

	drawSimpleShadowText(timerText,"JBNormal",scrW-16-64,y+32,JB.Color.white,1,1);
end

// LAST REQUEST
local lrGuard,lrPrisoner;
local drawLastRequest = function()
	setMaterial(matLR)
	setDrawColor(JB.Color.white)

	drawTexturedRect(scrW/2 - 256, 4,512,128);

	-- unpack from table;
	lrGuard,lrPrisoner = unpack(JB.LastRequestPlayers);

	-- convert to string
	lrGuard = IsValid(lrGuard) and lrGuard:Nick() or "ERROR!";
	lrPrisoner = IsValid(lrPrisoner) and lrPrisoner:Nick() or "ERROR!";

	drawSimpleShadowText(lrPrisoner,"JBNormal",scrW/2 + 28, 4 + 64,JB.Color.white,0,1);
	drawSimpleShadowText(lrGuard,"JBNormal",scrW/2 - 28, 4 + 64,JB.Color.white,2,1);
end

// POINTER
local posMarkerScreen,marker;
local drawWardenPointer = function()
	posMarkerScreen = (JB.TRANSMITTER:GetJBWarden_PointerPos()):ToScreen();

	x = clamp(posMarkerScreen.x,32,scrW-64);
	y = clamp(posMarkerScreen.y,32,scrH-64) - 8;

	marker= wardenMarkers[JB.TRANSMITTER:GetJBWarden_PointerType()];

	color_marker.a = (posMarkerScreen.x ~= x or posMarkerScreen.y ~= y+8) and 100 or 255;
	color_marker_dark.a = color_marker.a;
	setMaterial(marker.icon);

	setDrawColor(color_marker);
	drawTexturedRect(x-16,y-16,32,32);

	drawSimpleShadowText(marker.text,"JBNormal",x,y+16,color_marker,1,0);

	// note: 64unit = 1.22meters
	drawSimpleShadowText(tostring(math.floor(LocalPlayer():EyePos():Distance(JB.TRANSMITTER:GetJBWarden_PointerPos()) * 1.22/64)).."m","JBSmall",x,y+34,color_marker,1,0);
end

// GM HOOK
local hookCall = hook.Call;
JB.Gamemode.HUDPaint = function(gm)
	ply = LocalPlayer();

	if not IsValid(ply) then return end

	scrW,scrH,dt=ScrW(),ScrH(),FrameTime();

	state = JB.State;

	if ply:Alive() then
		drawAmmoHealth(); // alive and well

		-- ES support
		if ES and ES.NotificationOffset then
			ES.NotificationOffset.x = 24
			ES.NotificationOffset.y = 232
		end

	else
		drawSpectatorHUD(); // Spectator or dead.

		-- ES support
		if ES and ES.NotificationOffset then
			ES.NotificationOffset.x = 24
			ES.NotificationOffset.y = 24
		end
	end

	drawTimer();

	if JB.State == STATE_LASTREQUEST and JB.LastRequest ~= "0" then
		drawLastRequest();
	end

	if #teamGetPlayers(TEAM_GUARD) < 1 or #teamGetPlayers(TEAM_PRISONER) < 1 then
		drawText("A new round can not start until there is at least one player on both teams.\nWait for somebody to join the empty team.","JBNormalShadow",scrW/2,scrH * .6,JB.Color.black,1,1);
		drawText("A new round can not start until there is at least one player on both teams.\nWait for somebody to join the empty team.","JBNormal",scrW/2,scrH * .6,JB.Color.white,1,1);
	end

	if IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_PointerPos() and JB.TRANSMITTER:GetJBWarden_PointerType() and wardenMarkers[JB.TRANSMITTER:GetJBWarden_PointerType()] then
		drawWardenPointer();
	end

	JB.Gamemode:HUDDrawTargetID();  -- not calling hook, we don't want any addons messing with this.
	hookCall("HUDPaintOver",JB.Gamemode)
end;

// TARGET ID
local uniqueid,ent,text_x,text_y,text,text_sub,text_wide,text_tall,text_color;
JB.Gamemode.HUDDrawTargetID = function()
	if LocalPlayer():GetObserverMode() ~= OBS_MODE_NONE then return end

	ent = LocalPlayer():GetEyeTrace().Entity;

	if (not IsValid(ent) ) then return end;

	text = "ERROR"
	text_sub = "Something went terribly wrong!";

	if (ent:IsPlayer()) then
		text = ent:Nick()
		text_sub = ent:GetPos():Distance(LocalPlayer():EyePos()) < 200 and (ent:Health().."% HP"..(ent.GetRebel and ent:GetRebel() and " | Rebel" or ent.GetWarden and ent:GetWarden() and " | Warden" or ""));
		text_color = team.GetColor(ent:Team());
	elseif (ent:IsWeapon()) then
		local tab=weapons.Get(ent:GetClass())
		text = tab and tab.PrintName or ent:GetClass();
		if( tableHasValue(JB.LastRequestPlayers,LocalPlayer()) and JB.LastRequestTypes[JB.LastRequest] and not JB.LastRequestTypes[JB.LastRequest]:GetCanPickupWeapons() ) then
			text_sub = "Can not pick up in LR";
		else
			local bind = inputLookupBinding("+use");
			text_sub = ent:GetPos():Distance(LocalPlayer():EyePos()) > 200 and "" or ((not bind) and "Bind a key to +use to pick up") or ("Press "..bind.." to pick up");
		end

		text_color = JB.Color.white;
	else
		return
	end

	text_x,text_y = scrW/2, scrH *.6;
	drawSimpleShadowText(text,"JBNormal",text_x,text_y,text_color,1,1);

	if text_sub and text_sub ~= "" then

		setFont("JBNormal");
		text_wide,text_tall = getTextSize(text);

		text_y = text_y + text_tall*.9;

		drawSimpleShadowText(text_sub,"JBSmall",text_x,text_y,JB.Color.white,1,1);

	end
end

function JB.Gamemode:HUDShouldDraw(element)
	return (element ~= "CHudHealth" and element ~= "CHudBattery" and element ~= "CHudAmmo" and element ~= "CHudSecondaryAmmo" and element ~= "CHudMessage" and element ~= "CHudWeapon");
end
