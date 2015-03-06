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


local NoticeMaterial = {}
NoticeMaterial[ NOTIFY_GENERIC ] 	= Material( "vgui/notices/generic" )
NoticeMaterial[ NOTIFY_ERROR ] 		= Material( "vgui/notices/error" )
NoticeMaterial[ NOTIFY_UNDO ] 		= Material( "vgui/notices/undo" )
NoticeMaterial[ NOTIFY_HINT ] 		= Material( "vgui/notices/hint" )
NoticeMaterial[ NOTIFY_CLEANUP ] 	= Material( "vgui/notices/cleanup" )

local Notices = {}

local function createNotice(text,type)
	local pnl = vgui.Create("JBQuickNoticePanel");
	pnl.text = text;
	pnl.type = type;
	
	pnl.index = table.insert(Notices,pnl);
end

local matMiddle = Material("jailbreak_excl/notify_quick_middle.png");
local matEdge = Material("jailbreak_excl/notify_quick_edge.png");


local speed = 300;
local mul;
local fontNotify = "JBSmall";
local state_expand,state_show,state_die = 1,2,3;
vgui.Register("JBQuickNoticePanel",{
	Init = function(self)
		self.timeStateStart = SysTime();
		self.text = "Undefined";
		self.type = NOTIFY_GENERIC;
		self.state = state_expand;
		self.x = ScrW();
		self.y = ScrH() * .4
		self.xTrack = self.x;
		self.yTrack = self.y;
	end,
	PerformLayout = function(self)
		surface.SetFont(fontNotify);
		local w = surface.GetTextSize(self.text or "Undefined");
		
		w= math.Clamp(w+26,17,ScrW()/2); -- margin of 8 at each side
		self:SetSize(w,32);
	end,
	Think = function(self)
		for k,v in pairs(Notices)do
			if v == self then
				self.index = k;
			end
		end
	
		-- commit suicide if we're done.
		if self:IsDone() then
			for k,v in pairs(Notices)do
				if v==self then
					table.remove(Notices,k);
					break;
				end
			end
			self:Remove();
			return;
		end

		mul=FrameTime()*10
		
		self.yTrack = Lerp(mul,self.yTrack,(ScrH() * .4) + ((self.index-1) * 32));

		
		if self.state == state_expand then
			-- increase X position by FrameTime() * speed
			
			self.xTrack = Lerp(mul,self.xTrack,ScrW()-self:GetWide(),FrameTime() * speed);
			
			if self.xTrack <= ScrW() - self:GetWide()+1 then
				self.state = state_show;
				self.timeStateStart = SysTime();
				self.xTrack=(ScrW()-self:GetWide());
			end
		elseif self.state == state_show then
			-- keep the notification where it is, only seet Y position in case an old notification dies.
						
			if SysTime() > self.timeStateStart + 2.6 then
				self.state = state_die;
				self.timeStateStart = SysTime();
			end
		elseif self.state == state_die then
			self.xTrack = Lerp(mul,self.xTrack,ScrW()+1);
		end
		
		self.x = math.Round(self.xTrack);
		self.y = math.Round(self.yTrack);
	end,
	Paint = function(self,w,h)
		if not self.text or not self.type or self.text == "" then return end
	
		surface.SetDrawColor(JB.Color.white);
		
		surface.SetMaterial(matEdge);
		surface.DrawTexturedRect(0,0,16,32);
		surface.SetMaterial(matMiddle);
		surface.DrawTexturedRect(16,0,w-16,32);
	
		draw.SimpleText(self.text,fontNotify.."Shadow",18,h/2,JB.Color.black,0,1);
		draw.SimpleText(self.text,fontNotify,18,h/2,JB.Color["#EEE"],0,1);
	end,
	IsDone = function(self)
		return (self.state == state_die and self.x >= ScrW() );
	end,
},"Panel");

concommand.Add("testnotify",function()
	createNotice("nigga wat",NOTIFY_GENERIC)
end);

net.Receive("JB.SendQuickNotification",function()
	createNotice(net.ReadString(),NOTIFY_GENERIC);
end);