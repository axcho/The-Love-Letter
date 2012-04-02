package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Cover extends FlxSprite
	{
		private static const COLOR:uint = 0xff1b2632;
		private var _fading:Boolean;
		
		public function Cover()
		{
			super();
			
			// fill the screen
			makeGraphic(FlxG.width, FlxG.height, COLOR);
			
			// do not scroll with camera
			scrollFactor.x = scrollFactor.y = 0;
			
			// not fading
			_fading = false;
		}
		
		override public function update():void
		{
			// if showing
			if (visible)
			{
				// if fading out
				if (_fading)
				{
					// decrease alpha
					alpha -= FlxG.elapsed;
					
					// if done fading out
					if (alpha <= 0)
					{
						// stop fading
						_fading = false;
						
						// stop showing
						visible = false;
					}
				}
				// if still fading in
				else if (alpha < 1)
				{
					// increase alpha
					alpha += FlxG.elapsed;
				}
			}
			
			super.update();
		}
		
		public function show():void
		{
			// start showing
			visible = true;
			
			// not fading
			_fading = false;
		}
		
		public function hide():void 
		{
			// start fading
			_fading = true;
		}
		
	}

}