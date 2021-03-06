﻿package com.ankamagames.dofus.network.types.game.context.roleplay
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.dofus.network.types.game.guild.GuildEmblem;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class AllianceInformations extends BasicNamedAllianceInformations implements INetworkType 
    {

        public static const protocolId:uint = 417;

        public var allianceEmblem:GuildEmblem;

        public function AllianceInformations()
        {
            this.allianceEmblem = new GuildEmblem();
            super();
        }

        override public function getTypeId():uint
        {
            return (417);
        }

        public function initAllianceInformations(allianceId:uint=0, allianceTag:String="", allianceName:String="", allianceEmblem:GuildEmblem=null):AllianceInformations
        {
            super.initBasicNamedAllianceInformations(allianceId, allianceTag, allianceName);
            this.allianceEmblem = allianceEmblem;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.allianceEmblem = new GuildEmblem();
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_AllianceInformations(output);
        }

        public function serializeAs_AllianceInformations(output:ICustomDataOutput):void
        {
            super.serializeAs_BasicNamedAllianceInformations(output);
            this.allianceEmblem.serializeAs_GuildEmblem(output);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_AllianceInformations(input);
        }

        public function deserializeAs_AllianceInformations(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.allianceEmblem = new GuildEmblem();
            this.allianceEmblem.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.roleplay

