







TrackPointNode = Class("TrackPointNode");

function TrackPointNode:IsShow()
  return self.m_status == true;
end


function TrackPointNode:_BindUI(trackPoint)
  self.m_uiNode = trackPoint;

  if self.m_uiNode then
    self:_Update();
  end
end

function TrackPointNode:_AddChild(child)
  if not self.m_children then
    self.m_children = {}
  end
  table.insert(self.m_children, child);
  child.m_parent = self;
end

function TrackPointNode:_Update()
  self.m_status = self:_CalculateStatus();
  if self.m_uiNode and not self.m_uiNode:IsDestroyed() then
    self.m_uiNode:OnStateChanged(self);
  end
  return self.m_status;
end


function TrackPointNode:_CalculateStatus()
  if self.m_children then
    for _, child in ipairs(self.m_children) do
      local childShow = child:_CalculateStatus();
      if childShow then
        return true;
      end
    end
  end
  return self:OnCheckStatus();
end


function TrackPointNode:OnCheckStatus()
  return false;
end
