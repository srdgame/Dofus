﻿package com.ankamagames.dofus.network.messages.web.krosmaster
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class KrosmasterPlayingStatusMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6347;

        private var _isInitialized:Boolean = false;
        public var playing:Boolean = false;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6347);
        }

        public function initKrosmasterPlayingStatusMessage(playing:Boolean=false):KrosmasterPlayingStatusMessage
        {
            this.playing = playing;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.playing = false;
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
            this.serializeAs_KrosmasterPlayingStatusMessage(output);
        }

        public function serializeAs_KrosmasterPlayingStatusMessage(output:ICustomDataOutput):void
        {
            output.writeBoolean(this.playing);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_KrosmasterPlayingStatusMessage(input);
        }

        public function deserializeAs_KrosmasterPlayingStatusMessage(input:ICustomDataInput):void
        {
            this.playing = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.messages.web.krosmaster

