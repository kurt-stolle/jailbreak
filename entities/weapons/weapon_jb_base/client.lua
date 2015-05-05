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

local MODE_NORMAL = 1;
local MODE_AIM = 2;
local MODE_SPRINT = 3;

SWEP.DrawAmmo			= true;
SWEP.DrawCrosshair		= false;
SWEP.ViewModelFOV		= 52;
SWEP.ViewModelFlip		= false;
SWEP.CSMuzzleFlashes	= true;
SWEP.DrawWeaponInfoBox  = true;

SWEP.Slot				= 1;
SWEP.SlotPos			= 1;

SWEP.lastFire = 0;

local matCrosshair = Material("materials/jailbreak_excl/crosshair.png");

local lastFire = 0;
function SWEP:FireCallback()
	if IsFirstTimePredicted() then
		local vm = self.Owner:GetViewModel();
		local muz = vm:GetAttachment("1");

		if not self.Em then
			self.Em = ParticleEmitter(muz.Pos);
		end

		local par = self.Em:Add("particle/smokesprites_000" .. math.random(1, 9), muz.Pos);
		par:SetStartSize(math.random(0.5, 1));
		par:SetStartAlpha(100);
		par:SetEndAlpha(0);
		par:SetEndSize(math.random(4, 4.5));
		par:SetDieTime(1 + math.Rand(-0.3, 0.3));
		par:SetRoll(math.Rand(0.2, .8));
		par:SetRollDelta(0.8 + math.Rand(-0.3, 0.3));
		par:SetColor(140,140,140,200);
		par:SetGravity(Vector(0, 0, .5));
		local mup = (muz.Ang:Up()*-1);
		par:SetVelocity(Vector(0, 0,7)-Vector(mup.x,mup.y,0));

		local par = self.Em:Add("sprites/heatwave", muz.Pos);
		par:SetStartSize(4);
		par:SetEndSize(0);
		par:SetDieTime(0.6);
		par:SetGravity(Vector(0, 0, 1));
		par:SetVelocity(Vector(0, 0, 1));
	end
	lastFire = CurTime();
end

function SWEP:AdjustMouseSensitivity()
	return self:GetNWMode() == MODE_AIM and .5 or 1;
end

local gap = 5
local gap2 = 0
local color_sight = Color(255,255,255,255);
local x2 = (ScrW() - 1024) / 2
local y2 = (ScrH() - 1024) / 2
local x3 = ScrW() - x2
local y3 = ScrH() - y2
local dt;
function SWEP:DrawHUD()
	dt = FrameTime();

	x, y = ScrW() / 2, ScrH() / 2;

	local scale = (10 * self.Primary.Cone)* (2 - math.Clamp( (CurTime() - self:GetNWLastShoot()) * 5, 0.0, 1.0 ))

	if (self:GetNWMode() == MODE_AIM and not self.FakeIronSights) or self:GetNWMode() == MODE_SPRINT then
		color_sight.a = math.Approach(color_sight.a, 0, dt / 0.0017)
	else
		color_sight.a = math.Approach(color_sight.a, 230, dt / 0.001)
	end

	gap = math.Approach(gap, 50 * ((10 / (self.Owner:GetFOV() / 90)) * self:GetNWLastShoot()), 1.5 + gap * 0.1)

	surface.SetDrawColor(color_sight);
	surface.SetMaterial(matCrosshair);
	surface.DrawTexturedRectRotated(x - gap - 14/2,y,32,32,270+180);
	surface.DrawTexturedRectRotated(x + gap + 14/2,y,32,32,90+180);
	surface.DrawTexturedRectRotated(x, y + gap + 14/2,32,32,0+180);
	surface.DrawTexturedRectRotated(x, y - gap - 14/2,32,32,180+180);
end

local time,fireTime,targetPos,targetAng,speed,speedReduced;
local idealPos = Vector(0,0,0);
function SWEP:GetViewModelPosition( pos, ang )
	if not IsValid(self.Owner) then return end

	local mode = self:GetNWMode();
	if mode < 1 or mode > 3 then
		mode = MODE_NORMAL;
	end

	time = math.Clamp(FrameTime() * 7,0,1);

	idealPos.x = self.Positions[mode].pos.x;
	idealPos.y = self.Positions[mode].pos.y;

	if mode == MODE_AIM and self.FakeIronSights then
		idealPos.z = self.Positions[mode].pos.z-1.4;
	else
		idealPos.z = self.Positions[mode].pos.z
	end

	self.smPos = LerpVector(time,self.smPos or self.Positions[mode].pos,idealPos);
	self.smAng = LerpVector(time,self.smAng or self.Positions[mode].ang,self.Positions[mode].ang);

	if !self.lastMode or mode ~= self.lastMode then
		self.lastMode = mode;

		if mode == MODE_AIM then
			self.SwayScale = 0
			self.BobScale = 0
		else
			self.SwayScale = 0.8
			self.BobScale = 0.8
		end
	end

	targetPos = self.smPos + vector_origin;
	targetAng = self.smAng;

	if mode == MODE_AIM then
		local mul = 0;
		fireTime = math.Clamp(FrameTime()*7,.05,.18);
		lastFire = lastFire or 0;
		if lastFire > CurTime() - fireTime then
			mul = math.Clamp( (CurTime() - lastFire) / fireTime, 0, .5 )
			mul = 1-mul;
		end

		targetPos.y = targetPos.y + (-self.Primary.IronShootForce * mul);
	elseif mode == MODE_SPRINT then
		speed = self.Owner:GetVelocity():Length();
		local clamp = math.Clamp((4 + speed / 100) / (self.Owner:Crouching() and 1.5 or 1), 0, 7)

		local co = math.cos(CurTime() * clamp);
		local si = math.sin(CurTime() * clamp);
		local ta = math.atan(co, si)
		local ta2 = math.atan(co * si, co * si)

		speedReduced = speed / 250

		targetPos.x = targetPos.x + ta * 0.1375 * speedReduced;
		targetPos.z = targetPos.z + ta2 * 0.0625 * speedReduced;
		targetAng.y = targetAng.y + ta * 0.125 * speedReduced;
		targetAng.x = targetAng.x + ta2 * 0.25 * speedReduced;
		targetAng.z = targetAng.z + ta2 * 0.375 * speedReduced;
	end

	ang:RotateAroundAxis( ang:Right(), targetAng.x);
	ang:RotateAroundAxis( ang:Up(), targetAng.y);
	ang:RotateAroundAxis( ang:Forward(),  targetAng.z);
	pos = pos + targetPos.x * ang:Right();
	pos = pos + targetPos.y * ang:Forward();
	pos = pos + targetPos.z * ang:Up();

	return pos, ang
end


local lp,wep;
hook.Add("HUDPaint","drawHitMarkers",function()
	lp=LocalPlayer();
	if IsValid(lp) then
		wep = lp:GetActiveWeapon();
		if IsValid(wep) and wep.Markers then
		   for k,v in pairs( wep.Markers)do
		      if v.alpha < 5 then
		         table.remove( wep.Markers,k);
		         continue;
		      end
		      local pos = v.pos:ToScreen();

		      surface.SetDrawColor(Color(255,255,255,v.alpha))
		      surface.DrawLine(pos.x-2,pos.y-2,pos.x-5,pos.y-5);
		      surface.DrawLine(pos.x+2,pos.y+2,pos.x+5,pos.y+5);
		      surface.DrawLine(pos.x-2,pos.y+2,pos.x-5,pos.y+5);
		      surface.DrawLine(pos.x+2,pos.y-2,pos.x+5,pos.y-5);
		      v.alpha = v.alpha-FrameTime()*240;
		   end
		end
	end
end)
