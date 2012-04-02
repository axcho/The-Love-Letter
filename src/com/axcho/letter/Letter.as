package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Letter extends FlxSprite
	{
		
		public var callback:Function;
		
		[Embed(source = 'data/txt_letter.txt', mimeType = 'application/octet-stream')] private const TxtLetter:Class;
		[Embed(source = 'data/img_letter_icon.png')] private const ImgLetterIcon:Class;
		
		private const MARGIN:int = 8;
		private const PADDING:int = 16;
		private const SCROLL_SPEED:Number = 8;
		private const ACCELERATION:Number = 1024;
		
		private var _text:FlxText;
		private var _mask:FlxSprite;
		private var _icon:FlxSprite;
		private var _music:FlxSound;
		
		private var _textScrollPixels:int;
		private var _textScroll:Number;
		private var _maxScroll:int;
		private var _scrolling:Boolean;
		private var _showPosition:Number;
		private var _hidePosition:Number;
		
		public function Letter()
		{
			super(PADDING, FlxG.height);
			callback = null;
			
			// create the background
			makeGraphic(FlxG.width - PADDING * 2, 48, 0x80000000);
			
			// do not scroll with camera
			scrollFactor.x = scrollFactor.y = 0;
			
			// load the music
			_music = FlxG.loadSound(Data.SndLetterMusic, 1.0, true);
			
			// create the icon
			_icon = new FlxSprite();
			_icon.loadGraphic(ImgLetterIcon, true, false, 16, 16);
			_icon.addAnimation("idle", [0, 1, 2, 1], 8);
			_icon.play("idle");
			
			// create the mask for the text
			_mask = new FlxSprite();
			_mask.makeGraphic(width - _icon.width - MARGIN * 2, height - MARGIN * 2, 0x00, true);
			
			// create the text
			var textString:String = new TxtLetter().toString();
			textString = textString.replace(/\r/g, "");
			_text = new FlxText(0, 0, _mask.width, textString);
			_textScroll = 0;
			_maxScroll = _text.height - _text.size * 2.5;
			
			// not showing
			_scrolling = false;
			visible = false;
			
			// set up positions
			_showPosition = y - FlxG.height / 2 - height / 2;
			_hidePosition = y;
			
			// refresh the text display
			refreshText();
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// destroy the music
			_music.destroy();
		}
		
		override public function update():void
		{
			// if showing
			if (visible)
			{
				// if moving up
				if (acceleration.y < 0)
				{
					// if past the show position
					if (y <= _showPosition)
					{
						// snap to the show position
						y = _showPosition;
						
						// stop moving
						stopMoving();
						
						// start scrolling
						_scrolling = true;
					}
				}
				// if moving down
				else if (acceleration.y > 0)
				{
					// if past the hide position
					if (y >= _hidePosition)
					{
						// snap to the hide position
						y = _hidePosition;
						
						// stop moving
						stopMoving();
						
						// no longer showing
						visible = false;
						
						// stop the letter music
						_music.stop();
					}
				}
				
				// if scrolling and not finished reading
				if (_scrolling && !finishedReading)
				{
					// scroll the text
					_textScroll += SCROLL_SPEED * FlxG.elapsed;
					
					// update the pixels
					pixelsRead = int(_textScroll);
				}
				
				// update the icon
				_icon.preUpdate();
				_icon.update();
				_icon.postUpdate();
			}
			
			super.update();
		}
		
		override public function draw():void
		{
			super.draw();
			
			// draw the icon
			_icon.x = x + MARGIN;
			_icon.y = y + MARGIN;
			_icon.scrollFactor.x = scrollFactor.x;
			_icon.scrollFactor.y = scrollFactor.y;
			_icon.draw();
			
			// draw the mask
			_mask.x = _icon.x + _icon.width + MARGIN;
			_mask.y = _icon.y;
			_mask.scrollFactor.x = scrollFactor.x;
			_mask.scrollFactor.y = scrollFactor.y;
			_mask.draw();
		}
		
		public function get scrolling():Boolean
		{
			// return whether letter is scrolling
			return _scrolling;
		}
		
		public function get finishedReading():Boolean
		{
			// return whether text has scrolled all the way up
			return _textScrollPixels >= _maxScroll;
		}
		
		public function get pixelsRead():int
		{
			// return how many pixels have been read
			return _textScrollPixels;
		}
		
		public function set pixelsRead(PixelsRead:int):void
		{
			// skip if already read this many pixels
			if (_textScrollPixels == PixelsRead) return;
			
			// set the number of pixels read
			_textScroll = _textScrollPixels = PixelsRead;
			
			// if finished reading
			if (finishedReading)
			{
				// snap to exact height
				_textScrollPixels = _maxScroll;
				
				// call the callback if it exists
				if (callback != null) callback();
			}
			
			// refresh the text display
			refreshText();
		}
		
		public function hasRead(Pixels:int):Boolean
		{
			// return whether the specified number of pixels have been read
			return _textScrollPixels >= Pixels;
		}
		
		public function show():void
		{
			// stop moving
			stopMoving();
			
			// accelerate upward
			acceleration.y = -ACCELERATION;
			
			// start showing
			visible = true;
			
			// fade out the background music
			if (FlxG.music) FlxG.music.fadeOut(1.0, true);
			
			// fade in the letter music
			_music.fadeIn(1.0);
		}
		
		public function hide():void 
		{
			// stop moving
			stopMoving();
			
			// accelerate downward
			acceleration.y = ACCELERATION;
			
			// stop scrolling
			_scrolling = false;
			
			// fade in the background music
			if (FlxG.music) FlxG.music.fadeIn(1.0);
			
			// fade out the letter music
			_music.fadeOut(1.0);
		}
		
		private function stopMoving():void
		{
			// stop velocity and acceleration
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
		}
		
		private function refreshText():void
		{
			// clear the mask canvas
			_mask.fill(0x00);
			
			// stamp the text onto the mask canvas
			_mask.stamp(_text, 0, -_textScrollPixels);
		}
		
	}

}