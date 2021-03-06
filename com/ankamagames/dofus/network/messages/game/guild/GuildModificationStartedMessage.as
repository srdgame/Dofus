﻿package com.ankamagames.dofus.network.messages.game.guild
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import com.ankamagames.jerakine.network.utils.BooleanByteWrapper;

    [Trusted]
    public class GuildModificationStartedMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6324;

        private var _isInitialized:Boolean = false;
        public var canChangeName:Boolean = false;
        public var canChangeEmblem:Boolean = false;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6324);
        }

        public function initGuildModificationStartedMessage(canChangeName:Boolean=false, canChangeEmblem:Boolean=false):GuildModificationStartedMessage
        {
            this.canChangeName = canChangeName;
            this.canChangeEmblem = canChangeEmblem;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.canChangeName = false;
            this.canChangeEmblem = false;
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
            this.serializeAs_GuildModificationStartedMessage(output);
        }

        public function serializeAs_GuildModificationStartedMessage(output:ICustomDataOutput):void
        {
            var _box0:uint;
            _box0 = BooleanByteWrapper.setFlag(_box0, 0, this.canChangeName);
            _box0 = BooleanByteWrapper.setFlag(_box0, 1, this.canChangeEmblem);
            output.writeByte(_box0);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GuildModificationStartedMessage(input);
        }

        public function deserializeAs_GuildModificationStartedMessage(input:ICustomDataInput):void
        {
            var _box0:uint = input.readByte();
            this.canChangeName = BooleanByteWrapper.getFlag(_box0, 0);
            this.canChangeEmblem = BooleanByteWrapper.getFlag(_box0, 1);
        }


    }
}//package com.ankamagames.dofus.network.messages.game.guild

