﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.fight
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameRolePlayFightRequestCanceledMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5822;

        private var _isInitialized:Boolean = false;
        public var fightId:int = 0;
        public var sourceId:uint = 0;
        public var targetId:int = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5822);
        }

        public function initGameRolePlayFightRequestCanceledMessage(fightId:int=0, sourceId:uint=0, targetId:int=0):GameRolePlayFightRequestCanceledMessage
        {
            this.fightId = fightId;
            this.sourceId = sourceId;
            this.targetId = targetId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.fightId = 0;
            this.sourceId = 0;
            this.targetId = 0;
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

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GameRolePlayFightRequestCanceledMessage(output);
        }

        public function serializeAs_GameRolePlayFightRequestCanceledMessage(output:ICustomDataOutput):void
        {
            output.writeInt(this.fightId);
            if (this.sourceId < 0)
            {
                throw (new Error((("Forbidden value (" + this.sourceId) + ") on element sourceId.")));
            };
            output.writeVarInt(this.sourceId);
            output.writeInt(this.targetId);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameRolePlayFightRequestCanceledMessage(input);
        }

        public function deserializeAs_GameRolePlayFightRequestCanceledMessage(input:ICustomDataInput):void
        {
            this.fightId = input.readInt();
            this.sourceId = input.readVarUhInt();
            if (this.sourceId < 0)
            {
                throw (new Error((("Forbidden value (" + this.sourceId) + ") on element of GameRolePlayFightRequestCanceledMessage.sourceId.")));
            };
            this.targetId = input.readInt();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.fight

