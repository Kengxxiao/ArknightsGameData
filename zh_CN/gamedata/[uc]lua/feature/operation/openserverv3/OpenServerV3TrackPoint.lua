
OpenServerV3TrackPoint = TrackPointModel.DefineTrackPoint("OpenServerV3TrackPoint");


OpenServerV3CheckInTrackPoint = TrackPointModel.DefineTrackPoint("OpenServerV3CheckInTrackPoint",
    OpenServerV3TrackPoint);

function OpenServerV3CheckInTrackPoint:OnCheckStatus()
  return OpenServerV3Model.me:CheckIfHasCheckInReward();
end


OpenServerV3MissionTabTrackPoint = TrackPointModel.DefineTrackPoint("OpenServerV3MissionTabTrackPoint",
    OpenServerV3TrackPoint);

function OpenServerV3MissionTabTrackPoint:OnCheckStatus()
  return OpenServerV3Model.me:CheckIfHasMissionReward() or OpenServerV3Model.me:CheckIfHasMilestoneReward();
end


OpenServerV3MissionTaskTrackPoint = TrackPointModel.DefineTrackPoint("OpenServerV3MissionTaskTrackPoint",
    OpenServerV3MissionTabTrackPoint);

function OpenServerV3MissionTaskTrackPoint:OnCheckStatus()
  return OpenServerV3Model.me:CheckIfHasMissionReward();
end


OpenServerV3MilestoneTrackPoint = TrackPointModel.DefineTrackPoint("OpenServerV3MilestoneTrackPoint",
    OpenServerV3MissionTabTrackPoint);

function OpenServerV3MilestoneTrackPoint:OnCheckStatus()
  return OpenServerV3Model.me:CheckIfHasMilestoneReward();
end

local MISSION_STAGE_TRACK_POINT_NAME_FORMAT = "OpenServerV3MissionStageTrackPoint_%s";


OpenServerV3TrackPointUtil = Class("OpenServerV3TrackPointUtil", nil);



local function _GetMissionStageTrackPointName(groupId)
  return string.format(MISSION_STAGE_TRACK_POINT_NAME_FORMAT, groupId);
end



function OpenServerV3TrackPointUtil.DefineMissionStageTrackPoint(groupId)
  if groupId == nil or groupId == "" then
    return nil;
  end
  local name = _GetMissionStageTrackPointName(groupId);
  local trackType = TrackPointModel.GetTrackPointType(name);
  if trackType ~= nil then
    return trackType;
  end
  return TrackPointModel.DefineTrackPointWithCheckFunc(name, OpenServerV3MissionTaskTrackPoint, function()
    local missionIds = OpenServerV3Model.me:GetClaimableMissionIdsInGroup(groupId);
    return missionIds ~= nil and #missionIds > 0;
  end);
end
