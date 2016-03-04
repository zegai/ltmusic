--lua文件必须是UTF-8编码的(最好无BOM头)
function SetState(self,newState) 		
		local attr = self:GetAttribute()
		
		if attr and newState ~= attr.NowState then
			local ownerTree = self:GetOwner()
			local oldBkg = self:GetControlObject("oldBkg")
			local bkg = self:GetControlObject("bkg")
			
			oldBkg:SetResID(bkg:GetResID())
			oldBkg:SetAlpha(255)
			if newState == 0 then
				bkg:SetResID(attr.NormalBkgID)
			elseif newState == 1 then
				bkg:SetResID(attr.DownBkgID)
			elseif newState == 2 then
				bkg:SetResID(attr.DisableBkgID)
			elseif newState == 3 then
				bkg:SetResID(attr.HoverBkgID)
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

function OnLButtonDown(self)
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

function OnMouseMove(self)
	local attr = self:GetAttribute()
	if attr.Enable then
		if attr.NowState==0 then
			self:SetState(3)
		end
	end
end
function SetEnable(self, enable)
	if type(enable) == 'boolean' then
			self:GetAttribute().Enable = false
	end
end
function OnMouseLeave(self)
	local attr = self:GetAttribute()
	if attr.Enable then
	self:SetState(0)
	end
end

function OnBind(self)
	local attr = self:GetAttribute()
	--self:SetText(attr.Text)
	attr.NowState=0
	local bkg = self:GetControlObject("bkg")
	bkg:SetResID(attr.NormalBkgID)
end