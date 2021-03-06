﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.fight.arena
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameRolePlayArenaUpdatePlayerInfosMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6301;

        private var _isInitialized:Boolean = false;
        public var rank:uint = 0;
        public var bestDailyRank:uint = 0;
        public var bestRank:uint = 0;
        public var victoryCount:uint = 0;
        public var arenaFightcount:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6301);
        }

        public function initGameRolePlayArenaUpdatePlayerInfosMessage(rank:uint=0, bestDailyRank:uint=0, bestRank:uint=0, victoryCount:uint=0, arenaFightcount:uint=0):GameRolePlayArenaUpdatePlayerInfosMessage
        {
            this.rank = rank;
            this.bestDailyRank = bestDailyRank;
            this.bestRank = bestRank;
            this.victoryCount = victoryCount;
            this.arenaFightcount = arenaFightcount;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.rank = 0;
            this.bestDailyRank = 0;
            this.bestRank = 0;
            this.victoryCount = 0;
            this.arenaFightcount = 0;
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
            this.serializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(output);
        }

        public function serializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(output:ICustomDataOutput):void
        {
            if ((((this.rank < 0)) || ((this.rank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.rank) + ") on element rank.")));
            };
            output.writeVarShort(this.rank);
            if ((((this.bestDailyRank < 0)) || ((this.bestDailyRank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.bestDailyRank) + ") on element bestDailyRank.")));
            };
            output.writeVarShort(this.bestDailyRank);
            if ((((this.bestRank < 0)) || ((this.bestRank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.bestRank) + ") on element bestRank.")));
            };
            output.writeVarShort(this.bestRank);
            if (this.victoryCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.victoryCount) + ") on element victoryCount.")));
            };
            output.writeVarShort(this.victoryCount);
            if (this.arenaFightcount < 0)
            {
                throw (new Error((("Forbidden value (" + this.arenaFightcount) + ") on element arenaFightcount.")));
            };
            output.writeVarShort(this.arenaFightcount);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(input);
        }

        public function deserializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(input:ICustomDataInput):void
        {
            this.rank = input.readVarUhShort();
            if ((((this.rank < 0)) || ((this.rank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.rank) + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.rank.")));
            };
            this.bestDailyRank = input.readVarUhShort();
            if ((((this.bestDailyRank < 0)) || ((this.bestDailyRank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.bestDailyRank) + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.bestDailyRank.")));
            };
            this.bestRank = input.readVarUhShort();
            if ((((this.bestRank < 0)) || ((this.bestRank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.bestRank) + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.bestRank.")));
            };
            this.victoryCount = input.readVarUhShort();
            if (this.victoryCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.victoryCount) + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.victoryCount.")));
            };
            this.arenaFightcount = input.readVarUhShort();
            if (this.arenaFightcount < 0)
            {
                throw (new Error((("Forbidden value (" + this.arenaFightcount) + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.arenaFightcount.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.fight.arena

