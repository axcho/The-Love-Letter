package org.flixel.plugin.axcho 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	import org.flixel.FlxG;
	
	// got an error? just comment out the offending line
	//[Frame(extraClass = "mochi.as3.MochiServices")]
	//[Frame(extraClass = "com.newgrounds.API")]
	//[Frame(extraClass = "Playtomic.Log")]
	
	/**
	 * ...
	 * @author axcho
	 */
	public class FlxAPI
	{
		
		static public var kongregate:* = null;
		static public var mochi:* = null;
		static public var newgrounds:* = null;
		static public var playtomic:* = null;
		
		static public var mochiadsID:String = null;
		static public var mochibotID:String = null;
		static public var newgroundsID:String = null;
		static public var newgroundsEncryptionKey:String = null;
		static public var playtomicID:int = 0;
		static public var playtomicGUID:String = null;
		static public var playtomicAPIKey:String = null;
		
		static private var _parent:DisplayObjectContainer = null;
		
		static private var _url:String = "";
		
		static public function get url():String
		{
			return _url;
		}
		
		static public function connect(Parent:DisplayObjectContainer):void
		{
			// save the parent
			_parent = Parent;
			
			// if the parent is not yet on the stage
			if (!_parent.stage)
			{
				// wait to be added to the stage
				_parent.addEventListener(Event.ADDED_TO_STAGE, onStage);
				
				// skip the rest until later
				return;
			}
			
			// get the root object
			var root:DisplayObject = _parent.stage.root;
			
			// get the url of the domain this is hosted on
			var loaderInfo:LoaderInfo = root.loaderInfo;
			_url = loaderInfo.url;
			try
			{
				// get the loader info from Mochi Live Updates
				while (loaderInfo.loader != null) 
				{
					// get the loader info of the loader
					loaderInfo = loaderInfo.loader.loaderInfo;
				}
			}
			catch (error:Error)
			{
				// use the loader url if the above doesn't work
				_url = loaderInfo.loaderURL;
			}
			
			// if the domain is on Kongregate
			if (_url.indexOf("chat.kongregate.com/") >= 0)
			{
				// get the path for the Kongregate API
				var parameters:Object = loaderInfo.parameters;
				var path:String = parameters.api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
				
				// let the Kongregate API access this game
				Security.allowDomain(path);
				
				// load the Kongregate API
				var kongregateLoader:Loader = new Loader();
				kongregateLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadKongregate);
				kongregateLoader.load(new URLRequest(path));
				root.stage.addChild(kongregateLoader);
			}
			
			// if MochiAds ID is provided
			if (mochiadsID)
			{
				// get the Mochi API
				mochi = getDefinitionByName("mochi.as3.MochiServices");
				
				// connect to Mochi
				if (mochi) mochi.connect(mochiadsID, root);
			}
			
			// if MochiBot ID is provided
			if (mochibotID)
			{
				// track with MochiBot
				if (Security.sandboxType != "localWithFile")
				{
					Security.allowDomain("*");
					Security.allowInsecureDomain("*");
					var variables:URLVariables = new URLVariables();
					variables["sb"] = Security.sandboxType;
					variables["v"] = Capabilities.version;
					variables["swfid"] = mochibotID;
					variables["mv"] = "8";
					variables["fv"] = "9";
					if (_url.indexOf("http") == 0) variables["url"] = _url;
					else variables["url"] = "local";
					var request:URLRequest = new URLRequest("http://core.mochibot.com/my/core.swf");
					request.contentType = "application/x-www-form-urlencoded";
					request.method = URLRequestMethod.POST;
					request.data = variables;
					var mochibotLoader:Loader = new Loader();
					root.stage.addChild(mochibotLoader);
					mochibotLoader.load(request);
				}
			}
			
			// if Newgrounds ID and encryption key are provided
			if (newgroundsID && newgroundsEncryptionKey)
			{
				// get the Newgrounds API
				newgrounds = getDefinitionByName("com.newgrounds.API");
				
				// connect to Newgrounds
				if (newgrounds) newgrounds.connect(root, newgroundsID, newgroundsEncryptionKey);
			}
			
			// if Playtomic GUID and API key are provided
			if (playtomicGUID && playtomicAPIKey)
			{
				// get the Playtomic API
				playtomic = getDefinitionByName("Playtomic.Log");
				
				// connect to Playtomic
				if (playtomic) playtomic.View(playtomicID, playtomicGUID, playtomicAPIKey, _url);
			}
		}
		
		static private function onLoadKongregate(event:Event):void
		{
			// get the Kongregate API
			kongregate = event.target.content;
			
			// allow the API to access this game
			Security.allowDomain(kongregate.loaderInfo.url);
			
			// connect to Kongregate
			kongregate.services.connect();
		}
		
		static private function onStage(event:Event):void
		{
			// stop waiting to be added to the stage
			_parent.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			// try to connect again
			connect(_parent);
		}
		
	}

}