﻿package com.ankamagames.berilia.utils.web
{
    import flash.events.EventDispatcher;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.ProgressEvent;
    import flash.events.Event;

    [Event(name="complete", type="flash.events.Event")]
    public class HttpSocket extends EventDispatcher 
    {

        private static const SEPERATOR:RegExp = new RegExp(/\r?\n\r?\n/);
        private static const NL:RegExp = new RegExp(/\r?\n/);

        private var requestSocket:Socket;
        private var requestBuffer:ByteArray;
        private var _rootPath:String;

        public function HttpSocket(socket:Socket, rootPath:String)
        {
            this.requestSocket = socket;
            this.requestBuffer = new ByteArray();
            this.requestSocket.addEventListener(ProgressEvent.SOCKET_DATA, this.onRequestSocketData);
            this.requestSocket.addEventListener(Event.CLOSE, this.onRequestSocketClose);
            this._rootPath = rootPath;
        }

        public function get rootPath():String
        {
            return (this._rootPath);
        }

        private function onRequestSocketData(e:ProgressEvent):void
        {
            var headerString:String;
            var initialRequestSignature:String;
            var initialRequestSignatureComponents:Array;
            var method:String;
            var serverAndPath:String;
            var path:String;
            var httpResponser:HttpResponder;
            this.requestSocket.readBytes(this.requestBuffer, this.requestBuffer.length, this.requestSocket.bytesAvailable);
            var bufferString:String = this.requestBuffer.toString();
            var headerCheck:Number = bufferString.search(SEPERATOR);
            if (headerCheck != -1)
            {
                headerString = bufferString.substring(0, headerCheck);
                initialRequestSignature = headerString.substring(0, headerString.search(NL));
                initialRequestSignatureComponents = initialRequestSignature.split(" ");
                method = initialRequestSignatureComponents[0];
                serverAndPath = initialRequestSignatureComponents[1];
                serverAndPath = serverAndPath.replace(/^http(s)?:\/\//, "");
                path = serverAndPath.substring(serverAndPath.indexOf("/"), serverAndPath.length);
                httpResponser = new HttpResponder(this.requestSocket, method, path, this._rootPath);
            };
        }

        private function onRequestSocketClose(e:Event):void
        {
            this.done();
        }

        private function done():void
        {
            this.tearDown();
            var completeEvent:Event = new Event(Event.COMPLETE);
            this.dispatchEvent(completeEvent);
        }

        private function testSocket(socket:Socket):Boolean
        {
            if (!(socket.connected))
            {
                this.done();
                return (false);
            };
            return (true);
        }

        public function tearDown():void
        {
            if (((!((this.requestSocket == null))) && (this.requestSocket.connected)))
            {
                this.requestSocket.flush();
                this.requestSocket.close();
            };
        }


    }
}//package com.ankamagames.berilia.utils.web

