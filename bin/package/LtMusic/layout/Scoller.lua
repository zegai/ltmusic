--lua文件必须是UTF-8编码的(最好无BOM头)
function SetState(self,newState) 		
		local attr = self:GetAttribute()
		
		if newState ~= attr.NowState then
			local ownerTree = self:GetOwner()
			local oldBkg = self:GetControlObject("oldBkg")
			local bkg = self:GetControlObject("bkg")
			
			oldBkg:SetTextureID(bkg:GetTextureID())
			oldBkg:SetAlpha(255)
			if newState == 0 then
				bkg:SetTextureID(attr.UnuseBkg)
			elseif newState == 1 then
				bkg:SetTextureID(attr.UseBkg)
			elseif newState == 2 then
				bkg:SetTextureID(attr.UnuseBkg)
			elseif newState == 3 then
				bkg:SetTextureID(attr.UseBkg)
			end

			
			local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
			local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
			aniAlpha:BindRenderObj(oldBkg)
			aniAlpha:SetTotalTime(500)
			aniAlpha:SetKeyFrameAlpha(255,0)
			ownerTree:AddAnimation(aniAlpha)
			aniAlpha:Resume()
			attr.NowState = newState
		end
end

function SetText(self,newText)
	local textObj = self:GetControlObject("text")
	textObj:SetText(newText)
end

function OnLButtonDown(self, x, y)
	local attr = self:GetAttribute()
	
	if attr.Enable then
		self:SetState(1)
		self:SetCaptureMouse(true)
	end
end

function OnLButtonUp(self)
	local attr = self:GetAttribute()
	if attr.Enable then
		if attr.NowState==1 then
			self:FireExtEvent("OnClick")
			self:SetState(0)
		end
		
		self:SetCaptureMouse(false)
	end
end

function OnMouseMove(self, x, y, wheel)
	local attr = self:GetAttribute()
	if attr.Enable then
		if attr.NowState == 1 or wheel == true then
			--XLMessageBox('Mouse Move: ' .. attr.NowState )
			local tmpf = self:GetControlObject("fillarea")
			local _,ytoh,_,ytoe = self:GetObjPos()
			local _,y1,_,y2 = tmpf:GetObjPos()
			local height = y2-y1;
			
			if y < height/2 then
				y = height/2
			elseif y > ytoe - height/2 then
				y = ytoe - height/2
			end
			
			tmpf:SetObjPos(0, y - height/2, "father.width", y + height/2)
			self:FireExtEvent("OnScollChange")
		end
		if attr.NowState==0 then
			self:SetState(3)
		end
	end
end

function OnMouseLeave(self)
	--local attr = self:GetAttribute()
	self:SetState(0)
end



function OnBind(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	attr.ClickY = 0;
	local oldbkg = self:GetControlObject("oldBkg");
	attr.NowState = 0;
	oldbkg:SetTextureID (attr.UseBkg)

	oldbkg:SetAlpha(255);
	oldbkg:SetZorder(100);
	bkg:SetTextureID (attr.UnuseBkg)

	oldbkg:SetObjPos(0,0,0,"father.height")
end

function SetScrollLen(self, sclen)
	local sc = self:GetControlObject("fillarea")
	local _,sy = sc:GetObjPos()
	sc:SetObjPos(0,sy,"father.width",sy+sclen)
end

function OnMouseWheel(self, x, y, distance, flag)
--
	local attr = self:GetAttribute()
	if attr.Enable then
		local tmpf = self:GetControlObject("fillarea")
		local _,y1,_,y2 = tmpf:GetObjPos()
		local height = (y2+y1)/2 - distance/6;
		OnMouseMove(self, 0, height, true)
	end
	
end