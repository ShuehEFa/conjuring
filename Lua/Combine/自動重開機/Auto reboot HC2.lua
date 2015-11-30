--[[
%% autostart
%% properties
%% globals
--]]

--[[
  @author LALA
  @date   104.11.27
  @brief  於特定時段內檢查HC2記憶體使用量，若超過標準則重開機
--]]

local startTime = 2300 --開始檢查時間
local untilTime = 0100 --結束檢查時間
local memoryStandard = 10 --momory free低於此標準會重開
local memoryStatusID = 358 --vitrul device "memory status"

local memoryFree = "ui.Label1.value"
local currentTime = (tonumber(os.date("%H%M")))

function Reboot()
  if ( tonumber(fibaro:getValue( memoryStatusID , memoryFree )) < memoryStandard ) then
    fibaro:debug("準備重開機")       
    fibaro:sleep(10000)
    fibaro:call(memoryStatusID, "pressButton", "2");
  else
    fibaro:debug("不用重開")
  end
end


while 1 do
  if ( startTime < untilTime ) then  --e.g. 0000~0300
    print("startTime < untilTime")
	if ( (tonumber(os.date("%H%M"))) > startTime ) and ( (tonumber(os.date("%H%M"))) < untilTime ) then
      print((tonumber(os.date("%H%M"))))
	  Reboot()	  
    end    
  elseif ( startTime > untilTime )  then  --e.g. 2300~0200
    print("startTime > untilTime")
	if ( (tonumber(os.date("%H%M"))) > startTime ) or ( (tonumber(os.date("%H%M"))) < untilTime ) then
      Reboot()
    end  
  elseif ( startTime == untilTime ) then
    print("startTime == untilTime")
	if ( ( ( startTime - 1 ) < (tonumber(os.date("%H%M"))) ) and  ((tonumber(os.date("%H%M"))) < ( startTime + 1 ) ) ) then	
      Reboot()
    end
  end    
  fibaro:sleep(1000*60*1)
end