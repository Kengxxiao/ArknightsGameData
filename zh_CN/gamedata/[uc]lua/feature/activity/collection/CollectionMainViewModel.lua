


local CollectionMainViewModel = Class("CollectionMainViewModel", UIViewModel)
local CollectionSimpleMainViewModel = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleMainViewModel")


function CollectionMainViewModel:LoadData(actId)
  if actId == nil then
    return
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(actId)
  if not suc or actData.consts == nil then
    return
  end
  local constData = actData.consts
  self.isSimpleMode = constData.isSimpleMode

  if self.isSimpleMode then
    self:_LoadSimpleModeData(actId)
  end

  self:UpdateData(actId)
end


function CollectionMainViewModel:_LoadSimpleModeData(actId)
  if self.simpleMainModel == nil then
    self.simpleMainModel = CollectionSimpleMainViewModel.new()
  end
  self.simpleMainModel:LoadData(actId)
end


function CollectionMainViewModel:UpdateData(actId)
  if actId == nil then
    return
  end

  if self.isSimpleMode then
    self:_UpdateSimpleModeData(actId)
  end
end


function CollectionMainViewModel:_UpdateSimpleModeData(actId)
  if self.simpleMainModel ~= nil then
    self.simpleMainModel:UpdateData(actId)
  end
end

return CollectionMainViewModel