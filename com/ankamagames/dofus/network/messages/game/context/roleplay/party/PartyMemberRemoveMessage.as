﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.party
{
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class PartyMemberRemoveMessage extends AbstractPartyEventMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5579;

        private var _isInitialized:Boolean = false;
        public var leavingPlayerId:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (((super.isInitialized) && (this._isInitialized)));
        }

        override public function getMessageId():uint
        {
            return (5579);
        }

        public function initPartyMemberRemoveMessage(partyId:uint=0, leavingPlayerId:uint=0):PartyMemberRemoveMessage
        {
            super.initAbstractPartyEventMessage(partyId);
            this.leavingPlayerId = leavingPlayerId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.leavingPlayerId = 0;
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
            this.serializeAs_PartyMemberRemoveMessage(output);
        }

        public function serializeAs_PartyMemberRemoveMessage(output:ICustomDataOutput):void
        {
            super.serializeAs_AbstractPartyEventMessage(output);
            if (this.leavingPlayerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.leavingPlayerId) + ") on element leavingPlayerId.")));
            };
            output.writeVarInt(this.leavingPlayerId);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_PartyMemberRemoveMessage(input);
        }

        public function deserializeAs_PartyMemberRemoveMessage(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.leavingPlayerId = input.readVarUhInt();
            if (this.leavingPlayerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.leavingPlayerId) + ") on element of PartyMemberRemoveMessage.leavingPlayerId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.party

