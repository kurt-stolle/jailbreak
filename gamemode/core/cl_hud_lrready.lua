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



local timeReceive;
local lrType = "BUG"
net.Receive('JB.LR.GetReady',function()
	timeReceive=CurTime();
	lrType = net.ReadString();
end);

local _Material = Material( "pp/toytown-top" )
_Material:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )

/* HUD elements */
local drawText = draw.DrawText
local setColor = surface.SetTextColor
local setTextPos = surface.SetTextPos
local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag;
local pushFilterMin = render.PushFilterMin;
local popFilterMag = render.PopFilterMag;
local popFilterMin = render.PopFilterMin;
local getTextSize = surface.GetTextSize;
local setFont = surface.SetFont;

local sin=JB.Util.memoize(math.sin);
local cos=JB.Util.memoize(math.cos);
local deg2rad=math.rad;
local floor=math.floor;

local matrix = Matrix()
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)
local textWidth, textHeight, rad,textWidthSub,textHeightSub,width,height;
local halvedPi = math.pi/2;
local color=Color(255,255,255,255);
local color_dark=Color(0,0,0,255);
local clamp = math.Clamp;
local scale=1;
local ang = 0;
local text = function( text,sub )

	x,y = ScrW()/2,ScrH()/2;
	pushFilterMag( TEXFILTER.ANISOTROPIC )
	pushFilterMin( TEXFILTER.ANISOTROPIC )

	setFont("JBExtraExtraLarge");
	textWidth, textHeight = getTextSize( text )
	if sub then
		setFont("JBNormal");
		sub = JB.Util.formatLine(sub,ScrW()*.3)
		textWidthSub, textHeightSub = getTextSize( sub );
		textHeight=textHeight+textHeightSub;

		if textWidthSub > textWidth then
			width = textWidthSub;
		else
			width=textWidth;
		end
		
		height=(textHeight+textHeightSub);
	else
		width=textWidth;
		height=textHeight;
	end
	
	rad = -deg2rad( ang )
	x = x - ( sin( rad + halvedPi ) * width*scale / 2 + sin( rad ) * height*scale / 2 )
	y = y - ( cos( rad + halvedPi ) * width*scale / 2 + cos( rad ) * height*scale / 2 )
	
	matrix=Matrix();
	matrixAngle.y = ang;
	matrix:SetAngles( matrixAngle )
	matrixTranslation.x = x;
	matrixTranslation.y = y;
	matrix:SetTranslation( matrixTranslation )
	matrixScale.x = scale;
	matrixScale.y = scale;
	matrix:Scale( matrixScale )
	pushModelMatrix( matrix )
		drawText( text,"JBExtraExtraLargeShadow", sub and (width/2 - textWidth/2) or 0,0,color_dark,0);
		drawText( text,"JBExtraExtraLarge", sub and (width/2 - textWidth/2) or 0,0,color,0);
		if sub then
			drawText(sub,"JBNormalShadow",width/2,textHeight,color_dark,1);
			drawText(sub,"JBNormal",width/2,textHeight,color,1);
		end

	popModelMatrix()
	popFilterMag()
	popFilterMin()
end

local time,xCenter,yCenter;
hook.Add("HUDPaintOver","JB.HUDPaintOver.PaintReadyForLR",function()
	if not timeReceive or (CurTime() - timeReceive) > 8 or not JB.LastRequestTypes[lrType] then return end


	time=(CurTime() - timeReceive);

	if time > 4 then
		scale=.2 + (1-(time%1)) * 3
		ang=-10 + (1-(time%1)) * 30;
	else
		scale=1;
		ang=0;
	end

	time=floor(time);

	text(time < 4 and JB.LastRequestTypes[lrType].name or time == 7 and "Go!" or tostring(3 - (time-4)), time < 4 and JB.LastRequestTypes[lrType].description);
end);