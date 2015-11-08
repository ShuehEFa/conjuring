--[[
%% autostart
%% properties
227 value
177 value
228 value
%% globals
EH_FakeCo
EH_FakeHu
EH_FakeInTe
EH_UseFakeCo
EH_UseFakeHu
EH_UseFakeInTe
--]]

--[[
  @author eFa
  @date   104.10.19
  @brief  取得指定Sensor數值
      長昇使用版本，會將值紀錄到Global Value，同時依據是否作假模式而傳真的或假的值
      Global Value儲存的值是供其他情境或Virtual Device使用，如此這些設備就不用管是否使用軟體模擬數值
      是否作假就由本情境處理，其他的則由“長昇環境偵測”的Virtual Device處理

  @note   注意上方Trigger參數必須與下面的成員變數匹配
--]]

-- 是否啟動各項參數作假
local gUseFakeCo = "EH_UseFakeCo"   -- co2
local gUseFakeHu = "EH_UseFakeHu"   -- 濕度
local gUseFakeTe = "EH_UseFakeInTe" -- 室內溫度

-- 各項參數作假值
local gFakeCo = "EH_FakeCo"     -- co2
local gFakeHu = "EH_FakeHu"     -- 濕度
local gFakeTe = "EH_FakeInTe"   -- 室內溫度

-- 儲存要給外界使用的數值
local gCo = "EH_ValueCo"        -- co2
local gHu = "EH_ValueHu"        -- 濕度
local gTe = "EH_ValueInTe"      -- 室內溫度

-- Sensor ID
local mCo2ID = 177              -- co2 sensor id
local mHumidityID = 227         -- 濕度 sensor id
local mTemperatureID = 228      -- 溫度 sensor id

local useFake , value

-- co2
useFake = ( fibaro:getGlobalValue( gUseFakeCo ) == "true" )
if useFake then
  value = fibaro:getGlobalValue( gFakeCo )
else
  value = fibaro:getValue( mCo2ID , "value" )
end
fibaro:setGlobal( gCo , value )

-- 濕度
useFake = ( fibaro:getGlobalValue( gUseFakeHu ) == "true" )
if useFake then
  value = fibaro:getGlobalValue( gFakeHu )
else
  value = fibaro:getValue( mHumidityID , "value" )
end
fibaro:setGlobal( gHu , value )

-- 室內溫度
useFake = ( fibaro:getGlobalValue( gUseFakeTe ) == "true" )
if useFake then
  value = fibaro:getGlobalValue( gFakeTe )
else
  value = fibaro:getValue( mTemperatureID , "value" )
end
fibaro:setGlobal( gTe , value )

print( "modifing..." )