﻿package com.ankamagames.berilia.types.event
{
    import flash.events.Event;
    import com.ankamagames.berilia.types.data.Hook;

    public class HookEvent extends Event 
    {

        public static const DISPATCHED:String = "hooDispatched";

        private var _hook:Hook;

        public function HookEvent(type:String, hook:Hook)
        {
            super(type, false, false);
            this._hook = hook;
        }

        public function get hook():Hook
        {
            return (this._hook);
        }


    }
}//package com.ankamagames.berilia.types.event

