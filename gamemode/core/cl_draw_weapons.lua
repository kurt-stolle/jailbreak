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

local clientModels = {}
clientModels["weapon_jb_knife"] = ClientsideModel("models/weapons/w_knife_t.mdl");
if IsValid(clientModels["weapon_jb_knife"]) then
	clientModels["weapon_jb_knife"]:SetNoDraw(true);
end

local primWeps = {"weapon_jb_weapon_jb_ak47","weapon_jb_awp","weapon_jb_m3","weapon_jb_m4a1","weapon_jb_mp5navy","weapon_jb_scout","weapon_jb_scout_ns","weapon_jb_tmp","weapon_jb_awp","weapon_jb_famas","weapon_jb_galil","weapon_jb_mac10","weapon_jb_p90","weapon_jb_sg552","weapon_jb_ump"};
local secoWeps = {"weapon_jb_deagle","weapon_jb_fiveseven","weapon_jb_glock","weapon_jb_usp"};

local wmeta = FindMetaTable("Weapon");
function wmeta:IsPrimary()
	return (table.HasValue(primWeps,self:GetClass()) or table.HasValue(primWeps,weapons.Get(self:GetClass()).Base));
end
function wmeta:IsSecondary()
	return (table.HasValue(secoWeps,self:GetClass()) or table.HasValue(secoWeps,weapons.Get(self:GetClass()).Base));
end

function GM:CheckWeaponTable(class,model)
	if clientModels[class] then return end

	timer.Simple(0,function()
		clientModels[class] = ClientsideModel(model,RENDERGROUP_OPAQUE);
		if IsValid(clientModels[class]) then
			clientModels[class]:SetNoDraw(true);
		end
	end);
end

hook.Add("PostPlayerDraw","JB.PostPlayerDraw.DrawWeapons",function(p)
	local weps = p:GetWeapons();

	for k, v in pairs(weps)do
		local mdl = clientModels[v:GetClass()];
		if IsValid(mdl) and p:GetActiveWeapon() and p:GetActiveWeapon():IsValid() and p:GetActiveWeapon():GetClass() ~= v:GetClass() then
			if v:IsSecondary() then
				local boneindex = p:LookupBone("ValveBiped.Bip01_R_Thigh")
				if boneindex then
					local pos, ang = p:GetBonePosition(boneindex)

					ang:RotateAroundAxis(ang:Forward(),90)
					mdl:SetRenderOrigin(pos+(ang:Right()*4)+(ang:Up()*-4));
					mdl:SetRenderAngles(ang);
					mdl:DrawModel();
				end
			elseif v:IsPrimary() then
				local boneindex = p:LookupBone("ValveBiped.Bip01_Spine2")
				if boneindex then
					local pos, ang = p:GetBonePosition(boneindex)

					ang:RotateAroundAxis(ang:Forward(),0)
					mdl:SetRenderOrigin(pos+(ang:Right()*4)+(ang:Up()*-7)+(ang:Forward()*6));
					ang:RotateAroundAxis(ang:Right(),-15)
					mdl:SetRenderAngles(ang);
					mdl:DrawModel();
				end
			elseif v:GetClass() == "weapon_jb_knife" and not tobool(JB.Config.knivesAreConcealed) then
				local boneindex = p:LookupBone("ValveBiped.Bip01_L_Thigh")
				if boneindex then
					local pos, ang = p:GetBonePosition(boneindex)

					ang:RotateAroundAxis(ang:Forward(),90)
					ang:RotateAroundAxis(ang:Right(),-90)
					mdl:SetRenderOrigin(pos+(ang:Right()*-4.2)+(ang:Up()*2));
					mdl:SetRenderAngles(ang);
					mdl:DrawModel();
				end
			elseif string.Left(v:GetClass(),10) == "weapon_jb_grenade" then
				local boneindex = p:LookupBone("ValveBiped.Bip01_L_Thigh")
				if boneindex then
					local pos, ang = p:GetBonePosition(boneindex)

					ang:RotateAroundAxis(ang:Forward(),10)
					ang:RotateAroundAxis(ang:Right(),90)
					mdl:SetRenderOrigin(pos+(ang:Right()*-6.5)+(ang:Up()*-1));
					mdl:SetRenderAngles(ang);
					mdl:DrawModel();
				end
			end
		elseif not mdl and IsValid(v) and weapons.Get( v:GetClass( ) ) then
			GAMEMODE:CheckWeaponTable( v:GetClass() ,
			weapons.Get( v:GetClass( ) ).WorldModel );
		end
	end
end)
