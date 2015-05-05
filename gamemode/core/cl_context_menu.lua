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



local matPointerBg = Material("jailbreak_excl/pointers/pointer_background.png");
local bubbles = {};

local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag;
local pushFilterMin = render.PushFilterMin;
local popFilterMag = render.PopFilterMag;
local popFilterMin = render.PopFilterMin;
local setColor = surface.SetDrawColor;
local setMaterial = surface.SetMaterial;
local drawTexturedRect = surface.DrawTexturedRect;

local matrix = Matrix()
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)
local scale=1;

local size = 350;

local x,y,steps,mul;

local selection=0;

local contextEnabled = false;

local color=Color(255,255,255,0);
local color_black = Color(0,0,0,0);
hook.Add("HUDPaintOver","JB.HUDPaintOver.PaintContextMenu",function()


	mul=FrameTime()*10;

	scale = Lerp(mul,scale,contextEnabled and 1 or 0);
	color.a = Lerp(mul,color.a,contextEnabled and 255 or 0)
	color_black.a = color.a;

	if (color.a < 1) then return end

	x,y = ScrW()/2 - ((size + 128)*scale)/2,ScrH()/2 - ((size + 128)*scale)/2;
	pushFilterMag( TEXFILTER.ANISOTROPIC )
	pushFilterMin( TEXFILTER.ANISOTROPIC )

	matrix=Matrix();
	matrixTranslation.x = x;
	matrixTranslation.y = y;
	matrix:SetTranslation( matrixTranslation )
	matrixScale.x = scale;
	matrixScale.y = scale;
	matrix:Scale( matrixScale )

	steps = 2 * math.pi / #bubbles;

	pushModelMatrix( matrix )
		for k,v in pairs(bubbles)do
			if not v.ang then v.ang = 0 end;
			v.ang= Lerp(mul,v.ang,(math.pi + (k-1)*steps) % (2*math.pi));

			x,y=  (size + 64)/2 + math.sin(v.ang) * size/2,(size + 64)/2 + math.cos(v.ang) * size/2;

			setMaterial(matPointerBg);

			if not v.color then v.color = Color(50,50,50,0) end

			v.color.a = color.a;
			if v.selected then
				v.color.r = Lerp(mul,v.color.r,255);
				v.color.g = Lerp(mul,v.color.g,255);
				v.color.b = Lerp(mul,v.color.b,255);
			else
				v.color.r = Lerp(mul,v.color.r,180);
				v.color.g = Lerp(mul,v.color.g,180);
				v.color.b = Lerp(mul,v.color.b,180);
			end

			setColor(v.color);
			drawTexturedRect(x-32,y-32,128,128);

			if v.icon then
				setMaterial(v.icon);
				drawTexturedRect(x+16,y+16,32,32);
			end
			draw.DrawText(v.text,"JBNormalShadow",x+32,y+64+14,color_black,1);
			draw.DrawText(v.text,"JBNormal",x+32,y+64+14,color,1);
		end
	popModelMatrix()
	popFilterMag()
	popFilterMin()

end);

local xRel,yRel,ang;
hook.Add("Think","JB.Think.ContextMenuLogic",function()
	if (color.a < 250) then return end

	steps = 2 * math.pi / #bubbles;

	xRel,yRel=(-ScrW()/2 + gui.MouseX()) + (size/2),(-ScrH()/2 + gui.MouseY()) + (size/2);

	for k,v in pairs(bubbles)do
		x,y=  (size + 64)/2 + math.sin(v.ang) * size/2,(size + 64)/2 + math.cos(v.ang) * size/2;

		if xRel > x-64 and xRel < x and yRel > y-64 and yRel < y then
			v.selected = true;
		else
			v.selected = false;
		end
	end

end);

local function addBubble(text,icon,action)
	local tab = {}
	tab.icon = icon;
	tab.text = text;
	tab.action = action;
	table.insert(bubbles,tab);
end

concommand.Add( "+menu_context",function()
	if LocalPlayer().GetWarden and LocalPlayer():GetWarden() then
		JB:DebugPrint("Opening context menu")

		scale = 0;
		color.a = 0;

		bubbles = {};

		addBubble("Move",Material("jailbreak_excl/pointers/generic.png"),function() RunConsoleCommand("jb_warden_placepointer","generic") end)
		addBubble("Attack",Material("jailbreak_excl/pointers/exclamation.png"),function() RunConsoleCommand("jb_warden_placepointer","exclamation") end)
		addBubble("Check out",Material("jailbreak_excl/pointers/question.png"),function() RunConsoleCommand("jb_warden_placepointer","question") end)
		addBubble("Line up",Material("jailbreak_excl/pointers/line.png"),function() RunConsoleCommand("jb_warden_placepointer","line") end)
		addBubble("Avoid",Material("jailbreak_excl/pointers/cross.png"),function() RunConsoleCommand("jb_warden_placepointer","cross") end)
		addBubble("None",nil,function() RunConsoleCommand("jb_warden_placepointer","0") end)

		gui.EnableScreenClicker(true);
		contextEnabled = true;

	end
end);

local function closeContext()
	if not contextEnabled then return end

	gui.EnableScreenClicker(false);
	contextEnabled = false;

	for k,v in pairs(bubbles)do
		if v.selected then
			v.action();
			JB:DebugPrint("Selected option '"..v.text.."' in context menu.");
		end
	end
end

concommand.Add( "-menu_context",closeContext);

hook.Add("GUIMouseReleased","JB.GUIMouseReleased.ContextMenuMouse",function(mouse)
	if mouse == MOUSE_LEFT and contextEnabled then
		closeContext();
	end
end);
