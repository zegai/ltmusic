--lua文件必须是UTF-8编码的(最好无BOM头)
function SetState(self,newState) 		
		local attr = self:GetAttribute()
		local bkg = self:GetControlObject("itembkg");
		if newState ~= attr.NowState then
			local ownerTree = self:GetOwner()
			if newState == 0 then
				bkg:SetSrcColor(attr.NormalColor)
			elseif newState == 1 then
				bkg:SetSrcColor(attr.DownColor)
			elseif newState == 2 then
				bkg:SetSrcColor(attr.DisableColor)
			elseif newState == 3 then
				bkg:SetSrcColor(attr.HoverColor)
			end
			attr.NowState = newState
		end
end

function SetText(self,newText)
	local textObj = self:GetControlObject("item.text")
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
	local bkg = self:GetControlObject("itembkg");
	bkg:SetAlpha(255);
end

function OnMouseLeave(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("itembkg");
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local alphaAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
	local owner = bkg:GetOwner()
	alphaAni:SetTotalTime(300)
	alphaAni:SetKeyFrameAlpha(255,60)
	alphaAni:BindRenderObj(bkg)
	owner:AddAnimation(alphaAni)
	alphaAni:Resume()
	
	--self:SetState(0)
	--bkg:SetAlpha(0)
end

function OnLButtonDbClick(self)
	local attr = self:GetAttribute()
	--if attr.Enable then
	--if attr.NowState==1 then
	self:FireExtEvent("OnDoubleClick", self:GetAttribute());
	
	--self:SetState(2) 
		--end
		
		--self:SetCaptureMouse(false)
	--end
end

function OnBind(self)
	local attr = self:GetAttribute()
	--self:SetText(attr.Text)
	attr.NowState=0
	local bkg = self:GetControlObject("itembkg")
	bkg:SetSrcColor(attr.NormalColor)
	if attr.data_model_ ~= nil then
		local tname = self:GetControlObject("item.text.name")
		tname:SetText(attr.data_model_.item_head_);
		local tsing = self:GetControlObject("item.text.singer")
		tsing:SetText(attr.data_model_.item_text_);
	end
end

function Globel_Get_Obj( wndname, objname)
	assert( wndname and objname )

	local hostWnd = XLGetObject("Xunlei.UIEngine.HostWndManager"):GetHostWnd(wndname)
	return hostWnd:GetBindUIObjectTree():GetUIObject(objname)

end

function DelClick(self)
	
	local item_ = Globel_Get_Obj('MainFrame', 'id.func.list')
	item_:DelItem(self:GetParent())
end

function SetBtnEnable(self, enable)
	local btn = self:GetControlObject('del.btn')
	assert( btn )

	btn:Enable(enable) 
end