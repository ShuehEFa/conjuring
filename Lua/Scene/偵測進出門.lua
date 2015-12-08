--[[
%% properties
486 value
496 value
%% globals
--]]

--[[
  @author LalA
  @date   104.12.01
  @brief  偵測出門或進門
  @note   1. 填寫內外側motionSensorID
          2. 填寫properties trigger
		  3. 新增globalValue: inOrOut
		  4. 填寫timeout
--]]

local motionInside = 486  --內側sensorID
local motionOutside = 496  --外側sensorID
local mTimeout = 1000 --偵測到人卻沒進/出門，過幾毫秒後忽略此次動作
local gInOrOut = "inOrOut" --預設有人進門時設此global value為1，有人出門時設此global value為2，

--偵測到有人進門時做的事
function ComeIn()
  fibaro:setGlobal( gInOrOut , 1 )
  print('<span style="color:yellow">有人進來</span>')
end

--偵測到有人出門時做的事
function GoOut()
  fibaro:setGlobal( gInOrOut , 2 )
  print('<span style="color:pink">有人出去</span>')
end


local trigger = fibaro:getSourceTrigger()
local firstTrigger = tonumber( trigger['deviceID'])
local lastTrigger = 0
local motionOnInside = false
local motionOnOutside = false
local motionOnInside = (tonumber(fibaro:getValue(motionInside , "value")) > 0 ) 
local motionOnOutside = (tonumber(fibaro:getValue(motionOutside , "value")) > 0 )  

if (trigger['type'] ~= 'property' ) then
  fibaro:abort()
end

if (fibaro:countScenes() > 1 ) then
  fibaro:abort()
end

if motionOnInside and (not motionOnOutside) then
  print("裡面照到人了")
  for i = 1 , mTimeout do
    motionOnOutside = (tonumber(fibaro:getValue(motionOutside , "value")) > 0 ) 
	motionOnInside = (tonumber(fibaro:getValue(motionInside , "value")) > 0 )
	if motionOnOutside	and (not motionOnInside) then	  
	  GoOut()
      fibaro:abort()	
	end
	fibaro:sleep(10)
  end
  print('<span style="color:gray">逾時，忽略</span>')    
elseif motionOnOutside and (not motionOnInside) then
  print("外面照到人了") 
  for i = 1 , mTimeout do
    motionOnOutside = (tonumber(fibaro:getValue(motionOutside , "value")) > 0 ) 
	motionOnInside = (tonumber(fibaro:getValue(motionInside , "value")) > 0 )
	if motionOnInside	and (not motionOnOutside) then	  
      ComeIn()
      fibaro:abort()	
	end
	fibaro:sleep(10)
  end
  print('<span style="color:gray">逾時，忽略</span>')  
end