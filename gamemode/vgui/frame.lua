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


/* backup of old vgui
local matGradient = Material("materials/jailbreak_excl/gradient.png"); 
local matClose = Material("materials/jailbreak_excl/vgui_close.png");
local matCloseHover = Material("materials/jailbreak_excl/vgui_close_hover.png");

local color_white_shadow = Color(255,255,255,60);

vgui.Register("JB.Frame.CloseButton",{
OnCursorEntered = function(self)
	self.Hover = true;
end,
OnCursorExited = function(self)
	self.Hover = false;
end,
Paint = function(self,w,h)
	surface.SetMaterial(self.Hover and matCloseHover or matClose)
	surface.SetDrawColor(JB.Color.white);
	surface.DrawTexturedRectRotated(w/2,h/2,32,32,0);
end
},"Panel");

local PNL = {};
AccessorFunc(PNL,"title","Title",FORCE_STRING);
function PNL:Init()
	self:SetTitle("Example title");
	
	self.CloseButton = vgui.Create("JB.Frame.CloseButton",self)
	self.CloseButton:SetSize(32,32);
	self.CloseButton.OnMouseReleased = function()
		self:Remove();
	end
end
function PNL:PerformLayout()
	self.CloseButton:SetPos(self:GetWide()-32,0);
end
function PNL:Paint(w,h)
	draw.RoundedBox(8,0,0,w,h,JB.Color.black);
	
	draw.RoundedBoxEx(6,2,2,w-4,28,JB.Color["#BBB"],true,true);
	
	draw.SimpleText(string.upper(self:GetTitle()),"JBNormal",13,30/2+1,color_white_shadow,0,1);
	draw.SimpleText(string.upper(self:GetTitle()),"JBNormal",12,30/2,JB.Color["#222"],0,1);
	
	surface.SetDrawColor(color_white_shadow);
	surface.DrawRect(2,29,w-4,1);
	
	surface.SetDrawColor(Color(0,0,0,120));
	surface.SetMaterial(matGradient);
	surface.DrawTexturedRectRotated(w/2,30 - 20/2,w-4,20,180);
			
	draw.RoundedBoxEx(6,2,32,w-4,h-32-2,JB.Color["#444"],false,false,true,true);
	
	surface.SetDrawColor(Color(0,0,0,120));
	surface.SetMaterial(matGradient);
	local h_grad = math.Clamp(h-30-2-8,0,256);
	surface.DrawTexturedRectRotated(w/2,30 + 3 + (h_grad)/2,w-6,h_grad,0);
end
vgui.Register("JB.Frame",PNL,"EditablePanel");
*/
surface.CreateFont("JBWindowTitle",{
	font = "Arial",
	size = 18,
	weight = 800
})
surface.CreateFont("JBWindowTitleShadow",{
	font = "Arial",
	size = 18,
	weight = 800,
	blursize =2
})

local matGradient = Material("materials/jailbreak_excl/gradient.png"); 
local matClose = Material("materials/jailbreak_excl/vgui_close.png");
local matCloseHover = Material("materials/jailbreak_excl/vgui_close_hover.png");

local color_white_shadow = Color(255,255,255,1);
local color_gradient_top = Color(0,0,0,20);
local color_gradient_bottom = Color(0,0,0,120);

vgui.Register("JB.Frame.CloseButton",{
Init = function(self)
		self.clr = Color(200,0,0,80);
end,
OnCursorEntered = function(self)
	self.Hover = true;
end,
OnCursorExited = function(self)
	self.Hover = false;
end,
Paint = function(self,w,h)
	//surface.SetMaterial(self.Hover and matCloseHover or matClose)
	//surface.SetDrawColor(JB.Color.white);
	//surface.DrawTexturedRectRotated(w/2,h/2,32,32,0);

	if self.Hover then
		self.clr.a = Lerp(FrameTime()*6,self.clr.a,255);
	else
		self.clr.a = Lerp(FrameTime()*6,self.clr.a,60);
	end

	draw.RoundedBox(6,0,0,w,h,Color(0,0,0,150));
	draw.RoundedBox(4,1,1,w-2,h-2,JB.Color.black);
	draw.RoundedBox(4,2,2,w-4,h-4,self.clr)
	surface.SetDrawColor(color_gradient_bottom);
	surface.SetMaterial(matGradient);
	surface.DrawTexturedRect(2,2,w-4,h-4);

end
},"Panel");

local PNL = {};
AccessorFunc(PNL,"title","Title",FORCE_STRING);
function PNL:Init()
	self:SetTitle("Example title");
	
	self.CloseButton = vgui.Create("JB.Frame.CloseButton",self)
	self.CloseButton:SetSize(32,12);
	self.CloseButton.OnMouseReleased = function()
		self:Remove();
	end
end
function PNL:PerformLayout()
	self.CloseButton:SetPos(self:GetWide()-33,12);
end

function PNL:Paint(w,h)
	draw.RoundedBox(8,0,30,w,h-30,Color(0,0,0,150));
	draw.RoundedBox(6,1,31,w-2,h-30-2,JB.Color.black);
	//draw.RoundedBoxEx(4,2,2,w-4,28,JB.Color["#111"],true,true);
	
	//draw.SimpleText(string.upper(self:GetTitle()),"JBWindowTitle",13,30/2 + 2,color_white_shadow,0,1);
	local wTitle,hTitle = JB.Util.drawSimpleShadowText(string.upper(self:GetTitle()),"JBWindowTitle",8,30/2 + 1,JB.Color["#fff"],0,1,6);

	//surface.SetDrawColor(color_white_shadow);
	//surface.DrawRect(2,29,w-4,1);
	
	//surface.SetDrawColor(color_gradient_top);
	//surface.SetMaterial(matGradient);
	//surface.DrawTexturedRectRotated(w/2,30 - 20/2,w-4,20,180);
			
	draw.RoundedBox(6,2,32,w-4,h-32-2,JB.Color["#4a4a4a"],false,false,true,true);
	
	surface.SetDrawColor(color_gradient_bottom);
	surface.SetMaterial(matGradient);
	local h_grad = math.Clamp(h-30-2-8,0,256);
	surface.DrawTexturedRectRotated(w/2,30 + 3 + (h_grad)/2,w-6,h_grad,0);
end
vgui.Register("JB.Frame",PNL,"EditablePanel");