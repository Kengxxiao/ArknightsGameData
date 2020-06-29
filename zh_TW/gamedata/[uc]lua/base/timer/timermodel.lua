---@class TimerModel:ModelBase
---@field me TimerModel
---@field private _switcher Event
---@field private _timers Timer[]
---@field private _newborn Timer[]
---@field private _dead Timer[]
---@field private _alives table<number, Timer>
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

---绑定驱动开关
---@param switcher Event 在需要开关帧驱动时触发 function(open:boolean) end
function TimerModel:BindSwitcher(switcher)
  self._switcher = switcher;
end

---延时执行
---@param delay number 延时时长s
---@param cb Event 执行内容
function TimerModel:Delay(delay, cb)
  return self:_SetTimer(delay, 1, cb);
end

---定时执行
---@param interval number 执行间隔s
---@param loop number 执行次数 <0 表示无限
---@param cb Event 执行内容
function TimerModel:Interval(interval, loop, cb)
  return self:_SetTimer(interval, loop, cb);
end

---每帧执行
---@param loop 执行次数
---@param cb Event 执行内容
function TimerModel:Frame(loop, cb)
  return self:_SetTimer(0, loop, cb);
end

---下帧执行一次
---@param cb Event 执行内容
function TimerModel:NextFrame(cb)
  return self:_SetTimer(0, 1, cb);
end

---销毁定时器
---@param timer number 定时器ID
function TimerModel:Destroy(timer)
  local timer = self._alives[timer];
  if timer then
    timer:Kill();
  end
end

---@private
function TimerModel:_SetTimer(interval, loop, evt)
  ---@type Timer
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

---@param deltaTime number
function TimerModel:Update(deltaTime)
  -- check
  local pos = 1;
  for idx = 1, #self._timers do
    local timer = self._timers[idx];
    if timer:Alive() then
      timer:Update(deltaTime);
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

  -- move all new born to timers
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