---@class UIBase
---@field m_parent ILuaDialog
---@field m_root GameObject
---@field m_layout LuaLayout
---@field m_rootDestroying boolean
---@field m_destroyed boolean
---@field m_doWhenClose function[]
---@field m_allTimer number[]
---@field m_allCustomComponents {}[]
UIBase = Class("UIBase");

---@param gobj GameObject
---@param parent ILuaDialog
function UIBase:Initialize(gobj, parent)
  self.m_destroyed = false;
  self.m_rootDestroying = false;
  self.m_parent = parent;
  self.m_root = gobj;
  self.m_layout = gobj:GetComponent("Torappu.Lua.LuaLayout");
  local this = self;
  self.m_layout:TraverseCtrlDefines(function(name, ctrl)
    this["_"..name] = ctrl;
  end);

  self:OnInitialize();
  self.m_layout:BindLayoutEventListener(self);
end

function UIBase:Dispose()
  if self.m_destroyed then
    return;
  end
  if not self.m_rootDestroying then
    self.m_layout:BindLayoutEventListener(nil);
  end

  self:OnDispose();

  if self.m_allCustomComponents then
    for _, com in ipairs(self.m_allCustomComponents) do
        if com.Dispose then
            com:Dispose();
        end
    end
  end

  if self.m_doWhenClose then
    for _, func in ipairs(self.m_doWhenClose) do
      func();
    end
    self.m_doWhenClose = nil;
  end

  if self.m_allTimer then
    for index, timer in ipairs(self.m_allTimer) do
      TimerModel.me:Destroy(timer);
    end
    self.m_allTimer = nil;
  end

  self.m_destroyed = true;

  if not self.m_rootDestroying then
    CS.UnityEngine.GameObject.Destroy(self.m_root);
  end

end

---@protected
function UIBase:OnInitialize()
end

---@protected
function UIBase:OnDispose()
end

---@protected
function UIBase:OnVisible(v)
end

function UIBase:RootGameObject()
    return self.m_root;
end

---@protected
function UIBase:OnResume()
end

---@protected
function UIBase:OnEnter()
end

---@protected
function UIBase:OnExit()
end

function UIBase:IsDestroy()
    return self.m_destroyed;
end

---为btn注册点击事件
---@param btn Button|string
---@param func 
function UIBase:AddButtonClickListener(btn, func, ...)
    if type(btn) == "string" then
        btn = self:GetButton(btn);
    end
    if not btn then
        return;
    end
    local args = {...};
    local this = self;
    btn.onClick:AddListener( function()
        func(this, table.unpack(args));
    end);

    self:_AddToDoWhenClose(function()
        if not CS.Torappu.Lua.Util.IsDestroyed(btn) then
            btn.onClick:RemoveAllListeners();
            btn.onClick:Invoke();
        end
    end);
end

---为cs对象的代理赋值，在关闭时会自动把赋值清理掉
---@param obj object
---@param delegateName string
---@param func function
---@param ... any 不定参数, 可以在注册时传递一些数据到func里去，在回调参数之后。
---                如代理本身有a，b，c三个参数，注册时传递了arg1 arg2 arg3三个参数
---                则最终在函数func里得到的参数是 function(a, b, c, arg1, arg2, arg3)
function UIBase:AsignDelegate(obj, delegateName, func, ...)
    local args = {...}
    local this = self;
    obj[delegateName] = function(...)
        local params = {...}
        if #params < 1 then
            params = args;
        elseif #args > 0 then
            for _, v in ipairs(args) do
                table.insert(params, v);
            end
        end
        
        func(this, table.unpack(params));
    end
    
    self:_AddToDoWhenClose(function()
        if not CS.Torappu.Lua.Util.IsDestroyed(obj) then
            obj[delegateName] = nil;
        end
    end);
end

---@private
function UIBase:_AddToDoWhenClose(func)
    if not func then
        return;
    end
    if not self.m_doWhenClose then
        self.m_doWhenClose = {};
    end
    table.insert(self.m_doWhenClose, func);
end

---延时执行
function UIBase:Delay(delay, func)
    local timer = TimerModel.me:Delay(delay, Event.Create(self, func));
    self:_RecordTimer(timer);
    return timer;
end

function UIBase:Interval(interval, loop, func)
    local timer = TimerModel.me:Interval(interval, loop, Event.Create(self, func));
    self:_RecordTimer(timer);
    return timer;
end

function UIBase:Frame(loop, func, ...)
    local timer = TimerModel.me:Frame(loop, Event.Create(self, func, ...));
    self:_RecordTimer(timer);
    return timer;
end

function UIBase:NextFrame(func)
    local timer = TimerModel.me:NextFrame(Event.Create(self, func));
    self:_RecordTimer(timer);
    return timer;
end

function UIBase:DestroyTimer(timer)
    TimerModel.me:Destroy(timer);
    if self.m_allTimer then
        for idx, v in ipairs(self.m_allTimer) do
            if v == timer then
                table.remove(self.m_allTimer, idx);
            end
        end
    end
end

---@private
function UIBase:_RecordTimer(timer)
    if not self.m_allTimer then
        self.m_allTimer = {};
    end
    table.insert(self.m_allTimer, timer);
end

---打开UI页面
function UIBase:OpenPage(pageName, openType, options)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, openType, options)
end

--- 打开UI页面
---示例：
---self:OpenPage1("stage")
---self:OpenPage(CS.Torappu.UI.UIPageNames.STAGE)
function UIBase:OpenPage1(pageName)
    CS.Torappu.UI.UIPageController.OpenPage(pageName)
end

--- 打开UI页面
---示例：
---self:OpenPage2(CS.Torappu.UI.UIPageNames.SHOP, CS.Torappu.UI.UIPageOpenType.SINGLE_INST);
function UIBase:OpenPage2(pageName, openType)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, openType)
end

--- 打开UI页面
---示例：
--[[
local params = CS.Torappu.UI.UIGainItemPage.Params();

local pointItemData = CS.Torappu.UI.UIItemViewModel();
pointItemData:LoadGameData(self.pointId, CS.Torappu.ItemType.NONE);
params.itemModels = {pointItemData};

self:OpenPage3(CS.Torappu.UI.UIPageNames.GAIN_ITEM, {
    args = params
});

]]
function UIBase:OpenPage3(pageName, options)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, options)
end

--- 由用户类创建一个用户组件，
--- 参数 comCls 为用户实现的组件类，可实现 Initialize 及 Dispose 接口，分别会在创建及窗口关闭时调用
---@param comCls 用户组件类
---@param ... 传入Initialize的参数
---@return 返回创建好的组件对象
function UIBase:CreateCustomComponent(comCls, ...)
    if not self.m_allCustomComponents then
        self.m_allCustomComponents = {};
    end
    local com = comCls.new();
    com:Initialize(...);
    table.insert(self.m_allCustomComponents, com);
    return com;
end

---@private call by lualayout
function UIBase:OnEnable()
    self:OnVisible(true);
end

---@private call by lualayout
function UIBase:OnDisable()
    self:OnVisible(false);
end

---@private call by lualayout
function UIBase:OnDestroy()
    self.m_rootDestroying = true;
    self:Dispose();
end