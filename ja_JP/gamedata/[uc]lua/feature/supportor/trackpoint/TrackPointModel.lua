

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



function TrackPointModel:_FindNode(trackType)
  return TrackPointModel.s_trackPoints[trackType.__cname];
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