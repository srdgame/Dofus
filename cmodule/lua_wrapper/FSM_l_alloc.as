package cmodule.lua_wrapper
{
   public final class FSM_l_alloc extends Machine
   {
      
      public function FSM_l_alloc() {
         super();
      }
      
      public static function start() : void {
         var _loc1_:FSM_l_alloc = null;
         _loc1_ = new FSM_l_alloc();
         FSM_l_alloc.gworker = _loc1_;
      }
      
      public static const intRegCount:int = 2;
      
      public static const NumberRegCount:int = 0;
      
      override public final function work() : void {
      }
      
      public var i0:int;
      
      public var i1:int;
   }
}