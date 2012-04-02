package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Clock extends FlxSprite
	{
		
		public var ticking:Boolean;
		public var ringing:Boolean;
		public var forward:Boolean;
		public var callback:Function;
		
		[Embed(source = 'data/img_clock.png')] private const ImgClock:Class;
		
		private const ACCELERATION:Number = 128;
		
		private var _text:FlxText;
		
		private var _startTime:Number;
		private var _time:Number;
		private var _done:Boolean;
		private var _showPosition:Number;
		private var _hidePosition:Number;
		
		public function Clock()
		{
			super(0, 0);
			ticking = false;
			ringing = false;
			forward = true;
			callback = null;
			
			// load the clock graphic
			loadGraphic(ImgClock, true, false, 32, 16);
			
			// start in the center of the screen
			x = FlxG.width / 2 - width / 2;
			y = -height;
			
			// do not scroll with camera
			scrollFactor.x = scrollFactor.y = 0;
			
			// set up animations
			addAnimation("idle", [0]);
			addAnimation("flash", [1, 0], 4);
			addAnimation("red", [1]);
			
			// create the text
			_text = new FlxText(x, y, width);
			_text.alignment = "center";
			_text.offset.x = 1;
			_text.offset.y = -2;
			
			// not showing
			visible = false;
			
			// set up positions
			_showPosition = y + height;
			_hidePosition = y;
			
			// start at zero
			time = 0;
			
			// start idle
			play("idle");
		}
		
		override public function update():void
		{
			// if ticking
			if (ticking)
			{
				// advance timer
				_time += forward ? FlxG.elapsed : -FlxG.elapsed;
				
				// if ticking down past zero
				if (!forward && _time < 0)
				{
					// reset to zero and stop
					_time = 0;
					stop();
					
					// start ringing
					ringing = true;
					
					// call the callback if it exists
					if (callback != null) callback();
				}
				
				// refresh the text display
				refreshText();
			}
			
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
			}
			
			super.update();
		}
		
		override public function draw():void
		{
			super.draw();
			
			// draw the text
			_text.x = x;
			_text.y = y;
			_text.scrollFactor.x = scrollFactor.x;
			_text.scrollFactor.y = scrollFactor.y;
			_text.draw();
		}
		
		public function get startTime():Number
		{
			// return the start time
			return _startTime;
		}
		
		public function get time():Number
		{
			// return the current time
			return _time;
		}
		
		public function set time(Time:Number):void
		{
			// set the new time
			_startTime = Time;
			_time = Time;
			
			// refresh the text display
			refreshText();
		}
		
		public function hasPassed(Time:Number):Boolean
		{
			// if ticking forward
			if (forward)
			{
				// return whether the specified amount of time has passed yet
				return (_time >= Time);
			}
			else
			{
				// return whether the clock has ticked past the specified time
				return (_time <= Time);
			}
		}
		
		public function start(Time:Number = NaN):void
		{
			// if time is specified
			if (!isNaN(Time))
			{
				// set the new time
				time = Time;
			}
			
			// start ticking
			ticking = true;
			
			// stop ringing
			ringing = false;
		}
		
		public function stop():void
		{
			// stop ticking
			ticking = false;
			
			// stop ringing
			ringing = false;
		}
		
		public function show(Time:Number = NaN):void
		{
			// if time is specified
			if (!isNaN(Time))
			{
				// set the new time
				time = Time;
			}
			
			// stop moving
			stopMoving();
			
			// accelerate downward
			acceleration.y = ACCELERATION;
			
			// start showing
			visible = true;
		}
		
		public function hide():void 
		{
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
		
		private function refreshText():void
		{
			// convert the time to a string
			var timeString:String = FlxU.formatTime(time);
			
			// if the string is different
			if (timeString != _text.text)
			{
				// update the text
				_text.text = timeString;
			}
		}
		
	}

}