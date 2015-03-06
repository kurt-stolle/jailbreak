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


function JB:CanLastRequest()
	return JB:AliveGuards() >= 1 and JB:AlivePrisoners() == 1 and (JB.State == STATE_PLAYING or (JB.State == STATE_LASTREQUEST and not JB.ValidLR(JB.LastRequestTypes[JB.LastRequest])) or JB.State == STATE_SETUP);
end


concommand.Add("jb_lastrequest_start",function(p,c,a)
	if not JB:CanLastRequest() or not p:Team() == TEAM_PRISONER or not p:Alive() or not a or not a[1] or not a[2] then return end
	
	local lr = a[1];
	if not JB.ValidLR(JB.LastRequestTypes[lr]) then return end

	local guard = Entity(tonumber(a[2]));
	if not IsValid(guard) or not guard.IsPlayer or not guard:IsPlayer() or not guard:Team() == TEAM_GUARD or not guard:Alive() then return end
	
	JB:DebugPrint("Setting up LR for ",p:Nick())
	JB.LastRequest = {type=lr,guard=guard,prisoner=p};
end);