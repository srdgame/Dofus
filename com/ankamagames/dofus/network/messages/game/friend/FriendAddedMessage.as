﻿package com.ankamagames.dofus.network.messages.game.friend
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.friend.FriendInformations;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import com.ankamagames.dofus.network.ProtocolTypeManager;

    [Trusted]
    public class FriendAddedMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5599;

        private var _isInitialized:Boolean = false;
        public var friendAdded:FriendInformations;

        public function FriendAddedMessage()
        {
            this.friendAdded = new FriendInformations();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5599);
        }

        public function initFriendAddedMessage(friendAdded:FriendInformations=null):FriendAddedMessage
        {
            this.friendAdded = friendAdded;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.friendAdded = new FriendInformations();
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
            this.serializeAs_FriendAddedMessage(output);
        }

        public function serializeAs_FriendAddedMessage(output:ICustomDataOutput):void
        {
            output.writeShort(this.friendAdded.getTypeId());
            this.friendAdded.serialize(output);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_FriendAddedMessage(input);
        }

        public function deserializeAs_FriendAddedMessage(input:ICustomDataInput):void
        {
            var _id1:uint = input.readUnsignedShort();
            this.friendAdded = ProtocolTypeManager.getInstance(FriendInformations, _id1);
            this.friendAdded.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.messages.game.friend

