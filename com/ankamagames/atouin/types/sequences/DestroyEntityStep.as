﻿package com.ankamagames.atouin.types.sequences
{
    import com.ankamagames.jerakine.sequencer.AbstractSequencable;
    import com.ankamagames.jerakine.entities.interfaces.IEntity;
    import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
    import com.ankamagames.tiphon.display.TiphonSprite;

    public class DestroyEntityStep extends AbstractSequencable 
    {

        private var _entity:IEntity;

        public function DestroyEntityStep(entity:IEntity)
        {
            this._entity = entity;
        }

        override public function start():void
        {
            if ((this._entity is IDisplayable))
            {
                (this._entity as IDisplayable).remove();
            };
            if ((this._entity is TiphonSprite))
            {
                (this._entity as TiphonSprite).destroy();
            };
            executeCallbacks();
        }


    }
}//package com.ankamagames.atouin.types.sequences

