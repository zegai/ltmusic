local user_data = nil

function OnCreate(self)

	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostWndManager:GetHostWnd("MainFrame")
	user_data = self:GetUserData()
	local volume = self:GetBindUIObjectTree():GetUIObject('music.scoller')
	volume:OnPersent(user_data.get_memconfig().file_volume*10)
	self:Center(mainWnd)
	
end

function OnInitControl(self)
	
	--volume:OnPersent(user_data.get_memconfig().file_volume)
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	hostwnd:EndDialog(0)
end

function Globel_Get_Obj(self, wndname, objname)
	assert( wndname and objname )

	local hostWnd = XLGetObject("Xunlei.UIEngine.HostWndManager"):GetHostWnd(wndname)
	return hostWnd:GetBindUIObjectTree():GetUIObject(objname)

end

function OnPointChange(self, str, attr)
	if user_data then
		local vl = {}
		vl.file_volume = tonumber(attr)
		user_data.volume(vl)
		user_data.save_config()
	end
end

function OnAddClick(self)
	
	local own_ = self:GetOwner();

	local item_ = Globel_Get_Obj(self, 'MainFrame', 'id.func.list')
	
	assert( item_ )

	local item_attr_ = {
		item_head_ = own_:GetUIObject("id.inputedit"):GetText(),
		item_text_ = own_:GetUIObject("id.valueedit"):GetText(),
	}

	item_:AddItem(item_attr_)
	
	OnClose(own_:GetUIObject("close.btn"));

end