﻿package com.ankamagames.dofus.datacenter.alignments
{
    import com.ankamagames.jerakine.interfaces.IDataCenter;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import __AS3__.vec.Vector;
    import com.ankamagames.jerakine.data.GameData;
    import com.ankamagames.jerakine.data.I18n;

    public class AlignmentRank implements IDataCenter 
    {

        public static const MODULE:String = "AlignmentRank";
        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(AlignmentRank));

        public var id:int;
        public var orderId:uint;
        public var nameId:uint;
        public var descriptionId:uint;
        public var minimumAlignment:int;
        public var objectsStolen:int;
        public var gifts:Vector.<int>;
        private var _name:String;
        private var _description:String;


        public static function getAlignmentRankById(id:int):AlignmentRank
        {
            return ((GameData.getObject(MODULE, id) as AlignmentRank));
        }

        public static function getAlignmentRanks():Array
        {
            return (GameData.getObjects(MODULE));
        }


        public function get name():String
        {
            if (!(this._name))
            {
                this._name = I18n.getText(this.nameId);
            };
            return (this._name);
        }

        public function get description():String
        {
            if (!(this._description))
            {
                this._description = I18n.getText(this.descriptionId);
            };
            return (this._description);
        }


    }
}//package com.ankamagames.dofus.datacenter.alignments

