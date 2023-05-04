








TimerModel = ModelMgr.DefineModel("TimerModel");

function TimerModel:OnInit()
  self._timers = {};
  self._newborn = {};
  self._dead = {};
  self._alives = {};
end

function TimerModel:OnDispose()
  for index, timer in ipairs(self._timers) do
    timer:Kill();
    table.insert(self._dead, timer);
  end

  self._timers = nil;
  self._newborn = nil;
  self._dead = nil;
  self._alives = nil;
end



function TimerModel:BindSwitcher(switcher)
  self._switcher = switcher;
end




function TimerModel:Delay(delay, cb)
  return self:_SetTimer(delay, 1, cb);
end





function TimerModel:Interval(interval, loop, cb)
  return self:_SetTimer(interval, loop, cb);
end




function TimerModel:Frame(loop, cb)
  return self:_SetTimer(0, loop, cb);
end



function TimerModel:NextFrame(cb)
  return self:_SetTimer(0, 1, cb);
end



function TimerModel:Destroy(timerID)
  local timer = self._alives[timerID];
  if timer then
    timer:Kill();
  end
end



function TimerModel:Alive(timerID)
  local timer = self._alives[timerID];
  return timer and timer:Alive();
end

function TimerModel:SetScaled(timerID)
  local timer = self._alives[timerID];
  timer:SetScaled();
end


function TimerModel:_SetTimer(interval, loop, evt)
  
  local newTimer = nil;
  if #self._dead > 0 then
    newTimer = table.remove(self._dead);
  else
    newTimer = Timer.new();
  end
  newTimer:Reset(interval, loop, evt);
  table.insert(self._newborn, newTimer);
  self._alives[newTimer:ID()] = newTimer;
  if self._switcher and #self._timers <= 0 then
    self._switcher:Call(true);
  end
  return newTimer:ID();
end


function TimerModel:Update(unscaledDeltaTime, deltaTime)
  
  local pos = 1;
  for idx = 1, #self._timers do
    local timer = self._timers[idx];
    if timer:Alive() then
      timer:Update(unscaledDeltaTime, deltaTime);
      self._timers[pos] = timer;
      pos = pos + 1;
    else
      table.insert(self._dead, timer);
      self._alives[timer:ID()] = nil;
    end
  end

  for idx = pos, #self._timers do
    table.remove(self._timers);
  end

  
  if #self._newborn > 0 then
    for _, new in ipairs(self._newborn) do
      table.insert(self._timers, new);
    end
    self._newborn = {};
  end

  if self._switcher and #self._timers <= 0 then
    self._switcher:Call(false);
  end
end