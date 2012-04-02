package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Advice extends FlxSprite 
	{
		
		[Embed(source = 'data/img_mouse_icon.png')] private const ImgMouseIcon:Class;
		
		private const MARGIN:int = 8;
		private const ACCELERATION:Number = 256;
		
		private var _text:FlxText;
		private var _icon:FlxSprite;
		
		private var _showPosition:Number;
		private var _hidePosition:Number;
		
		public function Advice()
		{
			super(0, -32);
			
			// create the background
			makeGraphic(FlxG.width, 32, 0x80000000);
			
			// do not scroll with camera
			scrollFactor.x = scrollFactor.y = 0;
			
			// create the icon
			_icon = new FlxSprite();
			_icon.loadGraphic(ImgMouseIcon, true, false, 16, 16);
			_icon.addAnimation("mouse_move", [3, 4, 5, 6, 2, 2, 2, 2, 6, 5, 4, 3, 2, 2, 2, 2], 10);
			_icon.addAnimation("mouse_click", [0, 1, 1, 1], 4);
			_icon.visible = false;
			
			// create the text
			_text = new FlxText(0, 0, width - MARGIN * 4 - _icon.width * 2);
			
			// not showing
			visible = false;
			
			// set up positions
			_showPosition = y + height;
			_hidePosition = y;
		}
		
		override public function update():void
		{
			// if showing
			if (visible)
			{
				// if moving down
				if (acceleration.y > 0)
				{
					// if past the show position
					if (y >= _showPosition)
					{
						// snap to the show position
						y = _showPosition;
						
						// stop moving
						stopMoving();
					}
				}
				// if moving up
				else if (acceleration.y < 0)
				{
					// if past the hide position
					if (y <= _hidePosition)
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
			
			// move the icon
			_icon.x = x + MARGIN;
			_icon.y = y + MARGIN;
			_icon.scrollFactor.x = scrollFactor.x;
			_icon.scrollFactor.y = scrollFactor.y;
			
			// draw the icon if it is visible
			if (_icon.visible) _icon.draw();
			
			// draw the text
			_text.x = _icon.x + _icon.width + MARGIN;
			_text.y = _icon.y;
			_text.scrollFactor.x = scrollFactor.x;
			_text.scrollFactor.y = scrollFactor.y;
			_text.draw();
			
		}
		
		public function show(Text:String = null, Icon:String = null):void
		{
			// play the open sound
			FlxG.play(Data.SndTextOpen);
			
			// stop moving
			stopMoving();
			
			// accelerate downward
			acceleration.y = ACCELERATION;
			
			// start showing
			visible = true;
			
			// if icon is specified
			if (Icon)
			{
				// show the icon
				_icon.visible = true;
				_icon.play(Icon);
				
				// put the text on the left
				_text.alignment = "left";
			}
			else
			{
				// hide the icon
				_icon.visible = false;
				
				// put the text in the center
				_text.alignment = "center";
			}
			
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
			
			// accelerate upward
			acceleration.y = -ACCELERATION;
		}
		
		private function stopMoving():void
		{
			// stop velocity and acceleration
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
		}
		
	}

}