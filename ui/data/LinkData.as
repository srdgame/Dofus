﻿package data
{
    import d2components.GraphicContainer;
    import flash.geom.Rectangle;
    import flash.geom.Point;

    public class LinkData 
    {

        public var text:String;
        public var href:String;
        public var page:String;
        private var _parent:GraphicContainer;
        private var _graphicContainer:GraphicContainer;

        public function LinkData(pTxt:String, pHref:String, pPage:String=""):void
        {
            this.text = pTxt;
            this.href = pHref.replace("event:", "");
            this.page = pPage;
        }

        public function setGraphicData(pCtr:GraphicContainer, pParent:GraphicContainer, pRect:Rectangle, pCtrPadding:Point):void
        {
            this._parent = pParent;
            this._graphicContainer = pCtr;
            this._graphicContainer.buttonMode = true;
            this._graphicContainer.x = (pRect.x + pCtrPadding.x);
            this._graphicContainer.y = (pRect.y + pCtrPadding.y);
            this._graphicContainer.width = pRect.width;
            this._graphicContainer.height = pRect.height;
            this._graphicContainer.bgColor = 0xFF0000;
            this._graphicContainer.alpha = 0;
            this._parent.addChild(this._graphicContainer);
        }

        public function get graphic():GraphicContainer
        {
            return (this._graphicContainer);
        }

        public function set parent(val:GraphicContainer):void
        {
            this._parent = val;
            this._parent.addChild(this._graphicContainer);
        }

        public function destroy():void
        {
            if (this._parent)
            {
                this._parent.removeChild(this._graphicContainer);
                this._parent = null;
            };
            this._graphicContainer.remove();
            this._graphicContainer = null;
        }


    }
}//package data

