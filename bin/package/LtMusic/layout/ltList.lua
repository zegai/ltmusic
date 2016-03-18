package.path = package.path .. ';..\\bin\\package\\LtMusic\\layout\\?.lua;'
local manager = require('item_manager')
local json_ = require('json')
--对应item索引
local user_set_ = {
	_item_height = '30',
	_item_width = '0',
	_max_item = 'nil',
	_show_scroll = '-1', --show '1~N' --don't show '0' --auto  value < 0
	_local_click = 'nil',
	_item_count = 0,
	_pos_value = {
		left = 0,
		top = 0,
		right = 0,
		bottom = 0,
	}
}

local function SetScrollVisible(self, isshow)
	local scroll = self:GetControlObject("list.vscoll")
	scroll:SetChildrenVisible(isshow);
end


function OnBind(self)
	SetScrollVisible(self, false);
end

local function check_scroll(self)
	if tonumber(user_set_._show_scroll) < 0 then
		   local _full_height = user_set_._pos_value.bottom - user_set_._pos_value.top
		   if manager.get_count()*user_set_._item_height > _full_height then
		   		SetScrollVisible(self, true)
		   		local scroll_obj = self:GetControlObject("list.vscoll")
		   		assert( scroll_obj )
		   		scroll_obj:SetScrollLen((_full_height*_full_height/user_set_._item_height)/manager.get_count())
		   else
		   		SetScrollVisible(self, false)
		   end
	else
		SetScrollVisible(self, false)
	end
end 


function OnScollChange(self)
	local own = self:GetOwnerControl()

	local scrollobjfill = own:GetControlObject("list.vscoll"):GetControlObject("fillarea")
	
	local moveobj = own:GetControlObject("list.content")
	
	local _,y1,_,y2 = scrollobjfill:GetObjPos()
	local height = y2 - y1;
	
	local _full_height = user_set_._pos_value.bottom - user_set_._pos_value.top
	local pos = y1*_full_height / height
	
	moveobj:SetObjPos(0, -pos, 500, _full_height - pos);
end


function update_callback( item_, pos )
	item_:SetObjPos2(0,(pos-1)*user_set_._item_height,"father.width-15",user_set_._item_height);
end

function Add_Item(self, item)

	assert( self and item )

	local contain_ = self

	local function OnItemDBClick(self, str, attr)
		--XLMessageBox( tostring(str) .. ':' .. self:GetID())
		attr.item_id_ = self:GetID()
		user_set_._local_click = self:GetID()
		contain_:FireExtEvent("OnItemDBClick", attr);
	end

	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()

	local item_v_ = manager.make_index()
	local item_obj = xarFactory:CreateUIObject("item"..item_v_, "ltui.MLItem")
	
	local itattr = item_obj:GetAttribute()

	local insert_val_ = { item_id_ = item_v_, item_val_ = item_obj, item_user_ = item }

	assert( item.item_head_ and item.item_text_ )

	itattr.data_model_ = item

	local fill_parent_ = self:GetControlObject("list.content")
	--添加子节点
	fill_parent_:AddChild(item_obj)

	item_obj:AttachListener("OnDoubleClick", true, OnItemDBClick);
	
	manager.add_item( insert_val_ )
	user_set_._item_count = user_set_._item_count + 1
	manager.put_save()
	check_scroll(self) 

end

function Get_Item_Val( self , pos )
	return manager.get_item_value( pos )
end

function Del_Item( self, item )
	-- 
	local content_ = self:GetControlObject("list.content")
	
	local item_id_ = item:GetID()
	local v = content_:RemoveChild(item)
	
	manager.del_item(item_id_)
	user_set_._item_count = user_set_._item_count - 1
	manager.put_save()
	check_scroll(self)
end

function Save_All( self )
	manager.put_save()
end

function Reverse_Save( self )
	local save_str_ = manager.get_save()
	if save_str_ ~= 'nil' then 
		for item_ in string.gmatch(save_str_, '\{.-\}') do
			Add_Item( self, json_.decode(item_) )
		end
	end
end

function Turn_Next( self )
	if user_set_._item_count == 0 then return nil end
	local count = manager.get_item_index( user_set_._local_click )
	if count == user_set_._item_count then
		local item_V_ = manager.get_item(1)
		user_set_._local_click = item_V_.item_id_
		return item_V_.item_user_
	end
	local item_V_ = manager.get_item(count + 1)
	user_set_._local_click = item_V_.item_id_
	return  item_V_.item_user_
end

function Trun_Pre( self , item)
	if user_set_._item_count == 0 then return nil end
	local count = manager.get_item_index( user_set_._local_click )
	if count == 1 then
		local item_V_ = manager.get_item(user_set_._item_count)
		user_set_._local_click = item_V_.item_id_
		return item_V_.item_user_
	end
	local item_V_ = manager.get_item(count - 1)
	user_set_._local_click = item_V_.item_id_
	return  item_V_.item_user_
end



function OnInitControl(self)
	local attr = self:GetAttribute()
	user_set_._item_height = attr.ItemHeight
	user_set_._show_scroll = attr.Scroll

	user_set_._pos_value.left,
	user_set_._pos_value.top,
	user_set_._pos_value.right,
	user_set_._pos_value.bottom = self:GetObjPos()

	manager.set_add_update( update_callback )
	manager.set_del_update( update_callback )
	manager.set_serialization( json_ )
	Reverse_Save(self)
end
