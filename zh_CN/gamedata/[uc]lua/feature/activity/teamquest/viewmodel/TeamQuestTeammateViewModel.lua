









local TeamQuestTeammateViewModel = Class("TeamQuestTeammateViewModel", nil)



function TeamQuestTeammateViewModel:LoadData(mateInfo, friendStatus)
  if mateInfo == nil or friendStatus == nil then
    return
  end

  self.friendStatus = friendStatus

  self.nickName = mateInfo.nickName
  self.uid = mateInfo.uid
  self.nickNumber = mateInfo.nickNumber
  self.level = mateInfo.level

  if mateInfo.skin ~= nil then
    local skinId = mateInfo.skin.selected
    self.skinId = skinId
    local tmpl = mateInfo.skin.tmpl[skinId]
    self.skinTmpl = tmpl ~= nil and tmpl or 0
  end

  if mateInfo.avatar ~= nil then
    self.avatarType = mateInfo.avatar.type
    self.avatarId = mateInfo.avatar.id
  end
end

return TeamQuestTeammateViewModel