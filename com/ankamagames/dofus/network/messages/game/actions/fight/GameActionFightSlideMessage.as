﻿package com.ankamagames.dofus.network.messages.game.actions.fight
{
    import com.ankamagames.dofus.network.messages.game.actions.AbstractGameActionMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameActionFightSlideMessage extends AbstractGameActionMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5525;

        private var _isInitialized:Boolean = false;
        public var targetId:int = 0;
        public var startCellId:int = 0;
        public var endCellId:int = 0;


        override public function get isInitialized():Boolean
        {
            return (((super.isInitialized) && (this._isInitialized)));
        }

        override public function getMessageId():uint
        {
            return (5525);
        }

        public function initGameActionFightSlideMessage(actionId:uint=0, sourceId:int=0, targetId:int=0, startCellId:int=0, endCellId:int=0):GameActionFightSlideMessage
        {
            super.initAbstractGameActionMessage(actionId, sourceId);
            this.targetId = targetId;
            this.startCellId = startCellId;
            this.endCellId = endCellId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.targetId = 0;
            this.startCellId = 0;
            this.endCellId = 0;
            this._isInitialized = false;
        }

        override public function pack(output:ICustomDataOutput):void
        {
            var data:ByteArray = new ByteArray();
            this.serialize(new CustomDataWrapper(data));
            writePacket(output, this.getMessageId(), data);
        }

        override public function unpack(input:ICustomDataInput, length:uint):void
        {
            this.deserialize(input);
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GameActionFightSlideMessage(output);
        }

        public function serializeAs_GameActionFightSlideMessage(output:ICustomDataOutput):void
        {
            super.serializeAs_AbstractGameActionMessage(output);
            output.writeInt(this.targetId);
            if ((((this.startCellId < -1)) || ((this.startCellId > 559))))
            {
                throw (new Error((("Forbidden value (" + this.startCellId) + ") on element startCellId.")));
            };
            output.writeShort(this.startCellId);
            if ((((this.endCellId < -1)) || ((this.endCellId > 559))))
            {
                throw (new Error((("Forbidden value (" + this.endCellId) + ") on element endCellId.")));
            };
            output.writeShort(this.endCellId);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameActionFightSlideMessage(input);
        }

        public function deserializeAs_GameActionFightSlideMessage(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.targetId = input.readInt();
            this.startCellId = input.readShort();
            if ((((this.startCellId < -1)) || ((this.startCellId > 559))))
            {
                throw (new Error((("Forbidden value (" + this.startCellId) + ") on element of GameActionFightSlideMessage.startCellId.")));
            };
            this.endCellId = input.readShort();
            if ((((this.endCellId < -1)) || ((this.endCellId > 559))))
            {
                throw (new Error((("Forbidden value (" + this.endCellId) + ") on element of GameActionFightSlideMessage.endCellId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.actions.fight

