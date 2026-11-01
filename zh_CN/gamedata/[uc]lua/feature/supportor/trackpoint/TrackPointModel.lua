

TrackPointModel = ModelMgr.DefineModel("TrackPointModel");
TrackPointModel.s_trackPoints = {}

function TrackPointModel:UpdateNode(trackType)
  local node = self:_FindNode(trackType);
  if not node then
    LogWarning("Undefined track type:".. trackType.__cname);
    return;
  end
  return node:_Update();
end



function TrackPointModel:BindUI(trackType, trackPoint)
  local node = self:_FindNode(trackType);
  if node then
    node:_BindUI(trackPoint);
  end
end

function TrackPointModel:UnbindUI(trackType)
  local node = self:_FindNode(trackType);
  if node then
    node:_BindUI(nil);
  end
end

function TrackPointModel:IsShow(trackType)
  local node = self:_FindNode(trackType);
  if node then
    return node:IsShow();
  end
  return false;
end



function TrackPointModel.GetTrackPointType(name)
  local node = TrackPointModel.s_trackPoints[name];
  if node ~= nil then
    return node.class;
  end
  return nil;
end



function TrackPointModel:UpdateSubTree(trackType)
  local node = self:_FindNode(trackType);
  if node == nil then
    return;
  end
  self:_UpdateSubTree(node);
end



function TrackPointModel:_FindNode(trackType)
  return TrackPointModel.s_trackPoints[trackType.__cname];
end



function TrackPointModel:_UpdateSubTree(node)
  if node == nil then
    return;
  end
  node:_Update();
  if node.m_children == nil then
    return;
  end
  for _, child in ipairs(node.m_children) do
    self:_UpdateSubTree(child);
  end
end




function TrackPointModel.DefineTrackPoint(name, parentNodeType)
  local trackDic = TrackPointModel.s_trackPoints;
  if trackDic[name] ~= nil then
    
    LogWarning("Dumplication track point type:"..name);
    return;
  end

  local nodeClass = Class(name, TrackPointNode);
  local parentNode = nil;
  if parentNodeType then
    parentNode = trackDic[parentNodeType.__cname];
    if not parentNode then
      
      LogWarning("Bad parent node type, can't find it in manager:"..name);
      return;
    end
  end

  local node = nodeClass.new();
  trackDic[nodeClass.__cname] = node;
  if parentNode then
    parentNode:_AddChild(node);
  end
  return nodeClass; 
end




function TrackPointModel.DefineTrackPointWithCheckFunc(name, parentNodeType, checkFunc)
  local nodeClass = TrackPointModel.DefineTrackPoint(name, parentNodeType);
  if nodeClass == nil then
    return nil;
  end
  function nodeClass:OnCheckStatus()
    return self.m_checkFunc ~= nil and self.m_checkFunc(self) == true;
  end
  local node = TrackPointModel.s_trackPoints[nodeClass.__cname];
  if node ~= nil then
    node.m_checkFunc = checkFunc;
  end
  return nodeClass;
end
