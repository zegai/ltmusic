package.path = package.path .. ';..\\bin\\package\\LtMusic\\layout\\?.lua;'
local play_manager = require('play_manager')
local play_node = {
	file_name = '',
	file_curtime = '',
	file_fulltime = '',
	file_path = '',
	file_nextpath = '',
	file_persent = '',
}
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

local function Make_Next()
	local nextpath = play_node.file_nextpath
	local next_item = MainTree:GetUIObject("id.func.list"):GetNext()
	if next_item then
		play_node.file_path = nextpath;
		play_node.file_nextpath = next_item.item_path_;
	else
		XLMessageBox( 'Get Null Item' )
	end
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
			if nowtime + 1000 > attr.FullTime then
				Make_Next()
				attr.playpath = play_node.file_path;
				XLMessageBox('[DEBUG]:' .. attr.playpath)
				banner2:SetText('00:00');
				start_play_item(self);
			end
			local scroll = attr.scoller;
			scroll:OnPersent(nowtime*1000/attr.FullTime);
		end
		
	end
	
end

function OnInitControl(self)
	local owner = self:GetOwner()
	MainTree = owner;
	HostWndTB.IsShow = false;
	local btn = owner:GetUIObject("music.pause.btn")
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
    	attr.playpath = "D:/Github/sbplayer/bin/2.mp3"
    	owner:AddAnimation(instance)
        instance:Resume()
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
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	posAni:SetTotalTime(400)
	if isshow then
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
	local showbtn = MainTree:GetUIObject("music.play.btn");
	showbtn:SetVisible(true);
	showbtn:SetChildrenVisible(true);
	self:SetVisible(false);
	self:SetChildrenVisible(false);
end


function play_item(self)
	play_manager.pause('nil');
	local showbtn = MainTree:GetUIObject("music.pause.btn");
	showbtn:SetVisible(true);
	showbtn:SetChildrenVisible(true);
	self:SetVisible(false);
	self:SetChildrenVisible(false);

end


function start_play_item(self)
	local attr = self:GetAttribute();
	if attr.playpath == nil then
		XLMessageBox('NULL PATH!')
	else
		play_node.file_path = attr.playpath
		play_manager.play(play_node)
	end
	local showbtn = MainTree:GetUIObject("music.pause.btn");
	local hidebtn = MainTree:GetUIObject("music.play.btn");
	showbtn:SetVisible(true);
	showbtn:SetChildrenVisible(true);
	hidebtn:SetVisible(false);
	hidebtn:SetChildrenVisible(false);
	
end


function save_items(self)
	MainTree:GetUIObject("id.func.list"):SaveAll()
end

function OnListDBClick(self, str, attr)
	if attr.data_model_ ~= nil then
		play_node.file_path = attr.data_model_.item_path_
		play_manager.play(play_node)
		play_node.file_nextpath = MainTree:GetUIObject("id.func.list"):GetNext().item_path_
		MainTree:GetUIObject('id.text.name'):SetText(attr.data_model_.item_head_)
	end
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
		wndimage:SetObjPos2((right-left)/2-175,(bottom-top)/2-150,300,200)
		wndimage:SetZorder(1200)
		--画出一个图片
		local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
		local xlbitmap = xlgraphic:CreateBitmap("ARGB32",300,200)
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

function OnAddClick(self)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	ShowModalDialog(self,"ltAdd.wnd", "ltAdd.wnd.1","ltAdd.tree","ltAdd.tree.1",nil,nil,true)
end

function OnSaveClick(self)
	local list_ = XLGetGlobal("MakeNew.Middle"):Main_Tree():GetUIObject( 'id.func.list' )
	list_:SaveAll()
end



