--[[
%% properties
276 value
%% globals
SlideMode
--]]
--[[
  @author Singo
--]]

--會議室間接燈300 會議室超大燈765 客廳間接燈302
--會議室嵌燈899 客廳嵌燈901
local mtLightId = {765,899} --{ 899,765,901 } 
local motionSensor=276
local delaySec = 40000
local delayNormal = 10000 --毫秒 
local Trigger = fibaro:getSourceTrigger();

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

if(Trigger[ 'type' ] == 'property' ) then
  local countScenes = fibaro:countScenes();
  local alreadyWork = fibaro:countScenes() <= 1;
  --local lightTriger = ( Trigger[ 'deviceID' ] == motionSensor );
  local lightState = fibaro:get( mtLightId[1] , 'value' )
  
  if alreadyWork then
    
      if(fibaro:getGlobalValue('SlideMode')=='0') then
      if(tonumber(fibaro:getValue(motionSensor,"value")))==1 then
            fibaro:debug( "一般模式：開始" )
            lightOn(mtLightId)
            while 1 do
              fibaro:debug( "一般模式：更新" )
          if fibaro:getGlobalValue('SlideMode')=='1' then
                  fibaro:debug("簡報模式開啟中");
                  break
                end
              fibaro:sleep(2000)
              if(tonumber(fibaro:getValue(motionSensor,"value")))==1 and (tonumber(fibaro:getValue(mtLightId[1],"value")))==0 and fibaro:getGlobalValue('SlideMode')=='0' then
                  fibaro:sleep(delayNormal)
                  lightOn(mtLightId)
                  fibaro:debug("系統判定會議室燈光異常，自動開啟燈光");
                end
       
              if(tonumber(fibaro:getValue(motionSensor,"value")))==0 then
                  fibaro:debug( "一般模式：一次偵測沒人" )
                  fibaro:sleep(delaySec)
                  if(tonumber(fibaro:getValue(motionSensor,"value")))==0 then
              lightOff(mtLightId)
                    fibaro:debug("系統判定會議室沒人了，關閉燈光");
                    break
                    else
                      fibaro:debug( "一般模式：二次偵測有人" )
                  end
              else
                  fibaro:debug( "一般模式：有人" )
                end
          
            end --while
            fibaro:debug( "一般模式：跳離" )
          else --偷偷被開燈的情況下
            while fibaro:getGlobalValue('SlideMode')=='0' do
                if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
                  fibaro:debug( "一般模式：第一次偵測沒人" )
                  fibaro:sleep(delaySec)
                  if(tonumber(fibaro:getValue(Modevice,"value")))==0 then
                    lightOff(mtLightId)
                    fibaro:debug("系統判定會議室沒人了，關閉燈光");
                    break
                    else
                      fibaro:debug( "簡報模式：二次偵測有人" )
                  end --if
              end --if
        end --while
        end
    
      fibaro:debug( "一般模式：結束" )
      
        else --簡報模式開啟中
          fibaro:debug("簡報模式開啟中");
          if(tonumber(fibaro:getValue(motionSensor,"value")))==1 then
            while 1 do
              fibaro:debug( "簡報模式：更新" )
                if fibaro:getGlobalValue('SlideMode')=='0' then
                  fibaro:debug("關閉簡報模式");
                  break
                end

              if(tonumber(fibaro:getValue(motionSensor,"value")))==0 or (tonumber(fibaro:getValue(motionSensor,"value")))==1 then
                  fibaro:debug( "簡報模式：第一次偵測沒人" )
                  fibaro:sleep(delaySec)
                  if(tonumber(fibaro:getValue(motionSensor,"value")))==0 then
                    lightOff(mtLightId)
                      fibaro:setGlobal('SlideMode','0')
                    fibaro:debug("系統判定會議室沒人了，關閉燈光，關閉簡報模式");
                    break
                    else
                      fibaro:debug( "簡報模式：二次偵測有人" )
                  end --if
                else
                  fibaro:debug( "簡報模式：有人" )
              end --if
            end --簡報模式中的while
            fibaro:debug( "簡報模式：離開" )
          else --被偷偷開簡報模式的情況下
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
          end --簡報模式中的if
          fibaro:debug( "簡報模式：結束" )
        end --SlideMode
      
  end --alreadyWork

end --Trigger