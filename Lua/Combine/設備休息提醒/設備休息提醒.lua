--[[
%% properties
723 value
%% globals
restWarning
--]]

--[[
  @author Lala
  @date   105.02.17
  @brief  設備或VD開啟超過指定時間，手機會發出通知給使用者詢問是否休息
  @note
    1. 需搭配"用電休息提醒Yes"情境使用
    2. 填寫設備名稱、提醒時間、SceneId
    3. 可用於Relay、Dimmer、RGBW、VD，用於VD時需搭配Global value
--]]


local deviceName = "書房燈"  --設備名稱
local waringTime = 1  --使用超過多久發出提醒(分鐘)

local selfId = 93     --本SceneId
local sceneYes = 94   --"Yes"按鍵觸發之情境Id

local imgUrl = ""     --通知訊息圖片連結位址

--__--__--__--__--
local tTrigger = fibaro:getSourceTrigger()


function TurnOn()
  print("device turnOn")
  setTimeout(Warning, waringTime * 60 * 1000)    
end


function TurnOff()
  print("device turnOff")
  fibaro:killScenes(selfId)

end


function Warning()
  HomeCenter.PopupService.publish
  (
    {
      title = "設備休息提醒",
      subtitle = os.date("%I:%M:$S %p | %B %d %Y"),
      contentTitle = "您已使用 " .. deviceName .. " 超過 " .. waringTime .. " 分鐘",
      contentBody = "是否關閉設備？",
  
      img = imgUrl,
	
	  type = "Success",
	
   	  buttons = 
 	  {
	    { caption = "是", sceneId = sceneYes },
	    { caption = "稍後提醒", sceneId = selfId },
	    { caption = "取消", sceneId = 0 }		
	  }
  
    }
  )
end

print("start")

if (tTrigger.type == "global") then   --virtual device
  if (fibaro:getGlobal(tTrigger.name) == "on" ) then  --開
    TurnOn()
  else --關
    TurnOff()
  end
elseif (tTrigger.type == "property") then    --physical device
  if (tonumber(fibaro:getValue(tTrigger.deviceID, "value")) > 0 ) then --開
    TurnOn()
  else --關
    TurnOff()	
  end  
elseif (tTrigger.type == "other") then   --later
  TurnOn()
end


