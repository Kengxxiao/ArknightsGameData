












UIBase = Class("UIBase");


function UIBase.GetLuaLayout(go)
    if go == nil then
        return nil
    end
    return go:GetComponent("Torappu.Lua.LuaLayout")
end 



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
  self.m_layout:TraverseValueDefines(function(name, value)
    this["_"..name] = value
  end)

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
    self.m_allTimer:ReleaseAll();
  end

  if self.m_coroutines then
    self.m_coroutines:ReleaseAll();
  end

  if self.m_tweens then
    self.m_tweens:ReleaseAll();
  end

  if self.m_disposeObjs then
    for _, obj in ipairs(self.m_disposeObjs) do
        obj:Dispose();
    end
    self.m_disposeObjs = nil;
  end

  self.m_destroyed = true;

  if not self.m_rootDestroying then
    CS.UnityEngine.GameObject.Destroy(self.m_root);
  end

end



function UIBase:TransCoroutine(inOrOut)
    if self.m_playingTransEffect then
        return nil;
    end
    self.m_playingTransEffect = true;
    if inOrOut then
        self.m_layout:PlayTransInEffect();
    else
        self.m_layout:PlayTransOutEffect();
    end
    return self:StartCoroutine(function()
        while self.m_playingTransEffect do
            coroutine.yield();
        end
    end);
end

function UIBase:TransImmediatly(inOrOut)
    if inOrOut then
        self.m_layout:ShowImmediatly();
    else
        self.m_layout:HideImmediatly();
    end
end

function UIBase:SetVisible(v)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self.m_root, v)
end

function UIBase:IsVisible()
    return self.m_root.activeSelf;
end


function UIBase:OnInitialize()
end


function UIBase:OnDispose()
end


function UIBase:OnVisible(v)
end

function UIBase:RootGameObject()
    return self.m_root;
end


function UIBase:OnResume()
end


function UIBase:OnEnter()
end


function UIBase:OnExit()
end


function UIBase:OnTransInEnd()
    self.m_playingTransEffect = false;
end

function UIBase:OnTransOutEnd()
    self.m_playingTransEffect = false;
end

function UIBase:IsDestroy()
    return self.m_destroyed;
end




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
        if obj ~= nil then
            obj[delegateName] = nil;
        end
    end);
end


function UIBase:_AddToDoWhenClose(func)
    if not func then
        return;
    end
    if not self.m_doWhenClose then
        self.m_doWhenClose = {};
    end
    table.insert(self.m_doWhenClose, func);
end





function UIBase:_AddDisposableObj(obj)
    if not obj then
        return;
    end

    if not self.m_disposeObjs then
        self.m_disposeObjs = {};
    end
    table.insert(self.m_disposeObjs, obj);
end

function UIBase:_ReleaseDisposableObj(obj)
    if not obj then
        return;
    end

    obj:Dispose();
    if not self.m_disposeObjs then
        return;
    end
    for idx, aObj in ipairs(self.m_disposeObjs) do
        if aObj == obj then
            table.remove(self.m_disposeObjs, idx);
            return;
        end
    end
end


function UIBase:Delay(delay, func, ...)
    local timer = TimerModel.me:Delay(delay, Event.Create(self, func, ...));
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

function UIBase:NextFrame(func, ...)
    local timer = TimerModel.me:NextFrame(Event.Create(self, func, ...));
    self:_RecordTimer(timer);
    return timer;
end

function UIBase:SetScaled(timerID)
    TimerModel.me:SetScaled(timerID);
end

function UIBase:DestroyTimer(timer)
    if self.m_allTimer then
        self.m_allTimer:Release(timer);
    end
end


function UIBase:_RecordTimer(timer)
    if not self.m_allTimer then
        self.m_allTimer = ReleaseCollection.Build(
            function(timer)
                return not TimerModel.me:Alive(timer);
            end,
            function(timer)
                TimerModel.me:Destroy(timer);
            end
        );
    end
    self.m_allTimer:Collect(timer);
end

function UIBase:StartCoroutine(func, ...)
    if not self.m_coroutines then
        self.m_coroutines = ReleaseCollection.Build(
            function(co)
                return not co:IsAlive();
            end,
            function(co)
                CoroutineModel.me:StopCoroutine(co);
            end
        );
    end

    local co = CoroutineModel.me:StartCoroutine(func, self, ...);
    self.m_coroutines:Collect(co);
    return co;
end

function UIBase:StopCoroutine(co)
    if not self.m_coroutines then
        return;
    end
    self.m_coroutines:Release(co);
end


function UIBase:PlayTween(config)
    if not self.m_tweens then
        self.m_tweens = ReleaseCollection.Build(
            function(tween)
                return not tween:IsAlive();
            end,
            function(tween)
                tween:Kill(false);
            end
        );
    end
    
    local tweenItem = TweenModel:Play(config);
    self.m_tweens:Collect(tweenItem);
    return tweenItem;
end


function UIBase:KillTween(tweenItem)
    if not self.m_tweens then
        return;
    end
    self.m_tweens:Release(tweenItem);
end


function UIBase:OpenPage(pageName, openType, options)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, openType, options)
end





function UIBase:OpenPage1(pageName)
    CS.Torappu.UI.UIPageController.OpenPage(pageName)
end




function UIBase:OpenPage2(pageName, openType)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, openType)
end




function UIBase:OpenPage3(pageName, options)
    CS.Torappu.UI.UIPageController.OpenPage(pageName, options)
end






function UIBase:CreateCustomComponent(comCls, ...)
    if not self.m_allCustomComponents then
        self.m_allCustomComponents = {};
    end
    local com = comCls.new();
    com:Initialize(...);
    table.insert(self.m_allCustomComponents, com);
    return com;
end


function UIBase:OnEnable()
    self:OnVisible(true);
end


function UIBase:OnDisable()
    self:OnVisible(false);
end


function UIBase:OnDestroy()
    self.m_rootDestroying = true;
    self:Dispose();
end




function UIBase:LoadSpriteFromAutoPackHub(hubPath, spriteName)
    return self.m_parent:LoadSpriteFromAutoPackHub(hubPath, spriteName);
end


function UIBase:LoadPrefab(path)
    return self.m_parent:LoadPrefab(path);
end