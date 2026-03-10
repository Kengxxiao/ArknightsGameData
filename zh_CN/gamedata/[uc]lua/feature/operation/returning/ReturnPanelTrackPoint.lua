
ReturnCheckInTrackPoint = TrackPointModel.DefineTrackPoint("ReturnCheckInTrackPoint");

function ReturnCheckInTrackPoint:OnCheckStatus()
  return ReturnModel.me:CheckIfHasCheckInReward();
end


ReturnMissionTrackPoint = TrackPointModel.DefineTrackPoint("ReturnMissionTrackPoint");

function ReturnMissionTrackPoint:OnCheckStatus()
  return ReturnModel.me:CheckIfHasMissionReward();
end


ReturnNewsTrackPoint = TrackPointModel.DefineTrackPoint("ReturnNewsTrackPoint");

function ReturnNewsTrackPoint:OnCheckStatus()
  return ReturnModel.me:CheckTabNewsLocalTrack();
end


ReturnPackageTrackPoint = TrackPointModel.DefineTrackPoint("ReturnPackageTrackPoint");

function ReturnPackageTrackPoint:OnCheckStatus()
  return ReturnModel.me:CheckTabPackageLocalTrack();
end


ReturnSpecialOpenTrackPoint = TrackPointModel.DefineTrackPoint("ReturnSpecialOpenTrackPoint");

function ReturnSpecialOpenTrackPoint:OnCheckStatus()
  return ReturnModel.me:CheckTabSpecialOpenLocalTrack();
end