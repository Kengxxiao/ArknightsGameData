local eutil = CS.Torappu.Lua.Util













TweenItem = Class("TweenItem")

TweenItem.DEFAULT_DUR = 0.1

function TweenItem:ctor(duration, delay, watch)
  self.m_watch = watch;
  self.m_startTick = self.m_watch.GetCurrentTime();
  if delay ~= nil and delay ~= 0 then
    self.m_startTick = self.m_startTick + self.m_watch.ConvertTimeUnit(delay);
  end
  if duration == nil or duration == 0 then
    duration = TweenItem.DEFAULT_DUR
  end
  self.m_endTick = self.m_startTick + self.m_watch.ConvertTimeUnit(duration);
end

function TweenItem:IsAlive()
  local coroutine = self.m_coroutine
  return coroutine ~= nil and coroutine:IsAlive()
end

function TweenItem:Kill(invokeOnComplete)
  if not self:IsAlive() then
    return
  end
  CoroutineModel.me:StopCoroutine(self.m_coroutine)
  self.m_coroutine = nil

  if self.m_onComplete == nil then
  end

  if invokeOnComplete and self.m_onComplete ~= nil then
    self.m_onComplete()
  end
end

function TweenItem:_Coroutine()
  local isFinished = false
  local s = self.m_startTick
  local e = self.m_endTick
  local ease = self.m_easeFunc
  local setter = self.m_setFunc

  while not isFinished do
    local curTick = self.m_watch.GetCurrentTime();

    if curTick >= s then 
      local k = (curTick - s) / (e - s) 
      if k < 0 then
        k = 0
      elseif k > 1 then
        k = 1
      end
      local lerp = k
      if ease ~= nil then
        lerp = ease(lerp)
      end
      if setter ~= nil then
        setter(lerp)
      end
    end

    isFinished = curTick >= e
    coroutine.yield()
  end

  self:Kill(true) 
end



TweenModel = ModelMgr.DefineModel("TweenModel")




function TweenModel:Play(config)
  local watch = TweenModel.Watches.TickWatch;
  if config.timeScaled then
    watch = TweenModel.Watches.TimeWatch;
  end
  local tween = TweenItem.new(config.duration, config.delay, watch)
  tween.m_easeFunc = config.easeFunc
  tween.m_setFunc = config.setFunc
  tween.m_onComplete = config.onComplete
  tween.m_coroutine = CoroutineModel.me:StartCoroutine(tween._Coroutine, tween)
  return tween
end

TweenModel.Watches = {};

TweenModel.Watches.TickWatch = 
{
  GetCurrentTime = function()
    return eutil.GetCurrentTicks();
  end,
  ConvertTimeUnit = function(timeSec)
    return timeSec * 1000 * 10000;
  end,
};

TweenModel.Watches.TimeWatch = 
{
  GetCurrentTime = function()
    return CS.UnityEngine.Time.time;
  end,
  ConvertTimeUnit = function(timeSec)
    return timeSec;
  end,
};

TweenModel.EaseFunc = {};
TweenModel.EaseFunc.easeOutQuad =  function(x)
  return 1 - (1 - x) * (1 - x);
end
TweenModel.EaseFunc.easeOutQuart = function(x)
  return 1 - (1 - x) * (1 - x) * (1 - x) * (1 - x)
end


Readonly(TweenModel.EaseFunc);