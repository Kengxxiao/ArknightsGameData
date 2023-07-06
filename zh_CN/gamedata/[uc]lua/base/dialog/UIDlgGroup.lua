



UIDlgGroup = Class("UIDlgGroup")


function UIDlgGroup:ctor(parentDlg)
  self.m_owner = parentDlg;
end

function UIDlgGroup:Clear()
  if self.m_childDlgs then
    for _, child in ipairs(self.m_childDlgs) do
      child:ClosedByParent();
    end
    self.m_childDlgs = nil;
  end
  CoroutineModel.me:StopCoroutine(self.m_coroutine);
end


function UIDlgGroup:InitList(dlgClsList)
  for idx, dlgCls in ipairs(dlgClsList) do
    if idx == #dlgClsList then
      self:AddChildDlg(dlgCls);
    else
      local child = self:AddChildDlgImmediatly(dlgCls);
      if child ~= nil then
        child:SetVisible(false);
      end
    end
  end
end


function UIDlgGroup:AddChildDlgImmediatly(dlgCls)
  if self:_CheckTransitting() then
    return nil;
  end
  local newAdd, preDlg = self:_HandleAdd(dlgCls);
  newAdd:TransImmediatly(true);
  if preDlg then
    preDlg:SetVisible(false);
  end
  return newAdd;
end

function UIDlgGroup:AddChildDlg(dlgCls)
  if self:_CheckTransitting() then
    return nil;
  end

  local child, preDlg = self:_HandleAdd(dlgCls);
  self.m_coroutine = CoroutineModel.me:StartCoroutine(self._TransTo, self, preDlg, child);
  return child;
end


function UIDlgGroup:_HandleAdd(dlgCls)
  if not self.m_childDlgs then
    self.m_childDlgs = {};
  end

  local child = DlgMgr.CreateDlg(dlgCls, self.m_owner);
  local preDlg = self.m_childDlgs[#self.m_childDlgs];
  table.insert(self.m_childDlgs, child);
  return child, preDlg
end

function UIDlgGroup:GetChildDlg(dlgCls)
  if not self.m_childDlgs then
    return nil;
  end
  for _, child in ipairs(self.m_childDlgs) do
    if child.class == dlgCls then
      return child;
    end
  end
  return nil;
end



function UIDlgGroup:RemoveChild(child)
  if self:_CheckTransitting() then
    return;
  end

  if self.m_childDlgs == nil then
    return false;
  end

  for idx = #self.m_childDlgs, 1, -1 do
    local achild = self.m_childDlgs[idx];
    if achild == child then
      
      local closeOwner = #self.m_childDlgs <= 1 and self.m_owner:IsPureGroup();
      if closeOwner then
        self.m_owner:Close();
        return true;
      end

      local isTop = idx == #self.m_childDlgs;
      table.remove(self.m_childDlgs, idx);
      if isTop then
        local curTop = self.m_childDlgs[#self.m_childDlgs];
        self.m_coroutine = CoroutineModel.me:StartCoroutine(self._CloseTo, self, achild, curTop);
      else
        child:ClosedByParent();
      end
      return true;
    end
  end
  return false;
end

function UIDlgGroup:SwitchChildDlg(dlgCls)
  if self:_CheckTransitting() then
    return nil;
  end

  
  if self.m_childDlgs == nil then
    return nil
  end
  local prevIdx = #self.m_childDlgs
  local prevDlg = self.m_childDlgs[prevIdx]
  if prevDlg == nil then
    return nil
  end

  table.remove(self.m_childDlgs, prevIdx)
  local newDlg = self:_HandleAdd(dlgCls)

  self.m_coroutine = CoroutineModel.me:StartCoroutine(self._SwitchTo, self, prevDlg, newDlg);
  return newDlg
end

function UIDlgGroup:GetTopDlg()
  if not self.m_childDlgs then
    return nil;
  end
  local lastIdx = #self.m_childDlgs
  return self.m_childDlgs[lastIdx]
end

function UIDlgGroup:_CheckTransitting()
  local trans = self:IsTransitting();
  if trans then
    CS.Torappu.Lua.Util.LogWarning("Dialog group is transitting..." );
  end
  return trans;
end

function UIDlgGroup:IsTransitting()
  return self.m_coroutine and self.m_coroutine:IsAlive();
end



function UIDlgGroup:_TransTo(from, to)
  
  if to then
    to:SetVisible(true);
    local transTo = to:TransCoroutine(true);
    while transTo and transTo:IsAlive() do
      print("transing in")
      coroutine.yield();
    end
  end

  
  if from then
    from:SetVisible(false);
  end
end



function UIDlgGroup:_CloseTo(closeDlg, newTopDlg )
  
  if newTopDlg then
    newTopDlg:SetVisible(true);
  end
  
  local transOut = closeDlg:TransCoroutine(false);
  while transOut and transOut:IsAlive() do
    coroutine.yield();
  end
  
  closeDlg:ClosedByParent();
end



function UIDlgGroup:_SwitchTo(closeDlg, newTopDlg)
  local closeCoroutine = nil
  if closeDlg ~= nil then
    closeCoroutine = closeDlg:TransCoroutine(false)
  end

  local openCoroutine = nil
  if newTopDlg ~= nil then
    newTopDlg:SetVisible(true)
    openCoroutine = newTopDlg:TransCoroutine(true)
  end

  while closeCoroutine and closeCoroutine:IsAlive() do
    coroutine.yield()
  end
  closeDlg:ClosedByParent()

  while openCoroutine and openCoroutine:IsAlive() do
    coroutine.yield()
  end
end