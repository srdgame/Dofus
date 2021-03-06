﻿package com.ankamagames.dofus.network.types.game.shortcut
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class ShortcutEmote extends Shortcut implements INetworkType 
    {

        public static const protocolId:uint = 389;

        public var emoteId:uint = 0;


        override public function getTypeId():uint
        {
            return (389);
        }

        public function initShortcutEmote(slot:uint=0, emoteId:uint=0):ShortcutEmote
        {
            super.initShortcut(slot);
            this.emoteId = emoteId;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.emoteId = 0;
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_ShortcutEmote(output);
        }

        public function serializeAs_ShortcutEmote(output:ICustomDataOutput):void
        {
            super.serializeAs_Shortcut(output);
            if ((((this.emoteId < 0)) || ((this.emoteId > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.emoteId) + ") on element emoteId.")));
            };
            output.writeByte(this.emoteId);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ShortcutEmote(input);
        }

        public function deserializeAs_ShortcutEmote(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.emoteId = input.readUnsignedByte();
            if ((((this.emoteId < 0)) || ((this.emoteId > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.emoteId) + ") on element of ShortcutEmote.emoteId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.types.game.shortcut

