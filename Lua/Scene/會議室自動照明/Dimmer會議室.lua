--[[
%% properties
769 sceneActivation
%% globals
--]]

--[[
  @author eFa
--]]

--[[
holding down ID 12 (option inactive in case of roller blind switch)
releasing ID 13
double click ID 14 (depends on parameters 15 value - 1 = double click active)
triple click ID 15
one click ID 16
--]]
--會議室間接燈300 會議室超大燈765 客廳間接燈302
--會議室嵌燈899 客廳嵌燈901
local mtLightId =  {765,899} --{ 899,765,901 } 

local Modevice = 276
local dimmerId = 769
local delaySec = 40000
local Trigger = fibaro:getSourceTrigger()
local LightState = fibaro:get( mtLightId[2] , 'value' )
fibaro:debug(fibaro:getValue(dimmerId, "sceneActivation"))

function lightOff(_table)
for i = 1 , #_table do   
  fibaro:call(_table[i],"turnOff")
end
end

function lightOn(_table)
for i = 1 , #_table do   
  fibaro:call(_table[i],"turnOn")
end
end

if( Trigger[ 'type' ] == 'property' ) then
  
--one click and holding
if tonumber(fibaro:getValue(dimmerId, "sceneActivation")) == 16 or tonumber(fibaro:getValue(dimmerId, "sceneActivation")) == 12 then 
	if tonumber(LightState) == 1 then
      	fibaro:debug("目前電燈狀態: " .. LightState)
    	lightOff(mtLightId)
        fibaro:debug("目前電燈狀態: " ..  LightState .. "關閉電燈")
    elseif tonumber(LightState) == 0 then
        fibaro:debug("目前電燈狀態: " .. LightState)
    	lightOn(mtLightId)
      	fibaro:debug("目前電燈狀態: " ..  LightState .. "開啟電燈")
      
    end
end

--double click
if  tonumber(fibaro:getValue(dimmerId, "sceneActivation")) == 14 then 
if(fibaro:getGlobalValue('SlideMode')=='0') then
	lightOff(mtLightId)
    fibaro:setGlobal('SlideMode','1')
    fibaro:debug("電燈狀態:" .. LightState .. "開啟簡報模式")
	          while fibaro:getGlobalValue('SlideMode')=='1' do
                if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
            			fibaro:debug( "一般模式：第一次偵測沒人" )
          				fibaro:sleep(delaySec)
          				if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
            				lightOff(mtLightId)
              				fibaro:setGlobal('SlideMode','0')
            				fibaro:debug("系統判定會議室沒人了，關閉燈光，關閉簡報模式");
          					break
              			else
              				fibaro:debug( "簡報模式：二次偵測有人" )
          				end --if
          		end --if
      end --while
          
end
end
--triple click
if  tonumber(fibaro:getValue(dimmerId, "sceneActivation")) == 15 then 
if(fibaro:getGlobalValue('SlideMode')=='1') then
	lightOn(mtLightId)
    fibaro:setGlobal('SlideMode','0')
    fibaro:debug("電燈狀態:" .. LightState .. "關閉簡報模式")
                while fibaro:getGlobalValue('SlideMode')=='0' do
                if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
            			fibaro:debug( "一般模式：第一次偵測沒人" )
          				fibaro:sleep(delaySec)
          				if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
            				lightOff(mtLightId)
              				fibaro:setGlobal('SlideMode','0')
            				fibaro:debug("系統判定會議室沒人了，關閉燈光，關閉簡報模式");
          					break
              			else
              				fibaro:debug( "簡報模式：二次偵測有人" )
          				end --if
          		end --if
      			end --while
                
end
end
  
end

