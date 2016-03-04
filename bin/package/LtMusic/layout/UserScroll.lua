--lua文件必须是UTF-8编码的(最好无BOM头)
function SetState(self,newState) 		
		local attr = self:GetAttribute()
		
		if newState ~= attr.NowState then
			local ownerTree = self:GetOwner()
			local oldBkg = self:GetControlObject("oldBkg")
			local bkg = self:GetControlObject("bkg")
			if attr.UseType == "progress" then
				return
			end
		end
end

function SetText(self,newText)
	local textObj = self:GetControlObject("text")
	textObj:SetText(newText)
end

function OnLButtonDown(self)
	local attr = self:GetAttribute()
	if attr.Enable then
		self:SetState(1)
		
		self:SetCaptureMouse(true)
		attr.NowState = 5; --clickdown;
	end
end

function OnLButtonUp(self, x, y)
	local attr = self:GetAttribute()
	if attr.Enable then
		if attr.NowState==1 then
			self:FireExtEvent("OnClick")
			self:SetState(0)
		end
		if attr.UseType == "progress" then
			local oldbkg = self:GetControlObject("oldBkg");
			local pos = self:GetControlObject("PosCoin");
			oldbkg:SetObjPos(0,0,x,"father.height")
			pos:SetObjPos(x-10,-24,x+14,0)
			--oldbkg:width = 0;
		end
		self:SetCaptureMouse(false)
		attr.NowState = 0;
	end
end

function OnMouseMove(self, x, y)
	local attr = self:GetAttribute()
	if attr.Enable then
		if attr.NowState==0 then
			self:SetState(3)
		end
	end
	if attr.NowState == 5 and attr.UseType == "progress" then
			local oldbkg = self:GetControlObject("oldBkg");
			local bkg = self:GetControlObject("bkg");
			local pos = self:GetControlObject("PosCoin");
			local x1,x2;
			x1,_,x2,_ = bkg:GetObjPos();

			if x > x1 and x < x2 then
				oldbkg:SetObjPos(0,0,x,"father.height")
				pos:SetObjPos(x-10,-24,x+14,0)
			end
	end
end

function OnMouseLeave(self)
	local attr = self:GetAttribute()
	self:SetState(0)
end

function OnBind(self)
	local attr = self:GetAttribute()
	--self:SetText(attr.Text)
	attr.NowState=0
	local bkg = self:GetControlObject("bkg")
	if attr.UseType == "progress" then
		local oldbkg = self:GetControlObject("oldBkg");
		oldbkg:SetTextureID (attr.UseBkg)
		--oldbkg:width = 0;
		oldbkg:SetAlpha(255);
		oldbkg:SetZorder(100);
		bkg:SetTextureID (attr.UnuseBkg)
		
		--oldbkg:SetObjPos(0,0,0,"father.height")
		oldbkg:SetObjPos(0,0,0,"father.height")
		return ;
	end
	bkg:SetTextureID(attr.NormalBkgID)
end

function OnPersent(self, persent)
	local oldbkg = self:GetControlObject("oldBkg");
	local bkg = self:GetControlObject("bkg");
	local pos = self:GetControlObject("PosCoin");
	local x1,x2;
	x1,_,x2,_ = bkg:GetObjPos();
	local posx = (x2 - x1)*persent/1000
	
	oldbkg:SetObjPos(0,0,posx,"father.height")
	pos:SetObjPos(posx-10,-24,posx+14,0)
end