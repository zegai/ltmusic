package.path = package.path .. ';..\\bin\\package\\LtMusic\\layout\\?.lua;'
local play_manager = require('play_manager')
local play_node = {}
MainTree = {}
HostWndTB = {}

function close_btn_OnLButtonDown(self)
	---定义动画结束的回调函数
	local function onAniFinish(self,oldState,newState)
		if newState == 4 then
		----os.exit 效果等同于windows的exit函数，不推荐实际应用中直接使用
			os.exit()
		end
	end
	local bkg = MainTree:GetUIObject("id.app.border")
	local pbkg = MainTree:GetUIObject("id.main.bkg")
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	local alphaAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
	posAni:SetTotalTime(300)
	alphaAni:SetTotalTime(200)
	if HostWndTB.IsShow then
		posAni:SetKeyFrameRect(0,0,650,400,350,100,350,220);
	else
		posAni:SetKeyFrameRect(0,0,650,220,350,100,350,220);
	end
	
	alphaAni:SetKeyFrameAlpha(255,0)
	posAni:BindLayoutObj(bkg)
	alphaAni:BindRenderObj(pbkg)
	posAni:AttachListener(true,onAniFinish)
	MainTree:AddAnimation(posAni)
	MainTree:AddAnimation(alphaAni)
	alphaAni:Resume()
	posAni:Resume()

end

function OnNext()
	local next_item = MainTree:GetUIObject("id.func.list"):GetNext()
	if next_item then
		play_node.file_path = next_item.item_path_
		play_node.file_name = next_item.item_head_
	else
		XLMessageBox( 'Get Null Item' )
	end
	play_manager.play(play_node)
end

function OnPre()
	local pre_item = MainTree:GetUIObject("id.func.list"):GetPre()
	if pre_item then
		play_node.file_path = pre_item.item_path_
		play_node.file_name = pre_item.item_head_
	else
		XLMessageBox( 'Get Null Item' )
	end
	play_manager.play(play_node)
end
 

function OnTime(self)
	
	local attr = self:GetAttribute()
    local banner1 = attr.textuse
    local banner2 = attr.textfull
    local control = attr.control
    play_node = play_manager.update(play_node)
	if banner2:GetText() == '00:00' then
		local time = play_node.file_fulltime
		if time ~= nil and time ~= 0 then
			attr.FullTime = time
			local min = math.modf(time/60000);
			local sec = math.modf((time/1000)%60);
			if min < 10 then
				min = '0' .. min
			end
			if sec < 10 then
				sec = '0' .. sec
			end
			banner2:SetText(min .. ':' .. sec);
		end

	end
	

	local nowtime = play_node.file_curtime
	if nowtime ~= nil then
		local min = math.modf(nowtime/60000);
		local sec = math.modf((nowtime/1000)%60);
		if min < 10 then
			min = '0' .. min
		end
		if sec < 10 then
			sec = '0' .. sec
		end
		banner1:SetText(min .. ':' .. sec);
		if attr.FullTime ~= nil then
			if nowtime == attr.FullTime then
				if play_node.file_mode == 'listloop' then
					OnNext()
				elseif play_node.file_mode == 'singleloop' then
					play_manager.stop(play_node)
					play_manager.play(play_node)
				end
			end
			local scroll = attr.scoller;
			scroll:OnPersent(nowtime*1000/attr.FullTime);
		end
		
	end
	
end



function MSG_OnMouseMove(self)
	--self:SetTextFontResID ("msg.font.bold")
	self:SetCursorID ("IDC_HAND")
end

function MSG_OnMouseLeave(self)
	--self:SetTextFontResID ("msg.font")
	self:SetCursorID ("IDC_ARROW")
end

function btn_show(self)
	if HostWndTB.IsShow then
		ShowList(self, false);
		HostWndTB.IsShow = false;
	else
		ShowList(self, true);
		HostWndTB.IsShow = true;
	end
end

function ShowList(self, isshow)
	local bkg = MainTree:GetUIObject("id.app.border")
	local hostwnd = XLGetObject("Xunlei.UIEngine.HostWndManager"):GetHostWnd('MainFrame')
	local left,top,_,_ = hostwnd:GetWindowRect()
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	posAni:SetTotalTime(400)

	---定义动画结束的回调函数
	local function onAniFinish(self,oldState,newState)
		if not isshow and newState == 4 then
			hostwnd:Move(left, top, 650, 220)
		end
	end
	posAni:AttachListener(true,onAniFinish)
	if isshow then
		hostwnd:Move(left, top, 650, 400)
		posAni:SetKeyFrameRect(0,0,650,220,0,0,650,400);
	else
		posAni:SetKeyFrameRect(0,0,650,400,0,0,650,220);
	end
	posAni:BindLayoutObj(bkg)
	MainTree:AddAnimation(posAni)
	posAni:Resume()
	
end


function add_item(self)
	local lc = MainTree:GetUIObject("id.func.list")
	if HostWndTB.List == nil then
		local ownc = lc:GetControlObject("LIST_C")
		local own = ownc:GetOwnerControl()
		HostWndTB.List = own;
	end
	local ls = HostWndTB.List;
	local lattr = ls:GetAttribute()
	
	lattr.DataFlag = "INSERT";

	local path,name,len = play_manager:load()
	if type(path) == 'table' then
		for k, v in ipairs(path) do
			local min = math.modf(v.time/60000);
			local sec = math.modf((v.time/1000)%60);
			if sec < 10 then
				sec = '0' .. sec
			end
			lc:AddItem{item_head_ = v.name, item_text_ = min .. ":" .. sec , item_path_ = v.path}
		end
		return 
	end
	if path ~= nil and name ~= nil then
		local min = math.modf(len/60000);
		local sec = math.modf((len/1000)%60);
		if sec < 10 then
			sec = '0' .. sec
		end
		lc:AddItem{item_head_ = name, item_text_ = min .. ":" .. sec , item_path_ = path}
	end
end

function pause_item(self)
	play_manager.pause('nil')
end


function play_item(self)
	play_manager.pause('nil');
end


function start_play_item(self)
	local attr = self:GetAttribute();
	if attr.playpath == nil then
		XLMessageBox('NULL PATH!')
	else
		play_node.file_path = attr.playpath
		play_manager.play(play_node)
	end
	
	
end

function OnListDBClick(self, str, attr)
	if attr.data_model_ ~= nil then
		play_node.file_path = attr.data_model_.item_path_
		play_node.file_name = attr.data_model_.item_head_
		play_manager.play(play_node)
	end
end

function OnPointChange(self, str,attr)
	play_node.file_persent = tonumber(attr)
	play_manager.jump(play_node)
end

function ShowModalDialog(self, wndClass, wndID, treeClass, treeID, userData, xarName, needF)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
    local modalHostWndTemplate = templateMananger:GetTemplate(wndClass,"HostWndTemplate")
    if modalHostWndTemplate == nil then
		XLMessageBox("找不到"..wndClass)
        return false
    end
    local modalHostWnd = modalHostWndTemplate:CreateInstance(wndID)
    if modalHostWnd == nil then
		XLMessageBox("无法创建"..wndID)
        return false
    end
	
    local objectTreeTemplate = templateMananger:GetTemplate(treeClass,"ObjectTreeTemplate")
    if objectTreeTemplate == nil then
		XLMessageBox("找不到"..treeClass)
        return false
    end
    local uiObjectTree = objectTreeTemplate:CreateInstance(treeID, xarName)
    if uiObjectTree == nil then
		XLMessageBox("无法创建"..treeID)
        return false
    end

	modalHostWnd:SetUserData(userData)
    modalHostWnd:BindUIObjectTree(uiObjectTree)

    local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
    local hostwnd = hostwndManager:GetHostWnd("MainFrame")
    --新窗口动画
    if needF then
    	local objTree = self:GetOwner()
		local rootObj = objTree:GetRootObject()
		--动态创建一个ImageObject,这个Object在XML中没定义
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		local wndimage = objFactory:CreateUIObject("wndimage","ImageObject")
		local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
		wndimage:SetResProvider(xarManager)
		local left,top,right,bottom = rootObj:GetObjPos()--坐标
		wndimage:SetObjPos2((right-left)/2-175,(bottom-top)/2-110,350,200)
		wndimage:SetZorder(1200)
		--画出一个图片
		local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
		local xlbitmap = xlgraphic:CreateBitmap("ARGB32",350,200)
		local render = XLGetObject("Xunlei.UIEngine.RenderFactory")
		render:RenderObject(uiObjectTree:GetRootObject(),xlbitmap)

		wndimage:SetBitmap(xlbitmap)
		rootObj:AddChild(wndimage)
		--动画
		local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
		local angleAni = aniFactory:CreateAnimation("AngleChangeAnimation")
		angleAni:BindObj(wndimage)
		angleAni:SetKeyFrameAngle(10,0,10,0,0,0)
		angleAni:SetTotalTime(200)
		local cookie = angleAni:AttachListener(true,function(self,oldState,newState)
			if newState == 4 then
				rootObj:RemoveChild(wndimage)
				local mainWnd = hostwndManager:GetHostWnd("MainFrame")
				local nRes = modalHostWnd:DoModal(mainWnd:GetWndHandle())

				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree(uiObjectTree)

				hostwndManager:RemoveHostWnd(modalHostWnd:GetID())
				return nRes
			end
		end)
		local objTree = self:GetOwner()
		objTree:AddAnimation(angleAni)
		angleAni:Resume()
	else
		local nRes = modalHostWnd:DoModal(hostwnd:GetWndHandle())
    	hostwndManager:RemoveHostWnd(modalHostWnd:GetID())
    	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")
    	objtreeManager:DestroyTree(uiObjectTree)

		return nRes
    end
end

function show_define(self)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	ShowModalDialog(self,"ltAdd.wnd", "ltAdd.wnd.1","ltAdd.tree","ltAdd.tree.1",play_manager,nil,true)
end

function OnAddClick(self)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	ShowModalDialog(self,"ltAdd.wnd", "ltAdd.wnd.1","ltAdd.tree","ltAdd.tree.1",nil,nil,true)
end

function OnSaveClick(self)
	local list_ = XLGetGlobal("MakeNew.Middle"):Main_Tree():GetUIObject( 'id.func.list' )
	list_:SaveAll()
end

function OnNextClick(self)
	OnNext()
end

function OnPreClick(self)
	OnPre()
end

function single_click(self)
	local btn = MainTree:GetUIObject('music.loop.btn')
	btn:SetVisible(true);
	btn:SetChildrenVisible(true);
	self:SetVisible(false);
	self:SetChildrenVisible(false);
	play_node.file_mode = 'listloop'
	play_manager.setmode(play_node)
	play_manager.save_config()
end

function loop_click(self)
	local btn = MainTree:GetUIObject('music.single.btn')
	btn:SetVisible(true);
	btn:SetChildrenVisible(true);
	self:SetVisible(false);
	self:SetChildrenVisible(false);
	play_node.file_mode = 'singleloop'
	play_manager.setmode(play_node)
	play_manager.save_config()
end

function OnInitControl(self)
	local owner = self:GetOwner()
	MainTree = owner;
	HostWndTB.IsShow = false;
	local btn = owner:GetUIObject("music.pause.btn")
	btn:SetVisible(false);
	btn:SetChildrenVisible(false);
	play_node = play_manager.get_config()
	if play_node.file_mode == 'listloop' then
		btn = owner:GetUIObject('music.single.btn')
	else
		btn = owner:GetUIObject('music.loop.btn')
	end
	
	btn:SetVisible(false);
	btn:SetChildrenVisible(false);
	local Mananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
    local banner = Mananger:GetTemplate("def.ani","AnimationTemplate")
    local instance = banner:CreateInstance()
    if instance then
    	local attr = instance:GetAttribute();
    	--当前播放时间
    	attr.textuse = owner:GetUIObject("time.text.use");
    	--歌曲总时间
    	attr.textfull = owner:GetUIObject("time.text.full");
    	--进度条
    	attr.scoller = owner:GetUIObject("music.scoller");
    	--动画响应函数
    	attr.func = OnTime;
    	--播放歌曲路径
    	attr.playpath = ""
    	owner:AddAnimation(instance)
        instance:Resume()
    end
    local function UIPlayStatus()
    	local showbtn = MainTree:GetUIObject("music.pause.btn");
		local hidebtn = MainTree:GetUIObject("music.play.btn");
		showbtn:SetVisible(true);
		showbtn:SetChildrenVisible(true);
		hidebtn:SetVisible(false);
		hidebtn:SetChildrenVisible(false);
		MainTree:GetUIObject('id.text.name'):SetText(play_node.file_name)
		MainTree:GetUIObject("time.text.full"):SetText('00:00')
    end
    local function UIPauseStatus(item)
    	local showbtn = MainTree:GetUIObject("music.pause.btn");
		local hidebtn = MainTree:GetUIObject("music.play.btn");
		if item.play_status == 'pause' then
			showbtn:SetVisible(false);
			showbtn:SetChildrenVisible(false);
			hidebtn:SetVisible(true);
			hidebtn:SetChildrenVisible(true);
		else
			showbtn:SetVisible(true);
			showbtn:SetChildrenVisible(true);
			hidebtn:SetVisible(false);
			hidebtn:SetChildrenVisible(false);
		end
    end
    play_manager.set_callback(UIPlayStatus, UIPauseStatus, nil, nil, nil)
    
end

