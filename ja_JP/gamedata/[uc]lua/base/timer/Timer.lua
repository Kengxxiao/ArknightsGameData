






Timer = Class("Timer");
Timer.s_ID = 0;

function Timer:Reset(interval, loop, call)
  Timer.s_ID = Timer.s_ID + 1;
  self.m_id = Timer.s_ID;
  self.m_interval = interval;
  self.m_scaled = false;
  self.m_loop = loop;
  self.m_call = call;

  self.m_waitTime = self.m_interval;
end

function Timer:ID()
  return self.m_id;
end

function Timer:Alive()
  return self.m_loop ~= 0;
end

function Timer:SetScaled()
  self.m_scaled = true;
end

function Timer:Kill()
  self.m_loop = 0;
  self.m_call = nil;
end

function Timer:Update(unscaledDeltaTime, deltaTime)
  local passTime = unscaledDeltaTime;
  if self.m_scaled then
    passTime = deltaTime;
  end
  self.m_waitTime = math.max(0, self.m_waitTime - passTime);
  if self.m_waitTime > 0 then
    return;
  end

  if self.m_loop > 0 then
    self.m_loop = self.m_loop -1;
  end
  self.m_call:Call();
  self.m_waitTime = self.m_interval;
end