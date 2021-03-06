﻿package com.ankamagames.dofus.network.messages.connection
{
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class IdentificationSuccessWithLoginTokenMessage extends IdentificationSuccessMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6209;

        private var _isInitialized:Boolean = false;
        public var loginToken:String = "";


        override public function get isInitialized():Boolean
        {
            return (((super.isInitialized) && (this._isInitialized)));
        }

        override public function getMessageId():uint
        {
            return (6209);
        }

        public function initIdentificationSuccessWithLoginTokenMessage(login:String="", nickname:String="", accountId:uint=0, communityId:uint=0, hasRights:Boolean=false, secretQuestion:String="", accountCreation:Number=0, subscriptionElapsedDuration:Number=0, subscriptionEndDate:Number=0, wasAlreadyConnected:Boolean=false, loginToken:String=""):IdentificationSuccessWithLoginTokenMessage
        {
            super.initIdentificationSuccessMessage(login, nickname, accountId, communityId, hasRights, secretQuestion, accountCreation, subscriptionElapsedDuration, subscriptionEndDate, wasAlreadyConnected);
            this.loginToken = loginToken;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.loginToken = "";
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
            this.serializeAs_IdentificationSuccessWithLoginTokenMessage(output);
        }

        public function serializeAs_IdentificationSuccessWithLoginTokenMessage(output:ICustomDataOutput):void
        {
            super.serializeAs_IdentificationSuccessMessage(output);
            output.writeUTF(this.loginToken);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_IdentificationSuccessWithLoginTokenMessage(input);
        }

        public function deserializeAs_IdentificationSuccessWithLoginTokenMessage(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.loginToken = input.readUTF();
        }


    }
}//package com.ankamagames.dofus.network.messages.connection

