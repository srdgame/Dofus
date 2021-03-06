﻿package com.ankamagames.dofus.network.types.game.context.roleplay
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.dofus.network.types.game.character.alignment.ActorAlignmentInformations;
    import com.ankamagames.dofus.network.types.game.look.EntityLook;
    import com.ankamagames.dofus.network.types.game.context.EntityDispositionInformations;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class GameRolePlayCharacterInformations extends GameRolePlayHumanoidInformations implements INetworkType 
    {

        public static const protocolId:uint = 36;

        public var alignmentInfos:ActorAlignmentInformations;

        public function GameRolePlayCharacterInformations()
        {
            this.alignmentInfos = new ActorAlignmentInformations();
            super();
        }

        override public function getTypeId():uint
        {
            return (36);
        }

        public function initGameRolePlayCharacterInformations(contextualId:int=0, look:EntityLook=null, disposition:EntityDispositionInformations=null, name:String="", humanoidInfo:HumanInformations=null, accountId:uint=0, alignmentInfos:ActorAlignmentInformations=null):GameRolePlayCharacterInformations
        {
            super.initGameRolePlayHumanoidInformations(contextualId, look, disposition, name, humanoidInfo, accountId);
            this.alignmentInfos = alignmentInfos;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.alignmentInfos = new ActorAlignmentInformations();
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GameRolePlayCharacterInformations(output);
        }

        public function serializeAs_GameRolePlayCharacterInformations(output:ICustomDataOutput):void
        {
            super.serializeAs_GameRolePlayHumanoidInformations(output);
            this.alignmentInfos.serializeAs_ActorAlignmentInformations(output);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameRolePlayCharacterInformations(input);
        }

        public function deserializeAs_GameRolePlayCharacterInformations(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.alignmentInfos = new ActorAlignmentInformations();
            this.alignmentInfos.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.roleplay

