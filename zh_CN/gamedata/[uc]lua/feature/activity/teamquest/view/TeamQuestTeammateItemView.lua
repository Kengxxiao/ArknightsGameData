local luaUtils = CS.Torappu.Lua.Util





















local TeamQuestTeammateItemView = Class("TeamQuestTeammateItemView", UIWidget)

function TeamQuestTeammateItemView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  local avatarPrefab = CS.Torappu.UI.PlayerAvatarUtil.GetAvatarViewPrefab()
  if avatarPrefab ~= nil then 
    self.m_avatarView = CS.UnityEngine.GameObject.Instantiate(avatarPrefab, self._avatarContainer)
  end

  self:AddButtonClickListener(self._btnRevertQuit, function()
    if self.onBtnRevertQuitClick == nil then
      return
    end
    self.onBtnRevertQuitClick:Call()
  end)

  self:AddButtonClickListener(self._btnDetail, function ()
    if self.onBtnDetailClick == nil or self.m_mateModel == nil then
      return
    end
    self.onBtnDetailClick:Call(self.m_mateModel.uid, self._btnDetailTrans.position)
  end)

  self:AddButtonClickListener(self._btnAddMate, function()
    if self.onBtnInviteFriendClick == nil then
      return
    end
    self.onBtnInviteFriendClick:Call()
  end)
end



function TeamQuestTeammateItemView:Render(mateModel, mainModel)
  self.m_mateModel = mateModel

  self:_InitIfNot()
  local isEmpty = mateModel == nil
  SetGameObjectActive(self._matePartGO, not isEmpty)
  SetGameObjectActive(self._emptyPartGO, isEmpty)
  if isEmpty then
    return
  end

  if mainModel == nil then
    return
  end

  local isMine = mainModel.myUid == mateModel.uid
  SetGameObjectActive(self._btnDetailGO, not isMine)
  SetGameObjectActive(self._btnRevertQuitGO, isMine and mainModel:HasPendingLeave())
  SetGameObjectActive(self._selfImg.gameObject, isMine)

  local colorTheme = luaUtils.FormatColorFromData(mainModel.themeColor)
  luaUtils.SetColorWithoutAlpha(self._selfImg, colorTheme)

  self._textName.text = luaUtils.Format("{0}#{1}", mateModel.nickName, mateModel.nickNumber)
  self._textId.text = tostring(mateModel.uid)
  self._textLv.text = tostring(mateModel.level)
  
  local avatarInfo = nil
  if self.m_avatarView ~= nil and mateModel.avatarType ~= nil and mateModel.avatarId ~= nil then
    avatarInfo = luaUtils.CreateAvatarInfo(mateModel.avatarType, mateModel.avatarId)
  end
  self.m_avatarView:Render(avatarInfo)

  local nameCardStyle = self:_LoadNameCardStyle(mateModel.skinId, mateModel.skinTmpl)
  local bgNameCard = nil
  if nameCardStyle ~= nil then
    bgNameCard = nameCardStyle.shortBg
  end
  self._imgBg.sprite = bgNameCard
end



function TeamQuestTeammateItemView:_LoadNameCardStyle(skinId, skinTmpl)
  if skinId == nil or skinTmpl == nil then
    return nil
  end

  return CS.Torappu.DataConvertUtil.LoadNameCardV2SkinStyleAndApplyTmpl(skinId, skinTmpl, nil)
end

return TeamQuestTeammateItemView