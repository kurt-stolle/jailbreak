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



function JB.Util.iterate(tab)
	local wrap = {};
	setmetatable(wrap,{__index = function(self,req)
		return (function(...)
			for _,v in pairs(tab)do
				if not (v[req] and type(v[req]) == "function" ) then continue end

				args={...};
				for i,arg in ipairs(args)do
					if arg == wrap then 
						rawset(args,i,v);
					end
				end
				v[req](unpack(args));

			end
			return wrap;
		end)
	end})
	return wrap;
end

function JB.Util.isValid(...)
	for k,v in ipairs{...}do
		if not IsValid(v) then return false end
	end
	return true;
end

function JB.Util.formatLine(str,size)
	//surface.SetFont( font );
	
	local start = 1;
	local c = 1;	
	local endstr = "";
	local n = 0;
	local lastspace = 0;
	while( string.len( str ) > c )do
		local sub = string.sub( str, start, c );
		if( string.sub( str, c, c ) == " " ) then
			lastspace = c;
		end

		if( surface.GetTextSize( sub ) >= size ) then
			local sub2;
			
			if( lastspace == 0 ) then
				lastspace = c;
			end
			
			if( lastspace > 1 ) then
				sub2 = string.sub( str, start, lastspace - 1 );
				c = lastspace;
			else
				sub2 = string.sub( str, start, c );
			end
			endstr = endstr .. sub2 .. "\n";
			start = c + 1;
			n = n + 1;	
		end
		c = c + 1;
	end
	
	if( start < string.len( str ) ) then
		endstr = endstr .. string.sub( str, start );
	end
	
	return endstr, n;
end

JB.Commands = {};
function JB.Util.addChatCommand(cmd,func)
	JB.Commands[cmd] = {func=func};
end
hook.Add("PlayerSay","JBUtil.PlayerSay.ChatCommands",function(p,t)
	if (p.JBNextCmd and p.JBNextCmd > CurTime()) or not IsValid(p) or not t then return end
	p.JBNextCmd = CurTime()+1; -- prevent spam
	
	local text = t;
	
	if t and ( string.Left(t,1) == "!" or string.Left(t,1) == "/" or string.Left(t,1) == ":") then
		local t = string.Explode(" ",t or "",false);
		t[1] = string.gsub(t[1] or "",string.Left(t[1],1) or "","");

		if t and t[1] then
			local c = string.lower(t[1]);
			if JB.Commands and JB.Commands[c] then
				table.remove(t,1);
				JB.Commands[c].func(p,c,t);

				JB:DebugPrint(p:Nick().." ran chat command '"..text.."'");

				return false
			end
		end

	end
end)