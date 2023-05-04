

CoroutineItem = Class("CoroutineItem")
function CoroutineItem:ctor(nativeCo)
  self.m_coroutine = nativeCo;
end

function CoroutineItem:IsAlive()
  return coroutine.status(self.m_coroutine) ~= "dead";
end






CoroutineModel = ModelMgr.DefineModel("CoroutineModel");



function CoroutineModel:StartCoroutine(func, callee, ...)
  local params = {callee, ...};
  local co = coroutine.create(func);
  local item = CoroutineItem.new(co);

  local suc, error = coroutine.resume(co, table.unpack(params));
  if not suc then
    CS.Torappu.Lua.Util.LogError(error);
  end

  if not item:IsAlive() then
    return item;
  end

  if not self.m_coroutines then
    self.m_coroutines = {};
  end
  table.insert(self.m_coroutines, item);
  if not self.m_driveTimer then
    self.m_driveTimer = TimerModel.me:Frame(-1, Event.Create(self, self._DriveCoroutine));
  end
  return item;
end


function CoroutineModel:StopCoroutine(co)
  if not co or not self.m_coroutines then
    return;
  end
  for idx, aCo in ipairs(self.m_coroutines) do
    if aCo == co then
      table.remove(self.m_coroutines, idx);
      return;
    end
  end
end


function CoroutineModel:_DriveCoroutine()
  if self.m_coroutines == nil or #self.m_coroutines <= 0 then
    TimerModel.me:Destroy(self.m_driveTimer);
    self.m_driveTimer = nil;
    return;
  end

  local aliveCo = 0;
  for idx, aCo in ipairs(self.m_coroutines) do
    if aCo and aCo:IsAlive() then
      coroutine.resume(aCo.m_coroutine);
      aliveCo = aliveCo + 1;
    end
  end

  if aliveCo <= 0 then
    self.m_coroutines = nil;
  end
end