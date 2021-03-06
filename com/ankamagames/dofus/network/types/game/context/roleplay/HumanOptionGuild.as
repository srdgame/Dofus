﻿package com.ankamagames.dofus.network.types.game.context.roleplay
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class HumanOptionGuild extends HumanOption implements INetworkType 
    {

        public static const protocolId:uint = 409;

        public var guildInformations:GuildInformations;

        public function HumanOptionGuild()
        {
            this.guildInformations = new GuildInformations();
            super();
        }

        override public function getTypeId():uint
        {
            return (409);
        }

        public function initHumanOptionGuild(guildInformations:GuildInformations=null):HumanOptionGuild
        {
            this.guildInformations = guildInformations;
            return (this);
        }

        override public function reset():void
        {
            this.guildInformations = new GuildInformations();
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_HumanOptionGuild(output);
        }

        public function serializeAs_HumanOptionGuild(output:ICustomDataOutput):void
        {
            super.serializeAs_HumanOption(output);
            this.guildInformations.serializeAs_GuildInformations(output);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_HumanOptionGuild(input);
        }

        public function deserializeAs_HumanOptionGuild(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.guildInformations = new GuildInformations();
            this.guildInformations.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.roleplay

