local DynamicMusicCompInfoHotfixer = Class("DynamicMusicCompInfoHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
 
local function LoadDataFix(self, archiveId)
  self:LoadData(archiveId);
  
  if not self:IsValid() or archiveId ~= "act17side" then
    return;
  end

  local model = self.music.Value;
  if model.homeMusicId == nil or model.homeMusicId == "" then
    
    local musicConfig = CS.Torappu.UI.ActArchiveMusicConfig("act17side");
    local suc, gameMusicId = CS.Torappu.UI.UIMusicConfigCache.instance:TryGetMusicId(musicConfig);
    if not suc then
      local defaultEventName = musicConfig:DefaultAudioEventName();
      local defaultGameMusicData = CS.Torappu.MusicDataUtil.GetMusicByEventName(defaultEventName);
      if defaultGameMusicData == nil then
        gameMusicId = "";
      else
        gameMusicId = defaultGameMusicData.id;
      end
    end
    
    if gameMusicId == nil or gameMusicId == "" then
      return;
    end

    for key, value in pairs(model.musicItems) do
      if value.musicItemData.desc == gameMusicId then
        model.homeMusicId = key;
      end
    end
  end
end
 
function DynamicMusicCompInfoHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.ActArchive.DynamicMusicCompInfo)

  self:Fix_ex(CS.Torappu.UI.ActArchive.DynamicMusicCompInfo, "LoadData", function(self, archiveId)
    local ok, errorInfo = xpcall(LoadDataFix, debug.traceback, self, archiveId)
    if not ok then
      eutil.LogError("[DynamicMusicCompInfoHotfixer] fix" .. errorInfo)
    end
  end)
end
 
function DynamicMusicCompInfoHotfixer:OnDispose()
end
 
return DynamicMusicCompInfoHotfixer