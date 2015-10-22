--[[
%% autostart
%% properties
%% globals
EH_ValueCo
EH_ValueHu
EH_ValueInTe
EH_ValueOutTe
EH_ValuePm
EH_ValueUv
--]]

--[[
  @author eFa
  @date   104.10.20
  @brief  當Global數值改變就傳值給server

  @note   記得Trigger Property的條件要與對應
--]]

local gCo = "EH_ValueCo"		-- 紫外線
local gHu = "EH_ValueHu"		-- PM2.5
local gInTe = "EH_ValueInTe"	-- 戶外溫度
local gUv = "EH_ValueUv"		-- 紫外線
local gPm = "EH_ValuePm"		-- PM2.5
local gOutTe = "EH_ValueOutTe"	-- 戶外溫度

local mSeverIP = "192.168.0.49"
local mSeverPort = 8080

local co = fibaro:getGlobalValue( gCo )
local hu = fibaro:getGlobalValue( gHu )
local inTe = fibaro:getGlobalValue( gInTe )
local uv = fibaro:getGlobalValue( gUv )
local pm = fibaro:getGlobalValue( gPm )
local outTe = fibaro:getGlobalValue( gOutTe )

local url = "http://" .. mSeverIP .. ":" .. mSeverPort .. "/api/demo/set/sensor/"
url = url .. hu .. "/" .. inTe .. "/" .. co .. "/" .. uv .. "/" .. outTe .. "/" .. pm

local h = net.HTTPClient()
h:request
(
  url ,
  {
    success = function( resp )
      print( resp.status )
    end ,
    error = function( error )
      print( error )
    end
  }
)