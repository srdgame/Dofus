﻿package com.ankamagames.jerakine.resources.adapters.impl
{
    import com.ankamagames.jerakine.resources.adapters.AbstractUrlLoaderAdapter;
    import com.ankamagames.jerakine.resources.adapters.IAdapter;
    import nochump.util.zip.ZipFile;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.resources.ResourceType;
    import flash.net.URLLoaderDataFormat;

    public class ZipAdapter extends AbstractUrlLoaderAdapter implements IAdapter 
    {


        override protected function getResource(dataFormat:String, data:*)
        {
            return (new ZipFile((data as ByteArray)));
        }

        override public function getResourceType():uint
        {
            return (ResourceType.RESOURCE_ZIP);
        }

        override protected function getDataFormat():String
        {
            return (URLLoaderDataFormat.BINARY);
        }


    }
}//package com.ankamagames.jerakine.resources.adapters.impl

