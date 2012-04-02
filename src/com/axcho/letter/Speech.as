package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Speech extends FlxSprite
	{
		
		[Embed(source = 'data/img_player.png')] private const ImgSpeechIcon:Class;
		
		private const MARGIN:int = 8;
		private const PADDING:int = 16;
		private const ACCELERATION:Number = 512;
		
		private var _text:FlxText;
		private var _icon:FlxSprite;
		
		private var _showPosition:Number;
		private var _hidePosition:Number;
		
		public function Speech()
		{
			super(PADDING, FlxG.height);
			
			// create the background
			makeGraphic(FlxG.width - PADDING * 2, 32, 0x80000000);
			
			// do not scroll with camera
			scrollFactor.x = scrollFactor.y = 0;
			
			// create the icon
			_icon = new FlxSprite();
			_icon.loadGraphic(ImgSpeechIcon, true, false, 16, 16);
			_icon.addAnimation("idle", [0, 12], 4);
			_icon.play("idle");
			
			// create the text
			_text = new FlxText(0, 0, width - _icon.width - MARGIN * 2);
			
			// not showing
			visible = false;
			
			// set up positions
			_showPosition = FlxG.height - height - PADDING;
			_hidePosition = y;
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
					}
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
			
			// draw the text
			_text.x = _icon.x + _icon.width + MARGIN;
			_text.y = _icon.y;
			_text.scrollFactor.x = scrollFactor.x;
			_text.scrollFactor.y = scrollFactor.y;
			_text.draw();
		}
		
		public function show(Text:String = null):void
		{
			// play the open sound
			FlxG.play(Data.SndTextOpen);
			
			// stop moving
			stopMoving();
			
			// accelerate upward
			acceleration.y = -ACCELERATION;
			
			// start showing
			visible = true;
			
			// if text is specified
			if (Text != null)
			{
				// change the display text
				_text.text = Text;
			}
		}
		
		public function hide():void 
		{
			// play the close sound
			FlxG.play(Data.SndTextClose);
			
			// stop moving
			stopMoving();
			
			// accelerate downward
			acceleration.y = ACCELERATION;
		}
		
		private function stopMoving():void
		{
			// stop velocity and acceleration
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
		}
		
	}

}