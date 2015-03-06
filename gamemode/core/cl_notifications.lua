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
local activeNotice = nil;

local function queueNotification(text,type)
	table.insert(Notices,{text=text,type=type});
	JB:DebugPrint("Notification: "..text);
end

local function createNotice(key)
	local pnl = vgui.Create("JBNoticePanel");
	pnl.key = key;
	pnl.text = Notices[key].text;
	
	local t = Notices[key].type;
	pnl.icon = NoticeMaterial[ t ];
	pnl.type = t == NOTIFY_GENERIC and "NOTICE" or t == NOTIFY_ERROR and "ERROR" or t == NOTIFY_UNDO and "OBJECTIVE" or t == NOTIFY_HINT and "HINT" or "NOTICE";
	
	activeNotice = pnl;
end

hook.Add("Think","JB.Think.UpdateNotifications", function()
	if IsValid(activeNotice) then
		activeNotice:Update();

		if activeNotice:IsDone() then
			table.remove(Notices,activeNotice.key);
			activeNotice:Remove();
			
			local key = table.GetFirstKey(Notices);
			if key then
				createNotice(key);
			end
		end
	elseif table.GetFirstKey(Notices) then
		createNotice(table.GetFirstKey(Notices));
	end
end)

local state_expand,state_show,state_die = 1,2,3;
local bracket = Material("materials/jailbreak_excl/notify_bracket.png");
local bracket_wide = 16;
local bracket_tall = 64;
vgui.Register("JBNoticePanel",{
	Init = function(self)
		self.timeStateStart = SysTime();
		self.text = "Undefined";
		self.icon = NoticeMaterial[ NOTIFY_GENERIC ];
		self.type = NOTIFY_GENERIC;
		self.state = state_expand;
		self.colorText = Color(255,255,255,0);
		self.colorBrackets = Color(255,255,255,0);
		self.distanceBrackets = 0;
		
		self:SetSize(1,bracket_tall);
	end,
	Update = function(self)
		surface.SetFont("JBLarge");
		local wide = surface.GetTextSize(self.text);
		local mul=FrameTime() * 60;
		if self.state == state_expand then
			local distance_max = (wide+16);
			
			self.distanceBrackets = math.Clamp(math.ceil(Lerp(0.05 * mul,self.distanceBrackets,distance_max + 1)), self.distanceBrackets, distance_max);
			self.colorBrackets.a = math.Clamp(math.ceil(Lerp(0.1 * mul,self.colorBrackets.a,256)), self.colorBrackets.a, 255);
			self.colorText.a = math.Clamp(math.ceil(Lerp(0.05 * mul,self.colorText.a,256)), self.colorText.a, 255);
			
			if self.distanceBrackets >= distance_max and self.colorText.a >= 255 and self.colorBrackets.a >= 255 then
				self.state = state_show;
				self.timeStateStart = SysTime();
			end
		elseif self.state == state_show then
			if SysTime() > self.timeStateStart + .8 then
				self.state = state_die;
				self.timeStateStart = SysTime();
			end
		elseif self.state == state_die then
			if self.colorText.a < 100 then
				self.distanceBrackets = math.Clamp(math.floor(Lerp(0.15 * mul,self.distanceBrackets,-1)), 0, self.distanceBrackets);
				self.colorBrackets.a = math.Clamp(math.floor(Lerp(0.15 * mul,self.colorBrackets.a,-1)), 0, self.colorBrackets.a);
			end
			self.colorText.a = math.Clamp(math.floor(Lerp(0.2 * mul,self.colorText.a,-1)), 0, self.colorText.a);
		end
		
		self:SetWide(self.distanceBrackets + (bracket_wide * 2));
		self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/10 * 3);
	end,
	Paint = function(self,w,h)	
		surface.SetDrawColor(self.colorBrackets);
		surface.SetMaterial(bracket);
		surface.DrawTexturedRectRotated(w/2 - bracket_wide/2 - self.distanceBrackets/2, h/2, bracket_wide, bracket_tall, 0) -- left bracket
		surface.DrawTexturedRectRotated(w/2 + bracket_wide/2 + self.distanceBrackets/2, h/2, bracket_wide, bracket_tall, 180) -- right bracket
		
		draw.SimpleText(self.type,"JBSmall",math.Round(w/2),8,self.colorText,1,0);
		draw.SimpleText(self.text,"JBLarge",math.Round(w/2),h/2 + 6, self.colorText,1,1);
	end,
	IsDone = function(self)
		return (self.state == state_die and self.distanceBrackets <= 0 );
	end,
},"Panel");

net.Receive("JB.SendNotification",function()
	queueNotification(net.ReadString(),NOTIFY_GENERIC);
end);

 -- this is what I can "legacy support" :V
function notification.AddProgress() end
function notification.Kill() end
function notification.Die() end
notification.AddLegacy = queueNotification;


