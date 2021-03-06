﻿package com.ankamagames.jerakine.logger.targets
{
    import flash.net.Socket;
    import com.ankamagames.jerakine.logger.LogEvent;
    import com.ankamagames.jerakine.logger.LogLevel;
    import flash.events.Event;

    public class CentralizeTarget extends AbstractTarget 
    {

        private static var _socket:Socket = new Socket();
        private static var _history:Array = new Array();
        private static var _connecting:Boolean = false;
        public static var serverHost:String = "chacha.ankama.lan";
        public static var serverPort:int = 6666;


        override public function logEvent(event:LogEvent):void
        {
            this.send(event.level, event.message);
        }

        private function send(level:uint, message:String):void
        {
            var _local_3:LoggerHistoryElement;
            if (_socket.connected)
            {
                _socket.writeUTF(((("(" + LogLevel.getString(level)) + ") ") + message));
            }
            else
            {
                if (!(_socket.hasEventListener("connect")))
                {
                    _socket.addEventListener("connect", this.onSocket);
                    _socket.addEventListener("ioError", this.onSocketError);
                    _socket.addEventListener("securityError", this.onSocketError);
                };
                if (!(_connecting))
                {
                    _socket.connect(serverHost, serverPort);
                    _connecting = true;
                };
                _local_3 = new LoggerHistoryElement(level, message);
                _history.push(_local_3);
            };
        }

        private function onSocket(e:Event):void
        {
            var o:LoggerHistoryElement;
            _connecting = false;
            for each (o in _history)
            {
                this.send(o.level, o.message);
            };
            _history = new Array();
        }

        private function onSocketError(e:Event):void
        {
            _connecting = false;
        }


    }
}//package com.ankamagames.jerakine.logger.targets

