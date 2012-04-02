package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author knivel
	 */
	public class BouncyText extends FlxGroup
	{
		
		public static const THE_LOVE_LETTER:String = "^love*letter";
		public static const THE_END:String = "the end";
		
		private static const DELAY:Number = 0.25;
		private static const ACCELERATION:Number = 400;
		private static const SPACING:Number = 18;
		
		private var _timer:Number;
		private var _xTargets:Array;
		private var _currentIndex:int;
		
		public function BouncyText(Text:String, Y:Number = 0, FrameRate:Number = 8):void 
		{	
			super();
			_timer = 0;
			_currentIndex = 0;
			
			// set up array to hold end positions for character sprites
			_xTargets = new Array();
			
			// parse string into character sprites
			var char:String;
			var titleChar:BouncyCharacter;
			var i:int;
			var textWidth:Number = Text.length * SPACING;
			for (i = 0; i < Text.length; i++)
			{
				char = Text.charAt(i);
				if (char != " ")
				{
					titleChar = new BouncyCharacter(0, 0, char, i, FrameRate);
					titleChar.x = FlxG.width + i * SPACING;
					titleChar.y = Y;
					add(titleChar);
					_xTargets.push(Number(FlxG.width * 0.5 - textWidth * 0.5 + i * SPACING));
				}
			}
			animateCurrentChar();
		}
		
		private function animateCurrentChar():void
		{
			// skip if the current index is not valid
			if (_currentIndex < 0 || _currentIndex >= length) return;
			
			// get current character
			var char:BouncyCharacter = members[_currentIndex] as BouncyCharacter;
			
			// and set its acceleration
			char.acceleration.x = -ACCELERATION;
		}
		
		override public function update():void
		{
			super.update();
			
			var char:BouncyCharacter;
			var xPos:Number;
			for (var i:uint = 0; i < length; i++)
			{
				char = members[i] as BouncyCharacter;
				xPos = _xTargets[i] as Number;
				
				// if a character has arrive at its x target, stop it
				if (char.x <= xPos)
				{
					char.x = xPos;
					char.acceleration.x = char.velocity.x = 0;
				}
			}
			
			// advance timer
			_timer += FlxG.elapsed;
			
			// if timer has passed delay, animate next char
			if (_timer >= DELAY)
			{
				_timer -= DELAY;
				_currentIndex++;
				animateCurrentChar();
			}
		}
		
	}
	
}