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



local PNL = {};
local color_shade = Color(255,255,255,5);
local color_bg = Color(20,20,20);
local color_bg_weak  = Color(20,20,20,240);
local matGradient = Material("materials/jailbreak_excl/gradient.png"); 

function PNL:Paint(w,h)
	surface.SetMaterial(matGradient);
	surface.SetDrawColor(color_bg);
	surface.DrawTexturedRect(0,0,w,h);
	surface.SetDrawColor(color_bg_weak);
	surface.DrawRect(0,0,w,h);
	draw.RoundedBox(0,0,0,w,1,color_shade);
end
vgui.Register("JB.Panel",PNL,"EditablePanel");
	