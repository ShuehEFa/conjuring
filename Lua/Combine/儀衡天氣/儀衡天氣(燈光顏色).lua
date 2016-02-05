--[[
%% properties
%% autostart
--]]

--[[
  @author Lala
  @date   105.2.4
  @brief  RGBW顯示天氣效果及氣溫顏色
  @note   14~40行 參數設定
          VD需填寫完畢並取得資料才能正常執行本情境
--]]


local virtualDeviceId = 689         --Virtual Device Id
local selfId = 87                   --本情境ID   
local sunsetSceneId = 88            --日落情境

local cityAmount = 5                --city數量
local gGlobal = "EH_City"           --global value命名，後面接數字(例：EH_City1)

local rgb0 = { 227, 233, 255 }      -- 0度RGB
local rgb25 = { 255, 209, 163 }     --25度RGB
local rgb45 = { 255, 137, 18 }      --45度RGB
local sunsetColor = { 5, 5, 25 }    --日落固定顏色

local programRain = 1               --雨天效果(RGB program)
local programSnow = 3               --下雪效果(RGB program)
local programThunderstorm = 2       --雷雨效果(RGB program)
local programOther = 5              --晴、雲、其他天氣效果(RGB program)

local intervalTime = 30             --此情境間隔時間(分)
local changeTime = 3*60*60          --日出至天完全亮的時間(秒)
local effectTime = 10               --天氣效果持續時間(秒)
local debugTime = 5                 --debug用，平常請設定為0(秒)

local soundCity = 5                 --播放此城市天氣音效
local rainButton = 14               --VD撥放音效Rain button
local snowButton = 15               --VD撥放音效Snow button
local rayButton = 16                --VD撥放音效Ray button
local otherButton = 17              --VD撥放音效Other button
local stopButton = 18               --停止音效button

--_--_--_--_--
local mCityName = {}
local mLightId = {}
local mWeather = {}
local mSunriseTime = {}
local mSunsetTime = {}
local mTemp = {}
local mSun = {}
local mCurrentTime = os.time()

---------------------------------------------------------
---------------------------------------------------------

function MainColor()

  for i = 1, cityAmount do 	
	if (mSun[i] == "set")  then
	  print("City " .. i .. " (" .. mCityName[i] .. ") 目前為夜間，固定顏色")     --此城市日落，不做事
      fibaro:call(mLightId[i], "setColor", sunsetColor[1], sunsetColor[2], sunsetColor[3], "0" )
	  
	elseif (mSun[i] == "rise") then
      print("City " .. i .. " (" .. mCityName[i] .. ") 目前為白天，開始調整顏色")
	  SetColor(mTemp[i], mSunriseTime[i], mLightId[i])       --改變城市燈光
    end
	
    fibaro:sleep(debugTime*1000)	
  end

end

function SetColor(_temp, _sunrise, _lightId)

  colorR, colorG, colorB = TempColor(_temp)
  valuePercent = SunColor(_sunrise)
  
  print("距離日出時間已經過了 " .. mCurrentTime - _sunrise .. " 秒")
  print("temp(目前溫度): " .. _temp .. " ， percent(亮度百分比): " .. valuePercent)
 -- print(_sunrise )
    
  setR = math.floor(colorR * valuePercent)
  setG = math.floor(colorG * valuePercent)
  setB = math.floor(colorB * valuePercent)
  print("setRGB: " .. setR .. ", " .. setG .. ", " .. setB)
  
  fibaro:call(_lightId, "setColor", setR, setG, setB, "0" )

end

function TempColor(_temp)  --根據溫度(temp)算出對應RGB
  if (_temp <= 0) then
    returnR = rgb0[1]
    returnG = rgb0[2]
    returnB = rgb0[3]
  elseif ((_temp > 0) and (_temp <= 25)) then
    spaceR = ( rgb25[1] - rgb0[1] )/25
    spaceG = ( rgb25[2] - rgb0[2] )/25
    spaceB = ( rgb25[3] - rgb0[3] )/25

    returnR =  rgb0[1] + spaceR * _temp 
    returnG =  rgb0[2] + spaceG * _temp 
    returnB =  rgb0[3] + spaceB * _temp 
  elseif ((_temp > 25) and (_temp <= 45 )) then
    spaceR = ( rgb45[1] - rgb25[1] )/20
    spaceG = ( rgb45[2] - rgb25[2] )/20
    spaceB = ( rgb45[3] - rgb25[3] )/20

    returnR =  rgb25[1] + spaceR * ( _temp - 25 )
    returnG =  rgb25[2] + spaceG * ( _temp - 25 )
    returnB =  rgb25[3] + spaceB * ( _temp - 25 )  
  elseif (_temp > 45) then
    returnR = rgb45[1]
    returnG = rgb45[2]
    returnB = rgb45[3]
  end
  
  return returnR, returnG, returnB
end

function SunColor(_sunrise)

  sunriseLong = mCurrentTime - _sunrise
  change = changeTime/10     --10%~100%總時間
                    					  
  for i = 1, 10 do
    if(sunriseLong > change * (i - 1)) and (sunriseLong <= change * i) then
        percent = i * 0.1
    end
  end
  if (sunriseLong > change * 10) then  --日出3小時過後
    percent = 1
  end
  --print("percent: " .. percent)
  return percent
end

---------------------------------------------------------
---------------------------------------------------------

function MainEffect()
  
  --根據soundCity的天氣撥放音效
  
  if ((mWeather[soundCity] == "Rain") or (mWeather[soundCity] == "Drizzle")) then    --雨
    fibaro:call(virtualDeviceId, "pressButton", rainButton)
  elseif (mWeather[soundCity] == "Snow") then                            --雪
    fibaro:call(virtualDeviceId, "pressButton", snowButton)
  elseif (mWeather[soundCity] == "Thunderstorm")  then                   --雷
    fibaro:call(virtualDeviceId, "pressButton", rayButton) 
  else
    fibaro:call(virtualDeviceId, "pressButton", otherButton)   --其他
  end
  
  
  for i = 1, cityAmount do
	if (mSun[i] == "set") then
	  print("City " .. i .. " ( " .. mCityName[i] .. " ) 目前為夜間，不執行天氣效果")
	  fibaro:call(mLightId[i], "setColor", sunsetColor[1], sunsetColor[2], sunsetColor[3], "0" )
    elseif (mSun[i] == "rise") then		
	  if ((mWeather[i] == "Rain") or (mWeather[i] == "Drizzle")) then         --雨
	    print("City " .. i .. " ( " .. mCityName[i] .. " ) is Rain")
        Rain(mCityName[i], mLightId[i])
      elseif (mWeather[i] == "Snow") then                                 --雪
	    print("City " .. i .. " ( " .. mCityName[i] .. " ) is Snow")
        Snow(mCityName[i], mLightId[i])
      elseif (mWeather[i] == "Thunderstorm")  then                        --雷
	    print("City " .. i .. " ( " .. mCityName[i] .. " ) is Thunderstorm")
        Thunder(mCityName[i], mLightId[i])	
      else                                                            --雲、晴、霧、...
	    print("City " .. i .. " ( " .. mCityName[i] .. " ) is Clouds")
        Clouds(mCityName[i], mLightId[i])
      end
	end
    fibaro:sleep(debugTime*1000)	
  end
  fibaro:sleep(effectTime*1000)
  fibaro:call(virtualDeviceId, "pressButton", stopButton)  --停止音效
end

function Rain(_cityName, _lightId)

  fibaro:call(_lightId, "startProgram", programRain )
  
end

function Snow(_cityName, _lightId)
 -- fibaro:debug(_cityName .. " is Snow")
  fibaro:call(_lightId, "startProgram", programSnow )

end

function Thunder(_cityName, _lightId)
 -- fibaro:debug(_cityName .. " is thunder")
  fibaro:call(_lightId, "startProgram", programThunderstorm )

end

function Clouds(_cityName, _lightId)          --多雲/晴/other
 -- fibaro:debug(_cityName .. " is clouds")
  fibaro:call(_lightId, "startProgram", programOther )

end

---------------------------------------------------------
---------------------------------------------------------

function Main()
  
  local safe = 0
  
  for i = 1, cityAmount do
    city = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "a.value")         --取得城市名稱、LighId
    condition = fibaro:getValue(virtualDeviceId, "ui.Label" .. i .. "b.value")    --取得天氣狀況  
    tCondition = json.decode(condition) 

    mCityName[i] = string.match(city, "(.+)，")
    mLightId[i] = string.match(city, "，(.+)")
    mWeather[i] = tCondition.weather                                              
    mTemp[i] = tCondition.temp
	if (mTemp[i] == nil ) then
      mTemp[i] = 0
	  print("網站目前無提供該城市溫度")
	end  
	  
	mSunriseTime[i] = tCondition.sunrise
	mSunsetTime[i] = tCondition.sunset
	
	mSun[i] = fibaro:getGlobal(gGlobal .. i)
		
    if (mSunsetTime[i] - mCurrentTime) < ( debugTime*10 + effectTime + 30) and ( mSunsetTime[i] > mCurrentTime ) then   --日落前不做事(秒)
	  print("City " .. i .." 即將日落")
      safe = 1
	  break
    end	  
  end
	
  if (safe == 1) then
    print("不執行天氣效果")

  else
	print("沒有城市將要日落，正常執行")
	MainEffect()	--執行天氣效果
	MainColor()	    --顯示氣溫顏色
  end
	
end

---------------------------------------------------------
---------------------------------------------------------
print("start")

if fibaro:countScenes() > 2 then
  print("countScenes > 2 ，中斷")
  fibaro:abort()
end

print("現在時間為 " .. mCurrentTime)
if fibaro:countScenes(sunsetSceneId) > 0 then
  print("因日落情境正在執行，不做任何事")
else
  Main()
end

print("執行完畢，等待間隔時間")
fibaro:sleep(intervalTime * 1000 * 60)
fibaro:startScene(selfId)	                           --N秒後再次執行本scene
print("finish")