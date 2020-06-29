---@class UIBase
---@field m_context LuaUIContext
---@field m_root GameObject
---@field m_layout LuaLayout
---@field m_destroyed boolean
---@field m_doWhenClose function[]
---@field m_allTimer number[]
UIBase = Class("UIBase");

---@param gobj GameObject
---@param ctx LuaUIContext
function UIBase:Initialize(gobj, ctx)
  self.m_destroyed = false;
  self.m_context = ctx;
  self.m_root = gobj;
  self.m_layout = gobj:GetComponent("Torappu.Lua.LuaLayout");
  local this = self;
  self.m_layout:TraverseCtrlDefines(function(name, ctrl)
    this["_"..name] = ctrl;
  end);

  self:OnInitialize();
  self.m_layout:BindLayoutEventListener(self);
end

function UIBase:Destroy()
  if self.m_destroyed then
    return;
  end
  self.m_layout:BindLayoutEventListener(nil);
  self:OnDestroy();

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

  CS.UnityEngine.GameObject.Destroy(self.m_root);

  self.m_destroyed = true;
end

---@protected
function UIBase:OnInitialize()
end

---@protected
function UIBase:OnDestroy()
end

---@protected
function UIBase:OnVisible(v)
end

function UIBase:Root()
    return self.m_root;
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
function UIBase:AsignDelegate(obj, delegateName, func)
    obj[delegateName] = func;
    
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
end