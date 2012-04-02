package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class SharePanel extends FlxGroup
	{
		
		[Embed(source = 'data/img_stumble.png')] private var ImgStumble:Class;
		[Embed(source = 'data/img_digg.png')] private var ImgDigg:Class;
		[Embed(source = 'data/img_reddit.png')] private var ImgReddit:Class;
		[Embed(source = 'data/img_delicious.png')] private var ImgDelicious:Class;
		[Embed(source = 'data/img_facebook.png')] private var ImgFacebook:Class;
		[Embed(source = 'data/img_twitter.png')] private var ImgTwitter:Class;
		
		private const TEXT_COLOR:uint = 0xffffffff;
		private const SHADOW_COLOR:uint = 0xff005784;
		private const BACKGROUND_COLOR:uint = 0xff1b2632;
		
		private var _stumbleButton:ShareButton;
		private var _diggButton:ShareButton;
		private var _redditButton:ShareButton;
		private var _deliciousButton:ShareButton;
		private var _facebookButton:ShareButton;
		private var _twitterButton:ShareButton;
		
		private var _helpText:FlxText;
		private var _helpBar:FlxSprite;
		
		private var _gameTitle:String;
		private var _gameURL:String;
		private var _scoreMessage:String;
		private var _caption:String;
		
		private var _clickCallback:Function;
		private var _hoverCallback:Function;
		
		public function SharePanel(GameTitle:String, GameURL:String, ScoreMessage:String, Caption:String, ClickCallback:Function=null, HoverCallback:Function=null)
		{
			super();
			_gameTitle = GameTitle;
			_gameURL = GameURL;
			_scoreMessage = ScoreMessage;
			_caption = Caption;
			_clickCallback = ClickCallback;
			_hoverCallback = HoverCallback;
			
			// add the bar at the bottom of the screen
			_helpBar = new FlxSprite();
			_helpBar.makeGraphic(FlxG.width, 48, BACKGROUND_COLOR);
			_helpBar.y = FlxG.height - _helpBar.height;
			add(_helpBar);
			
			// add the help text caption
			_helpText = new FlxText(_helpBar.x, _helpBar.y + 4, _helpBar.width, _caption + "!");
			_helpText.alignment = "center";
			_helpText.color = TEXT_COLOR;
			_helpText.shadow = SHADOW_COLOR;
			add(_helpText);
			
			// get the width of all the buttons together
			var spacing:Number = 32;
			var buttonsWidth:Number = spacing * (6 - 0.5);
			var buttonsX:Number = _helpBar.x + (_helpBar.width - buttonsWidth) / 2;
			var buttonsY:Number = _helpBar.y + _helpBar.height / 2;
			
			// set up stumble button
			_stumbleButton = new ShareButton(buttonsX + spacing * 0, buttonsY, ImgStumble, onStumbleClick);
			_stumbleButton.onOver = onStumbleOver;
			add(_stumbleButton);
			
			// set up digg button
			_diggButton = new ShareButton(buttonsX + spacing * 1, buttonsY, ImgDigg, onDiggClick);
			_diggButton.onOver = onDiggOver;
			add(_diggButton);
			
			// set up reddit button
			_redditButton = new ShareButton(buttonsX + spacing * 2, buttonsY, ImgReddit, onRedditClick);
			_redditButton.onOver = onRedditOver;
			add(_redditButton);
			
			// set up delicious button
			_deliciousButton = new ShareButton(buttonsX + spacing * 3, buttonsY, ImgDelicious, onDeliciousClick);
			_deliciousButton.onOver = onDeliciousOver;
			add(_deliciousButton);
			
			// set up facebook button
			_facebookButton = new ShareButton(buttonsX + spacing * 4, buttonsY, ImgFacebook, onFacebookClick);
			_facebookButton.onOver = onFacebookOver;
			add(_facebookButton);
			
			// set up twitter button
			_twitterButton = new ShareButton(buttonsX + spacing * 5, buttonsY, ImgTwitter, onTwitterClick);
			_twitterButton.onOver = onTwitterOver;
			add(_twitterButton);
		}
		
		override public function update():void 
		{
			super.update();
			
			// if the mouse is not on the support panel
			if (!overlapsPoint(FlxG.mouse.getScreenPosition()))
			{
				// set the caption
				_helpText.text = _caption + "!";
			}
		}
		
		public function overlapsPoint(Point:FlxPoint):Boolean
		{
			// return whether the help bar overlaps the point
			return _helpBar.overlapsPoint(Point);
		}
		
		private function onStumbleOver():void 
		{
			_helpText.text = _caption + " on StumbleUpon!";
		}
		
		private function onDiggOver():void 
		{
			_helpText.text = _caption + " on Digg!";
		}
		
		private function onRedditOver():void 
		{
			
			_helpText.text = _caption + " on Reddit!";
		}
		
		private function onDeliciousOver():void 
		{
			_helpText.text = _caption + " on Delicious!";
		}
		
		private function onFacebookOver():void 
		{
			_helpText.text = _caption + " on Facebook!";
		}
		
		private function onTwitterOver():void 
		{
			_helpText.text = _caption + " on Twitter!";
		}
		
		private function onStumbleClick():void 
		{
			// share on StumbleUpon
			FlxU.openURL("http://www.stumbleupon.com/submit?url=" + encodeURIComponent(_gameURL));
		}
		
		private function onDiggClick():void 
		{
			// share on Digg
			FlxU.openURL("http://digg.com/submit?url=" + encodeURIComponent(_gameURL) + "&title=" + encodeURIComponent(_gameTitle));
		}
		
		private function onRedditClick():void 
		{
			// share on Reddit
			FlxU.openURL("http://www.reddit.com/submit?url=" + encodeURIComponent(_gameURL));
		}
		
		private function onDeliciousClick():void 
		{
			// share on Delicious
			FlxU.openURL("http://delicious.com/save?v=5&noui&jump=close&url=" + encodeURIComponent(_gameURL) + "&title=" + encodeURIComponent(_gameTitle));
		}
		
		private function onFacebookClick():void 
		{
			// share on Facebook
			FlxU.openURL("http://www.facebook.com/sharer.php?u=" + encodeURIComponent(_gameURL) + "&t=" + encodeURIComponent(_gameTitle));
		}
		
		private function onTwitterClick():void 
		{
			// share on Twitter
			FlxU.openURL("http://twitter.com/home?status="+encodeURIComponent(((_scoreMessage) ? _scoreMessage : _gameTitle) + " " + _gameURL));
		}
		
	}
	
}