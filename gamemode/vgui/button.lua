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


local matEdge = Material("materials/jailbreak_excl/button_edge.png");
local matMid = Material("materials/jailbreak_excl/button_middle.png")

surface.CreateFont("JBButton",{
	font=JB.Config.font,
	size=14,
	weight = 700,
});
surface.CreateFont("JBButtonShadow",{
	font=JB.Config.font,
	size=14,
	weight = 700,
	blursize=2,
});

local PNL = {};
AccessorFunc(PNL,"text","Text",FORCE_STRING);
function PNL:Init()
	self:SetText("Example text");
	self.color = Color(200,200,200);
end
function PNL:OnCursorEntered()
	self.Hover = true;
end
function PNL:OnCursorExited()
	self.Hover=false;
end	
function PNL:Paint(w,h)
	if self.Hover then
		self.color.r = math.Approach( self.color.r, 255, FrameTime() * 600 )
		self.color.g = math.Approach( self.color.g, 255, FrameTime() * 600 )
		self.color.b = math.Approach( self.color.b, 255, FrameTime() * 600 )
	else
		self.color.r = math.Approach( self.color.r, 180, FrameTime() * 400 )
		self.color.g = math.Approach( self.color.g, 180, FrameTime() * 400 )
		self.color.b = math.Approach( self.color.b, 180, FrameTime() * 400 )
	end

	surface.SetDrawColor(Color(self.color.r * .8,self.color.g * .8, self.color.b * .8))
	surface.SetMaterial(matEdge);
	
	surface.DrawTexturedRectRotated(32/2,h/2,32,32,0);
	surface.DrawTexturedRectRotated(w-32/2,h/2,32,32,180);
	
	surface.SetMaterial(matMid);
	
	surface.DrawTexturedRectRotated(w/2,h/2,w-64,32,0);
	
	draw.SimpleText(self:GetText(),"JBButtonShadow",w/2,h/2,JB.Color.black,1,1);
	draw.SimpleText(self:GetText(),"JBButtonShadow",w/2,h/2,JB.Color.black,1,1);
	draw.SimpleText(self:GetText(),"JBButton",w/2,h/2,self.color,1,1);
end
vgui.Register("JB.Button",PNL,"Panel");