--[[
%% properties

%% globals
EH_City1
EH_City2
EH_City3
EH_City4
EH_City5
--]]

--[[
  @author Lala
  @date   105.2.4
  @brief  天氣情境之日落效果
  @note   填寫global trigger及下列參數
          VD需填寫完畢並取得資料才能正常執行本情境
--]]

local virtualDeviceId = 689       --Virtual Device Id
local sunsetColor = { 5, 5, 25 }  --日落固定顏色
local cityAmount = 5              --city數量   

--_--_--_--_--
local tTirgger = fibaro:getSourceTrigger()     --取得trigger
local triggerName = tTirgger['name']           --取得trigger name
local citySun = fibaro:getGlobal(triggerName)  --取得trigger 值

local currentTime = os.time()

function Sunseting(_lightId)

  lightValue = fibaro:getValue(_lightId, "value")
  lightStep = (lightValue - 10)/5
  
  for i = 1, 5 do
 --   print("step " .. i)
	lightValue = math.floor(lightValue - lightStep)
	fibaro:call(_lightId, "setValue", lightValue)
    fibaro:sleep(12000)
  end
  setR = sunsetColor[1]
  setG = sunsetColor[2]
  setB = sunsetColor[3]  
  fibaro:call(_lightId, "setColor", setR, setG, setB, "0" )
  
end

-----------------------------以下開始
print("start")



if (citySun == "set") then
  print("日落，執行日落效果")
  print("now: " .. currentTime)
  for i = 1, cityAmount do
    if (triggerName == "EH_City" .. i) then  --判斷城市編號
      city = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "a.value")         --取得城市名稱、LighId
      lightId = string.match(city, "，(.+)")
	  print("日落城市為 City ".. i .. " ，lightId為 " .. lightId)
	  
	  condition = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "b.value")    --取得天氣狀況  
      tCondition = json.decode(condition) 
	  sunrise = tCondition.sunrise
	  sunset = tCondition.sunset
	  
	  print("sunrise: " .. sunrise)
	  print("sunset : " .. sunset)
	  
	  
      Sunseting(lightId)
	end
    
  end
elseif (citySun == "rise") then
  print("日出，僅記錄log")
  print("now: " .. currentTime)
  for i = 1, cityAmount do
    if (triggerName == "EH_City" .. i) then  --判斷城市編號
      city = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "a.value")         --取得城市名稱、LighId
      lightId = string.match(city, "，(.+)")
	  print("日出城市為 City ".. i .. " ，lightId為 " .. lightId)
	  
	  condition = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "b.value")    --取得天氣狀況  
      tCondition = json.decode(condition) 
	  sunrise = tCondition.sunrise
	  sunset = tCondition.sunset
	  
	  print("sunrise: " .. sunrise)
	  print("sunset : " .. sunset)
    end
  end	
end

print("finish")