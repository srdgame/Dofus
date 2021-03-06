﻿package com.ankamagames.dofus.network.messages.game.inventory.preset
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.inventory.preset.PresetItem;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class InventoryPresetItemUpdateMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 0x1818;

        private var _isInitialized:Boolean = false;
        public var presetId:uint = 0;
        public var presetItem:PresetItem;

        public function InventoryPresetItemUpdateMessage()
        {
            this.presetItem = new PresetItem();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (0x1818);
        }

        public function initInventoryPresetItemUpdateMessage(presetId:uint=0, presetItem:PresetItem=null):InventoryPresetItemUpdateMessage
        {
            this.presetId = presetId;
            this.presetItem = presetItem;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.presetId = 0;
            this.presetItem = new PresetItem();
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
            this.serializeAs_InventoryPresetItemUpdateMessage(output);
        }

        public function serializeAs_InventoryPresetItemUpdateMessage(output:ICustomDataOutput):void
        {
            if (this.presetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.presetId) + ") on element presetId.")));
            };
            output.writeByte(this.presetId);
            this.presetItem.serializeAs_PresetItem(output);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_InventoryPresetItemUpdateMessage(input);
        }

        public function deserializeAs_InventoryPresetItemUpdateMessage(input:ICustomDataInput):void
        {
            this.presetId = input.readByte();
            if (this.presetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.presetId) + ") on element of InventoryPresetItemUpdateMessage.presetId.")));
            };
            this.presetItem = new PresetItem();
            this.presetItem.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.preset

