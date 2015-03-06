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

/* 

	drawSimpleShadowText
	draws a text with a shadow font under it.

*/

// we will probably call this many times each frame, so let's localize a bit
local getTextSize = surface.GetTextSize;
local setTextPos = surface.SetTextPos;
local setTextColor = surface.SetTextColor;
local setFont = surface.SetFont;
local drawText = surface.DrawText;
local ceil = math.ceil;
local w,h;

// actual function
function JB.Util.drawSimpleShadowText(text,font,x,y,color,xalign,yalign,passes)
	if not font or not x or not y or not color or not xalign or not yalign then return end

	passes=passes or 2;
	text 	= tostring( text )
	setFont(font.."Shadow");

	w,h = getTextSize( text )

	if (xalign == TEXT_ALIGN_CENTER) then
		x = x - w/2
	elseif (xalign == TEXT_ALIGN_RIGHT) then
		x = x - w
	end

	if (yalign == TEXT_ALIGN_CENTER) then
		y = y - h/2
	elseif ( yalign == TEXT_ALIGN_BOTTOM ) then
		y = y - h
	end

	setTextColor( 0,0,0,color.a )
	for i=1,passes do
		setTextPos( ceil( x ), ceil( y ) );
		drawText(text)
	end
	setFont(font);
	setTextPos( ceil( x ), ceil( y ) );
	setTextColor( color.r, color.g, color.b, color.a )
	drawText(text)

	return w, h
end
