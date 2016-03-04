--[[
  @author eFa
  @date   105.03.04
  @brief  FLH開發基本Lib

  @ date 105.03.04 by eFa . 修正LogTable
--]]
if FLH == nil then 
  FLH = 
  {
    version = "1.0" ,
    --[[
      @brief 可以指定顏色的Fibaro:debug()
      @parm  _data  any，欲print的資料
      @parm  _color 字串，欲顯示的顏色。ex: "yellow", "pink"。不填寫使用預設白色
    --]]
    Log = function( _data , _color )
      _color = _color or "white"
      fibaro:debug( '<span style="color:' .. _color .. '">' .. tostring( _data ) .. '</span>' )
    end ,

    --[[  
      @brief 解析Table的成員及型態
      @parm  _tTable Table，欲print的Table資料
      @parm  _color  字串，欲顯示的顏色。ex: "yellow", "pink"。不填寫使用預設白色
      @parm  _space  數字，要留多少空格在顯示文字前面，不填寫使用預設0
    --]]
    LogTable = function( _self , _tTable , _color , _space )
      _space = _space or 0
      local spaceText = ""
      for i = 1 , _space do
        spaceText = spaceText .. "　　"
      end
      
      for key , value in pairs( _tTable ) do
        if type( value ) == "table" then
          _self.Log( spaceText .. key .. " : table" , _color )
          _self:LogTable( value , _color , _space + 1 )
        elseif type( value ) == "function" then
          _self.Log( spaceText .. key .. " : function" , _color )
        elseif type( value ) == "userdata" then
          _self.Log( spaceText .. key .. " : userdata" , _color )
        else
          _self.Log( spaceText .. key .. " : " .. tostring( value ) , _color )
        end
      end
    end ,
    
    --[[  
      @brief 可以指定顏色的Fibaro:debug()，若資料是Table會把所有成員顯示出來
      @parm  _data  any，欲print的資料
      @parm  _color 字串，欲顯示的顏色。ex: "yellow", "pink"。不填寫使用預設白色
      @parm  _space 數字，要留多少空格在顯示文字前面，不填寫使用預設0
    --]]
    Debug = function( _self , _data , _color , _space )
      _space = _space or 0
      local spaceText = ""
      for i = 1 , _space do
        spaceText = spaceText .. "　　"
      end
      
      if type( _data ) == 'userdata' then
        _self.Log( spaceText .. "userdata" , _color )
      else
        _self.Log( spaceText .. tostring( _data ) , _color )
      end
      
      if type( _data ) == 'table' then
        _self:LogTable( _data , _color , _space + 1 )
      end
    end ,
  }
end