--[[
%% properties

%% globals
sleepLight
--]]

--[[
  @author Lala
  @date   105.03.01
  @brief  超過睡覺時間燈光會逐漸變暗，超過起床時間燈光會逐漸變亮
  @note   
   1. 需搭配VD使用
   2. 填寫trigger：%%globals sleepLight
   3. 填寫dimmerId
--]]




local tLightId = {723} --dimmerId

local turnOffTime = 2  --多久減弱一次燈光(分鐘)，總共分5階段
local turnOnTime = 1   --多久增強一次燈光(分鐘)，總共分5階段

--__--__--__--__--
local gLightRecord = "sleepLight2"

if (fibaro:countScenes() > 1) then
  fibaro:abort()
end



print("start")
local tLightValue = {}

for i = 1, #tLightId do
  tLightValue[i] = { id = tLightId[i], value = fibaro:getValue(tLightId[i], "value") }
end

local lightValue = json.encode(tLightValue)  --紀錄修改前亮度

print(lightValue)
fibaro:setGlobal(gLightRecord, lightValue)

local tTrigger = fibaro:getSourceTrigger()

local timeSelect = fibaro:getGlobal(tTrigger.name)

print(timeSelect)

if (timeSelect == "睡眠") then
  for i = 1, 5 do
    for  j = 1, #tLightId do
      lastValue = fibaro:getValue(tLightId[j], "value")
      newValue = math.floor(lastValue * 0.7)
	--  lastValue = newValue
      fibaro:call(tLightId[j], "setValue", newValue)
      print(newValue)
    end
  fibaro:sleep(turnOffTime * 60 * 1000)
  end
  for  j = 1, #tLightId do
    fibaro:call(tLightId[j], "turnOff")
  end  

elseif (timeSelect == "起床") then
  for i = 1, 5 do
    for  j = 1, #tLightId do
      lastValue = fibaro:getValue(tLightId[j], "value")
      newValue = math.floor((100 - lastValue) * 0.5 + lastValue)
	--  lastValue = newValue
      fibaro:call(tLightId[j], "setValue", newValue)
      print(newValue)
    end
  fibaro:sleep(turnOnTime * 60 * 1000)
  end
  for  j = 1, #tLightId do
    fibaro:call(tLightId[j], "setValue", 100)
  end

print("end")
end
