--[[
  @author eFa
  @brief  FLH開發基本Lib
  @date   2015.08.28
--]]
if FLH == nil then 
  FLH = 
  {
    --[[
      @brief 可以指定顏色的Fibaro:debug()
      @parm  _text  any，欲顯示的參數
      @parm  _color 字串，欲顯示的顏色。ex: "yellow", "pink"。不填寫使用預設白色
    --]]
    Log = function( _text , _color )
      _color = _color or "white"
      fibaro:debug( '<span style="color:' .. _color .. '">' .. tostring( _text ) .. '</span>' )
    end ,

    --[[  
      @brief 解析Table的成員及型態
      @pram  _tTable  Table，指定的Table
      @pram  _color   字串，欲顯示的顏色。ex: "yellow", "pink"。不填寫使用預設白色
      @pram  _space   數字，要留多少空格在顯示文字前面，預設0
    --]]
    LogTable = function( _tTable , _color , _space )
      _space = _space or 0
      local spaceText = ""
      for i = 1 , _space do
        spaceText = spaceText .. "　　"
      end
      
      for key , value in pairs( _tTable ) do
        if type( value ) == "table" then
          Log( spaceText .. key .. " : table" , _color )
          LogTable( value , _color , _space + 1 )
        elseif type( value ) == "function" then
          Log( spaceText .. key .. " : function" , _color )
        elseif type( value ) == "userdata" then
          Log( spaceText .. key .. " : userdata" , _color )
        else
          Log( spaceText .. key .. " : " .. value , _color )
        end
      end
    end ,
  }
end