﻿package com.ankamagames.jerakine.resources.protocols.impl
{
    import com.ankamagames.jerakine.resources.protocols.IProtocol;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import flash.utils.Dictionary;
    import __AS3__.vec.Vector;
    import com.ankamagames.jerakine.utils.crypto.CRC32;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.resources.protocols.AbstractFileProtocol;
    import com.ankamagames.jerakine.utils.system.AirScanner;
    import com.ankamagames.jerakine.data.XmlConfig;
    import com.ankamagames.jerakine.types.Uri;
    import com.ankamagames.jerakine.resources.IResourceObserver;
    import com.ankamagames.jerakine.newCache.ICache;
    import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import com.ankamagames.jerakine.resources.adapters.impl.BinaryAdapter;
    import com.ankamagames.jerakine.resources.ResourceObserverWrapper;
    import flash.utils.getTimer;
    import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSwfAdapter;
    import __AS3__.vec.*;

    public class HttpCacheProtocol implements IProtocol 
    {

        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(HttpCacheProtocol));
        private static const LIMITE_ATTEMPT_FOR_DOWNLOAD:uint = 2;
        private static const CACHE_FORMAT_VERSION:String = "1.0";
        private static const CACHE_FORMAT_TYPE:String = "D2S";
        private static var _cacheFilesDirectory:String;
        private static var _cachedFileData:Dictionary;
        private static var _calcCachedFileData:Dictionary = new Dictionary(true);
        private static var _pathCrcList:Dictionary = new Dictionary();
        private static var _dataLoading:Dictionary = new Dictionary(true);
        private static var _httpDataToLoad:Vector.<Object> = new Vector.<Object>();
        private static var _fileDataToLoad:Vector.<Object> = new Vector.<Object>();
        private static var _attemptToDownloadFile:Dictionary = new Dictionary(true);
        private static var _totalCrcTime:int = 0;
        private static var _crc:CRC32 = new CRC32();
        private static var _buff_crc:ByteArray = new ByteArray();
        private static var _urlRewritePattern;
        private static var _urlRewriteReplace;
        private static var _remoteLoadingErrorHandler;
        private static var _pendingFail:Vector.<PendingFail>;
        private static const REMOTE_MIN_CHECK_INTERVAL:int = 10000;

        private var _parent:AbstractFileProtocol;
        private var _serverRootDir:String;
        private var _serverRootUnversionedDir:String;
        private var _isLoadingFilelist:Boolean = false;
        private var _lastRemoteCheckTimestamp:Number = 0;

        public function HttpCacheProtocol()
        {
            if (AirScanner.hasAir())
            {
                this._parent = new FileProtocol();
            }
            else
            {
                this._parent = new FileFlashProtocol();
            };
        }

        public static function init(replacePattern:*, replaceNeedle:*, remoteLoadingErrorHandler:Function=null):void
        {
            _urlRewritePattern = replacePattern;
            _urlRewriteReplace = replaceNeedle;
            _remoteLoadingErrorHandler = remoteLoadingErrorHandler;
        }


        public function load(uri:Uri, observer:IResourceObserver, dispatchProgress:Boolean, cache:ICache, forcedAdapter:Class, singleFile:Boolean):void
        {
            if (this._serverRootDir == null)
            {
                this.serverRootDir = XmlConfig.getInstance().getEntry("config.root.path");
            };
            if ((((_cacheFilesDirectory == "")) || (!(_cacheFilesDirectory))))
            {
                _cacheFilesDirectory = XmlConfig.getInstance().getEntry("config.streaming.filelists.directory");
            };
            if (_cachedFileData == null)
            {
                this.loadCacheFile();
            };
            if (!(this._isLoadingFilelist))
            {
                if (_dataLoading[this.getLocalPath(uri)] != null)
                {
                    _fileDataToLoad.push({
                        "uri":uri,
                        "observer":observer,
                        "dispatchProgress":dispatchProgress,
                        "adapter":forcedAdapter
                    });
                }
                else
                {
                    this.loadFile(uri, observer, dispatchProgress, forcedAdapter);
                };
            }
            else
            {
                if (this.uriIsAlreadyWaitingForHttpDownload(uri))
                {
                    _fileDataToLoad.push({
                        "uri":uri,
                        "observer":observer,
                        "dispatchProgress":dispatchProgress,
                        "adapter":forcedAdapter
                    });
                }
                else
                {
                    _httpDataToLoad.push({
                        "uri":uri,
                        "observer":observer,
                        "dispatchProgress":dispatchProgress,
                        "adapter":forcedAdapter
                    });
                };
            };
        }

        private function uriIsAlreadyWaitingForHttpDownload(uri:Uri):Boolean
        {
            var data:Object;
            for each (data in _httpDataToLoad)
            {
                if (data.uri.path == uri.path)
                {
                    return (true);
                };
            };
            return (false);
        }

        private function loadCacheFile():void
        {
            var data:ByteArray;
            var fs:FileStream;
            var index:int;
            var value:int;
            var streamingFile:File;
            var dirListing:Array;
            this._isLoadingFilelist = true;
            var streamingFilelists:File = new File(((File.applicationDirectory + File.separator) + _cacheFilesDirectory));
            if (((streamingFilelists.exists) && (streamingFilelists.isDirectory)))
            {
                _cachedFileData = new Dictionary();
                data = new ByteArray();
                dirListing = streamingFilelists.getDirectoryListing();
                for each (streamingFile in dirListing)
                {
                    data.clear();
                    fs = new FileStream();
                    fs.open(streamingFile, FileMode.READ);
                    fs.readBytes(data, 0, 4);
                    data.readByte();
                    if (data.readMultiByte(3, "utf-8") != CACHE_FORMAT_TYPE)
                    {
                        throw (new Error("Format du fichier incorrect !!"));
                    };
                    data.clear();
                    fs.readBytes(data, 0, 4);
                    data.readByte();
                    if (data.readMultiByte(3, "utf-8") != CACHE_FORMAT_VERSION)
                    {
                        throw (new Error("Version du format de fichier incorrect !!"));
                    };
                    while (fs.bytesAvailable)
                    {
                        index = fs.readInt();
                        value = fs.readInt();
                        _cachedFileData[index] = value;
                    };
                    fs.close();
                };
            }
            else
            {
                _log.fatal("Impossible de charger les fichiers de streaming !!");
            };
            this._isLoadingFilelist = false;
            if (_httpDataToLoad.length > 0)
            {
                this.loadQueueData();
            };
        }

        private function loadQueueData():void
        {
            var file:Object;
            for each (file in _httpDataToLoad)
            {
                this.loadFile(file.uri, file.observer, file.dispatchProgress, file.adapter);
            };
            _httpDataToLoad = new Vector.<Object>();
        }

        private function loadFile(uri:Uri, observer:IResourceObserver, dispatchProgress:Boolean, adapter:Class):void
        {
            var data:ByteArray;
            var pathForCrc:String;
            var arrayIndex:int;
            var cachedCrcFile:int;
            var stream:FileStream;
            var path:String = this.getLocalPath(uri);
            trace(("load file " + path));
            if (_dataLoading[path] != null)
            {
                _fileDataToLoad.push({
                    "uri":uri,
                    "observer":observer,
                    "dispatchProgress":dispatchProgress,
                    "adapter":adapter
                });
                return;
            };
            var file:File = new File(path);
            if (file.exists)
            {
                data = new ByteArray();
                pathForCrc = this.getPathForCrc(uri);
                if (_pathCrcList[pathForCrc] == null)
                {
                    _pathCrcList[pathForCrc] = this.getPathIntSum(pathForCrc);
                };
                arrayIndex = _pathCrcList[pathForCrc];
                if (_calcCachedFileData[arrayIndex] == null)
                {
                    stream = new FileStream();
                    stream.open(file, FileMode.READ);
                    stream.readBytes(data, 0, file.size);
                    stream.close();
                    _calcCachedFileData[arrayIndex] = this.getFileIntSum(data);
                };
                cachedCrcFile = 0;
                if (((!((_calcCachedFileData == null))) && (!((_calcCachedFileData[arrayIndex] == null)))))
                {
                    cachedCrcFile = _calcCachedFileData[arrayIndex];
                };
                if (((((!((_cachedFileData == null))) && ((cachedCrcFile == _cachedFileData[arrayIndex])))) && (!((cachedCrcFile == 0)))))
                {
                    _log.debug((uri + " a jour: "));
                    this.loadFromParent(uri, observer, dispatchProgress, adapter);
                }
                else
                {
                    _log.debug((uri.path + " mise a jour necessaire"));
                    _dataLoading[path] = {
                        "uri":uri,
                        "observer":observer,
                        "dispatchProgress":dispatchProgress,
                        "adapter":adapter
                    };
                    this.loadDirectlyUri(uri, dispatchProgress);
                };
            }
            else
            {
                _log.debug((uri + " inexistant"));
                _dataLoading[path] = {
                    "uri":uri,
                    "observer":observer,
                    "dispatchProgress":dispatchProgress,
                    "adapter":adapter
                };
                this.loadDirectlyUri(uri, dispatchProgress);
            };
        }

        private function loadDirectlyUri(uri:Uri, dispatchProgress:Boolean):void
        {
            _attemptToDownloadFile[uri] = (((_attemptToDownloadFile[uri] == null)) ? 1 : (_attemptToDownloadFile[uri] + 1));
            var realPath:String = ("http://" + uri.path);
            if (_urlRewritePattern)
            {
                realPath = realPath.replace(_urlRewritePattern, _urlRewriteReplace);
            };
            this._parent.initAdapter(uri, BinaryAdapter);
            this._parent.adapter.loadDirectly(uri, realPath, new ResourceObserverWrapper(this.onRemoteFileLoaded, this.onRemoteFileFailed, this.onRemoteFileProgress), dispatchProgress);
        }

        private function onRemoteFileLoaded(uri:Uri, resourceType:uint, resource:*):void
        {
            var path:String;
            if (!(AirScanner.isStreamingVersion()))
            {
                path = this.getLocalPath(uri);
            }
            else
            {
                path = this.getPathWithoutAkamaiHack(this.getLocalPath(uri));
            };
            var f:File = new File(path);
            var fileStream:FileStream = new FileStream();
            fileStream.open(f, FileMode.WRITE);
            fileStream.position = 0;
            fileStream.writeBytes(resource);
            fileStream.close();
            if (_dataLoading[path] != null)
            {
                this.loadFromParent(_dataLoading[path].uri, _dataLoading[path].observer, _dataLoading[path].dispatchProgress, _dataLoading[path].adapter);
                _dataLoading[path] = null;
            };
        }

        private function removeNullValue(item:Object, index:int, vector:Vector.<Object>):Boolean
        {
            return (!((item == null)));
        }

        public function getLocalPath(uri:Uri):String
        {
            var newuri:String = uri.normalizedUri.split("|")[0];
            newuri = newuri.replace(this._serverRootDir, "");
            newuri = newuri.replace(this._serverRootUnversionedDir, "");
            return (((File.applicationDirectory.nativePath + File.separator) + newuri));
        }

        public function getPathWithoutAkamaiHack(inStr:String):String
        {
            var pattern:RegExp = /\/(_[0-9]*_\/)/i;
            return (inStr.replace(pattern, "/"));
        }

        private function onRemoteFileFailed(uri:Uri, errorMsg:String, errorCode:uint, canQueue:Boolean=true):void
        {
            var path:String;
            if (((_pendingFail) && (canQueue)))
            {
                _log.warn((((uri.path + ": download failed (") + errorMsg) + "), wait for remote check"));
                _pendingFail.push(new PendingFail(uri, errorMsg, errorCode));
                return;
            };
            _log.warn((((uri.path + ": download failed (") + errorMsg) + ")"));
            if (((!((_attemptToDownloadFile[uri] == null))) && ((_attemptToDownloadFile[uri] <= LIMITE_ATTEMPT_FOR_DOWNLOAD))))
            {
                _log.warn((uri.path + ": try again"));
                if (!(AirScanner.isStreamingVersion()))
                {
                    path = this.getLocalPath(uri);
                }
                else
                {
                    path = this.getPathWithoutAkamaiHack(this.getLocalPath(uri));
                };
                this.loadDirectlyUri(uri, _dataLoading[path].dispatchProgress);
            }
            else
            {
                if (((((canQueue) && (!((_remoteLoadingErrorHandler == null))))) && (((getTimer() - this._lastRemoteCheckTimestamp) > REMOTE_MIN_CHECK_INTERVAL))))
                {
                    _log.warn((((uri.path + ": download failed (") + errorMsg) + "), wait for remote check (1ft)"));
                    this._lastRemoteCheckTimestamp = getTimer();
                    _pendingFail = new Vector.<PendingFail>();
                    _pendingFail.push(new PendingFail(uri, errorMsg, errorCode));
                    _remoteLoadingErrorHandler(this.onRemoteLoadingErrorHandlerResponse);
                }
                else
                {
                    this.definitiveFail(uri, errorMsg, errorCode);
                };
            };
        }

        private function onRemoteLoadingErrorHandlerResponse(settingsChanged:Boolean):void
        {
            var pf:PendingFail;
            for each (pf in _pendingFail)
            {
                if (settingsChanged)
                {
                    _attemptToDownloadFile[pf.uri] = 0;
                    this.onRemoteFileFailed(pf.uri, pf.errorMsg, pf.errorCode, false);
                }
                else
                {
                    this.definitiveFail(pf.uri, pf.errorMsg, pf.errorCode);
                };
            };
        }

        private function definitiveFail(uri:Uri, errorMsg:String, errorCode:uint):void
        {
            _log.warn((((uri.path + ": download definitively failed (") + errorMsg) + ")"));
            var data:* = _dataLoading[uri];
            if (((data) && (data.observer)))
            {
                IResourceObserver(data.observer).onFailed(uri, errorMsg, errorCode);
            };
        }

        private function onRemoteFileProgress(uri:Uri, bytesLoaded:uint, bytesTotal:uint):void
        {
        }

        private function loadFromParent(uri:Uri, observer:IResourceObserver, dispatchProgress:Boolean, adapter:Class):void
        {
            var d:Object;
            var i:uint;
            var oldUri:Uri = uri;
            var oldUriPath:String = oldUri.path;
            if (uri.fileType == "swf")
            {
                uri = new Uri(this.getLocalPath(uri));
                uri.tag = oldUri;
                adapter = AdvancedSwfAdapter;
            }
            else
            {
                if (uri.fileType == "swl")
                {
                    uri = new Uri(this.getLocalPath(uri));
                    if (uri.tag == null)
                    {
                        uri.tag = new Object();
                    };
                    uri.tag.oldUri = oldUri;
                }
                else
                {
                    uri = new Uri(this.getLocalPath(uri));
                    uri.tag = oldUri;
                };
            };
            this._parent.load(uri, observer, dispatchProgress, null, adapter, false);
            var l:uint = _fileDataToLoad.length;
            i = 0;
            while (i < l)
            {
                d = _fileDataToLoad[i];
                if (((d) && ((((d.uri.path == uri.path)) || ((d.uri.path == oldUriPath))))))
                {
                    this._parent.load(uri, d.observer, d.dispatchProgress, null, d.adapter, false);
                    _fileDataToLoad[i] = null;
                };
                i++;
            };
            _fileDataToLoad = _fileDataToLoad.filter(this.removeNullValue);
        }

        private function getPathIntSum(path:String):int
        {
            _buff_crc.clear();
            _buff_crc.writeUTFBytes(path);
            _crc.reset();
            _crc.update(_buff_crc);
            return (_crc.getValue());
        }

        private function getPathForCrc(uri:Uri):String
        {
            return (uri.normalizedUri.replace(this._serverRootDir, "").replace(this._serverRootUnversionedDir, ""));
        }

        private function getFileIntSum(data:ByteArray):int
        {
            _crc.reset();
            _crc.update(data);
            return (_crc.getValue());
        }

        public function cancel():void
        {
            this._parent.cancel();
        }

        public function free():void
        {
            this._parent.free();
        }

        public function set serverRootDir(value:String):void
        {
            this._serverRootDir = value;
            this._serverRootUnversionedDir = value.replace(/\/_[0-9]*_/, "");
        }


    }
}//package com.ankamagames.jerakine.resources.protocols.impl

import com.ankamagames.jerakine.types.Uri;

class PendingFail 
{

    public var uri:Uri;
    public var errorMsg:String;
    public var errorCode:uint;

    public function PendingFail(uri:Uri, errorMsg:String, errorCode:uint)
    {
        this.uri = uri;
        this.errorMsg = errorMsg;
        this.errorCode = errorCode;
    }

}

