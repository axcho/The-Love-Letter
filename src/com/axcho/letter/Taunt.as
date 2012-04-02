package com.axcho.letter 
{
	import org.flixel.*;
	import org.flixel.system.FlxAnim;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Taunt extends FlxSprite
	{
		
		[Embed(source = 'data/img_taunt.png')] private const ImgTaunt:Class;
		
		public var target:FlxObject;
		
		private var _timer:Number;
		
		public function Taunt(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			target = null;
			
			// load the taunt graphics
			loadGraphic(ImgTaunt, true, false, 16, 16);
			
			// set up bounding box
			offset.x = 8;
			offset.y = 20;
			width = 0;
			height = 0;
			
			// set up animations
			addAnimation("!", [0]);
			addAnimation("?", [1]);
			addAnimation(":|", [2]);
			addAnimation(":)", [3]);
			addAnimation(":(", [4]);
			addAnimation(":P", [5]);
			addAnimation(":D", [6]);
			addAnimation(":O", [7]);
			addAnimation(":3", [8]);
			addAnimation("wtf", [9]);
			addAnimation("omg", [10]);
			addAnimation("lol", [11]);
			addAnimation("hey", [12]);
			addAnimation("sup", [13]);
			addAnimation("yo", [14]);
			addAnimation("hi", [15]);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			
			// reset the timer
			_timer = 0;
		}
		
		override public function update():void
		{
			// if target exists
			if (target)
			{
				// move to target position
				x = target.x + target.width / 2;
				y = target.y;
			}
			
			// if timer is running
			if (_timer > 0)
			{
				// advance the timer
				_timer -= FlxG.elapsed;
				
				// if timer is up
				if (_timer <= 0)
				{
					// stop the timer
					_timer = 0;
					
					// hide the taunt
					hide();
				}
			}
			
			super.update();
		}
		
		public function show(TauntAnimation:String = null, Time:Number = 0, Target:FlxObject = null):void
		{
			// if taunt animation is not specified
			if (!TauntAnimation)
			{
				// pick a random animation
				var animation:FlxAnim = FlxG.getRandom(_animations) as FlxAnim;
				
				// use it as the taunt animation
				TauntAnimation = animation.name;
			}
			
			// start the new taunt animation
			play(TauntAnimation, true);
			
			// start the timer
			_timer = Time;
			
			// set the new target
			target = Target;
			
			// appear
			visible = true;
			exists = true;
		}
		
		public function hide():void
		{
			// stop the timer
			_timer = 0;
			
			// disappear
			visible = false;
			exists = false;
		}
		
	}

}