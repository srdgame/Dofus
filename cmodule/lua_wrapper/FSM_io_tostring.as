package cmodule.lua_wrapper
{
   public final class FSM_io_tostring extends Machine
   {
      
      public function FSM_io_tostring() {
         super();
      }
      
      public static function start() : void {
         var _loc1_:FSM_io_tostring = null;
         _loc1_ = new FSM_io_tostring();
         FSM_io_tostring.gworker = _loc1_;
      }
      
      public static const intRegCount:int = 4;
      
      public static const NumberRegCount:int = 0;
      
      override public final function work() : void {
      }
      
      public var i0:int;
      
      public var i1:int;
      
      public var i2:int;
      
      public var i3:int;
   }
}