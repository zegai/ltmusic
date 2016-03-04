--节点集合
local local_items_ = {}
--设置
local local_set_ = 
{ 
	item_height_ = 30,
	min_index_ = -1,
	max_index_ = 0,
	if_save_ = false,
	add_item_update_callback_ = 'nil',
	del_item_update_callback_ = 'nil',
	serialization_func_ = 'nil'
}
--空闲节点列表
local free_index_ = {}

--获取节点在表中位置。 传入item的ID号
local function get_item_index_( item_index_ )
	-- body
	local count_ = 1

	for k,v in pairs(local_items_) do
		if v.item_id_ == item_index_ then return count_ end
		count_ = count_ + 1
	end
end

--根据节点在容器中的位置推算其在表中位置
local function get_quick_item_index_( item_ )
	-- body
	assert( item_:GetClass() )

	local _, _, _, bottom = item_:GetObjPos()
	
	return bottom / local_set_.item_height_
end

--根据ID获取item
local function get_item_( item_id_ )
	for k,item in pairs(local_items_) do
		if item_id_ == item.item_id_ then
			return item.item_val_
		end
	end
end 


--获取表中保存的节点数量
local function get_item_count_( )
	return #local_items_
end

--获取一个可用的节点ID
local function make_item_index_( )

	if local_set_.min_index_ == -1 then
		return #local_items_ + 1
	end

	return local_set_.min_index_
end

--添加节点
local function add_item_index_( item_ )
	assert( item_ and type(item_) == 'table' )
	assert( item_.item_id_ and item_.item_val_ and type(item_.item_id_) == 'number' )
	if item_.item_id_ ~= make_item_index_() then
		return false
	end
	local tmp_val_ = item_.item_id_
	item_.item_id_ = 'item' .. item_.item_id_
	table.insert(local_items_, item_)

	--满节点
	if local_set_.min_index_ == -1 then
		local_set_.max_index_ = #local_items_
		if type(local_set_.add_item_update_callback_) == 'function' then
			local_set_.add_item_update_callback_(item_.item_val_, #local_items_)
		end
		return true
	end

	--差一个节点就满节点
	if local_set_.max_index_ == #local_items_ then
		local_set_.min_index_ = -1
		local_set_.add_item_update_callback_(item_.item_val_, #local_items_)
		return true
	end

	--从free_index_中获取 获取最小的那个
	assert( free_index_ )
	local i 
	local min_val_ = free_index_[1]
	for k, v in pairs(free_index_) do
		if v < min_val_ then
			i, min_val_  = k, v
		end 
	end

	local_set_.min_index_ = min_val_
	table.remove(free_index_, i)
	local_set_.add_item_update_callback_(item_.item_val_, #local_items_)
	return true
end

--删除节点
local function del_item_index_( item_ )

	local item_index_ = get_item_index_( item_ )
	table.remove(local_items_, item_index_)
	local useful_index_ = tonumber(string.match(item_, '%d+'))
	--更新保存可用节点信息
	if local_set_.min_index_ == -1 then local_set_.min_index_ = useful_index_ 
	elseif local_set_.min_index_ > useful_index_ then 
		table.insert(free_index_, local_set_.min_index_)
		local_set_.min_index_ = useful_index_ 
	else table.insert(free_index_, useful_index_) end

	for i=item_index_, #local_items_ do
		local_set_.del_item_update_callback_(local_items_[i].item_val_, i)
	end

end

--设置添加时的界面更新回调
local function set_add_update_func( func )
	assert( type(func) == 'function' )
	local_set_.add_item_update_callback_ = func
end

--设置删除时的界面更新回调
local function set_del_update_func( func )
	assert( type(func) == 'function' )
	local_set_.del_item_update_callback_ = func
end

local function write_info_(data)
	local fdate = 'save.json'
	local f = assert(io.open(fdate, 'w+'))
	if f == nil then  return end
	f:write(data);
	f:close();
end

local function save_items_(  )
	local val_string_ = ''
	for k, item_ in ipairs(local_items_) do
		assert( type( item_.item_user_ ) == 'table' )
		val_string_ = val_string_ .. local_set_.serialization_func_.encode( item_.item_user_ )
	end
	local fdate = 'save.json'
	local core = XLGetObject("HelloBolt.Music.Factory"):CreateInstance() or nil
	if core then
		fdate = core:GetPath() .. fdate
	end
	local f = assert(io.open(fdate, 'w+'))
	if f == nil then  return end
	f:write(val_string_);
	f:close();
end

local function read_info_(data)
	local fdate = 'save.json'
	local f = io.open(fdate, 'a+b')
	if f == nil then  return 'nil' end
	local save_str_ = f:read('*all')
	f:close()
	return save_str_
end


local function make_save_( save_ )
	assert( type(save_) == 'boolean' )
	local_set_.if_save_ = save_
end

local function get_item_udata_( pos )
	if local_items_[pos] then
		return local_items_[pos].item_user_
	end
	return 'nil'
end

local function set_serialization_func_( handle )
	assert( handle.decode and handle.encode )
	local_set_.serialization_func_ = handle
end

local manager = {}

manager.add_item = add_item_index_
manager.del_item = del_item_index_

manager.set_add_update = set_add_update_func
manager.set_del_update = set_del_update_func

manager.make_index = make_item_index_

manager.get_count = get_item_count_

manager.make_save = make_save_
manager.put_save = save_items_
manager.get_save = read_info_
manager.set_serialization = set_serialization_func_

manager.get_item_value = get_item_udata_
manager.get_item_index = get_item_index_

return manager

