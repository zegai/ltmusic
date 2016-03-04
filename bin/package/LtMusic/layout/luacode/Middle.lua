--初始化
function Initialize(self, mainObjTree)
	self.mainObjTree = mainObjTree
	self._comm_table = {}
	self._self_table = {}
end

--窗口通过注册接口函数来公开可回调的接口
--
function RegisterRetfunc(self, item, pfuntable , key)
	
	local class_,id_

	class_ = item:GetClass()
	id_ = item:GetID()

	--assert( class_ and id_ )
	if not (class_ and id_) then return false end

	if key == nil then
		if self._comm_table[class_] ~= nil then
			self._comm_table[class_][id_] = item
			return true
		end
		self._comm_table[class_]['__func_list'] = pfuntable
		self._comm_table[class_][id_] = item;
	else
		if self._self_table[class_] ~= nil then
			self._self_table[class_][id_] = item
		end
		self._self_table[class_]['__func_list'] = pfuntable
		self._self_table[class_]['__prim_key'] = key
		self._self_table[class_][id_] = item
	end

	return true
end


function CallRetfunc(self, itemclass ,itemid, funcname, userdata, key)
	
	assert( self and itemclass and itemid )

	if not key then
		if self._comm_table[itemclass][itemid] == nil or 
		   type(self._comm_table[itemclass]['__func_list'][funcname]) ~= 'function'  then
			return false, 'could not found '.. funcname
		end
		return true,self._comm_table[itemclass]['__func_list'][funcname](
			self._comm_table[itemclass][itemid],
			userdata
		)
	else
		if self._self_table[itemclass] == nil or
		   self._self_table[itemclass]['__prim_key'] ~= key or
		   type(self._self_table[itemclass]['__func_list'][funcname]) ~= 'function' then
		   	return false, 'could not found '.. funcname
		end
		return true,self._self_table[itemclass]['__func_list'][funcname](
			self._self_table[itemclass][itemid],
			userdata
		)
	end
	
end

function Globel_Get_Obj(self, wndname, objname)
	assert( wndname and objname )

	local hostWnd = XLGetObject("Xunlei.UIEngine.HostWndManager"):GetHostWnd("wndname")
	return hostwnd:GetBindUIObjectTree():GetUIObject(objname)

end

function RegisterObject( self )
	-- body
	local retobj = {}
	retobj.Initialize = Initialize
	retobj.RegisterRetfunc = RegisterRetfunc
	retobj.CallRetfunc = CallRetfunc
	retobj.Globel_Get_Obj = Globel_Get_Obj
	XLSetGlobal("MakeNew.Middle", retobj)
end
