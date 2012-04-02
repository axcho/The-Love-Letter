package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Person extends FlxSprite
	{
		
		public var taunt:Taunt;
		public var taunts:Taunts;
		
		protected var _idle:Boolean;
		protected var _stand:Boolean;
		
		public function Person(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			taunt = null;
			taunts = null;
			
			// set up animations
			addAnimation("stand_down", [0]);
			addAnimation("stand_right", [1]);
			addAnimation("stand_up", [2]);
			addAnimation("stand_left", [3]);
			addAnimation("idle_down", [0, 12], 4);
			addAnimation("idle_right", [1, 13], 4);
			addAnimation("idle_up", [2, 14], 4);
			addAnimation("idle_left", [3, 15], 4);
			addAnimation("walk_down", [0, 4, 0, 5], 8);
			addAnimation("walk_right", [1, 6, 1, 7], 8);
			addAnimation("walk_up", [2, 8, 2, 9], 8);
			addAnimation("walk_left", [3, 10, 3, 11], 8);
			addAnimation("show_letter", [0, 16, 17, 18], 8, false);
			addAnimation("hide_letter", [18, 17, 16, 0], 8, false);
		}
		
		override public function update():void
		{
			// if taunt no longer exists
			if (taunt && !taunt.exists)
			{
				// clear the taunt
				taunt = null;
			}
			
			// if following a path
			if (pathSpeed != 0)
			{
				// refresh the facing direction accordingly
				refreshFacing();
			}
			
			super.update();
		}
		
		override public function set facing(Facing:uint):void
		{
			// skip if already the same
			if (_facing == Facing) return;
			
			// set facing
			super.facing = Facing;
			
			// refresh the animation accordingly
			refreshAnimation();
		}
		
		public function get idle():Boolean
		{
			// return whether person is idle
			return _idle;
		}
		
		public function set idle(Idle:Boolean):void
		{
			// skip if already the same
			if (_idle == Idle) return;
			
			// set the new idle
			_idle = Idle;
			
			// refresh the animation accordingly
			refreshAnimation();
		}
		
		public function get stand():Boolean
		{
			// return whether person is standing
			return _stand;
		}
		
		public function set stand(Stand:Boolean):void
		{
			// skip if already the same
			if (_stand == Stand) return;
			
			// set the new stand
			_stand = Stand;
			
			// refresh the animation accordingly
			refreshAnimation();
		}
		
		public function enable():void
		{
			// be alive
			alive = true;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function disable():void
		{
			// be dead
			alive = false;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function say(TauntAnimation:String, Time:Number = 1):void
		{
			// if taunts exist and old taunt does not
			if (taunts && !taunt)
			{
				// add a taunt
				taunt = taunts.addTaunt(TauntAnimation, Time, this);
			}
		}
		
		public function talk(Time:Number = 2):void
		{
			// say a random emoticon
			say(FlxG.getRandom([":|", ":)", ":(", ":P", ":D", ":O", ":3"]) as String, Time);
		}
		
		public function tease(Time:Number = 2):void
		{
			// say a random teasing taunt
			say(FlxG.getRandom([":)", ":P", ":D", "wtf", "omg", "lol"]) as String, Time);
		}
		
		public function greet(Time:Number = 1):void
		{
			// say a random greeting taunt
			say(FlxG.getRandom(["hey", "sup", "yo", "hi"]) as String, Time);
		}
		
		public function resetBelow(Point:FlxPoint):void
		{
			// reset just below the given point
			reset(Point.x, Point.y + height);
		}
		
		public function face(Target:FlxObject):void
		{
			// get the center of the person
			getMidpoint(_point);
			
			// face toward the target
			pathAngle = FlxU.getAngle(_point, Target.getMidpoint());
			
			// refresh facing accordingly
			refreshFacing();
		}
		
		protected function refreshFacing():void
		{
			// adjust facing according to path angle
			if (pathAngle > -45 && pathAngle < 45)
			{
				facing = UP;
			}
			else if (pathAngle >= 45 && pathAngle < 135)
			{
				facing = RIGHT;
			}
			else if (pathAngle > -135 && pathAngle <= -45)
			{
				facing = LEFT;
			}
			else
			{
				facing = DOWN;
			}
		}
		
		protected function refreshAnimation():void
		{
			// change animation according to facing and idle
			switch (_facing) 
			{
				case DOWN:
					play((_stand) ? "stand_down" : (_idle) ? "idle_down" : "walk_down");
				break;
				case RIGHT:
					play((_stand) ? "stand_right" : (_idle) ? "idle_right" : "walk_right");
				break;
				case UP:
					play((_stand) ? "stand_up" : (_idle) ? "idle_up" : "walk_up");
				break;
				case LEFT:
					play((_stand) ? "stand_left" : (_idle) ? "idle_left" : "walk_left");
				break;
			}
		}
		
	}

}