package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Player extends Person
	{
		
		public var target:FlxObject;
		public var tilemap:FlxTilemap;
		public var cursor:Cursor;
		public var letter:Letter;
		
		public var allowWalking:Boolean;
		public var allowReading:Boolean;
		
		[Embed(source = 'data/img_player.png')] private const ImgPlayer:Class;
		
		private const SPEED:Number = 64;
		private const RANGE:Number = 8;
		
		private var _mousePoint:FlxPoint;
		private var _mouseScreenPoint:FlxPoint;
		private var _followMouse:Boolean;
		
		public function Player(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			target = null;
			tilemap = null;
			cursor = null;
			letter = null;
			allowWalking = true;
			allowReading = true;
			
			_mousePoint = new FlxPoint();
			_mouseScreenPoint = new FlxPoint();
			
			// load the player graphics
			loadGraphic(ImgPlayer, true, false, 16, 16);
			
			// set up friction
			drag.x = drag.y = 256;
			
			// set up bounding box
			offset.x = 3;
			offset.y = 8;
			width = 9;
			height = 8;
			
			// set up animations
			addAnimation("show_blush", [0, 19, 20, 21, 22, 23, 24], 16, false);
			addAnimation("hide_blush", [24, 23, 22, 21, 20, 19, 0], 16, false);
			
			// reset
			reset(X, Y);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			// start by facing down
			facing = DOWN;
			
			// follow the mouse
			_followMouse = true;
			
			super.reset(X - width / 2, Y - height / 2);
		}
		
		override public function update():void
		{
			// if alive and allowed to read
			if (alive && allowReading)
			{
				// if mouse button or equivalent key was just pressed
				if (FlxG.mouse.justPressed() ||
					FlxG.keys.justPressed("SPACE") ||
					FlxG.keys.justPressed("ENTER"))
				{
					// show the letter
					showLetter();
				}
				// if mouse button or equivalent key was just released
				else if (FlxG.mouse.justReleased() ||
						FlxG.keys.justReleased("SPACE") ||
						FlxG.keys.justReleased("ENTER"))
				{
					// hide the letter
					hideLetter();
				}
			}
			
			// if following the mouse
			if (_followMouse)
			{
				// if a keyboard key was just pressed
				if (FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("ENTER") ||
					FlxG.keys.justPressed("DOWN") || FlxG.keys.justPressed("S") ||
					FlxG.keys.justPressed("RIGHT") || FlxG.keys.justPressed("D") ||
					FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("W") ||
					FlxG.keys.justPressed("LEFT") || FlxG.keys.justPressed("A"))
				{
					// do not follow the mouse
					_followMouse = false;
				}
			}
			else
			{
				// get the current mouse screen position
				_point.make(FlxG.mouse.screenX, FlxG.mouse.screenY);
				
				// get the distance from the last mouse screen position
				var mouseScreenDistance:Number = FlxU.getDistance(_point, _mouseScreenPoint);
				
				// if the mouse button was just pressed or moved beyond range
				if (FlxG.mouse.justPressed() || mouseScreenDistance >= RANGE)
				{
					// follow the mouse
					_followMouse = true;
				}
			}
			
			// be immovable if reading the letter or not alive or not allowed to walk
			immovable = reading || !alive || !allowWalking || FlxG.mouse.pressed();
			
			// if immovable or should not follow the mouse
			if (immovable || !_followMouse)
			{
				// hide the cursor
				if (cursor) cursor.arrow();
				
				// stop moving?
				velocity.x = velocity.y = pathSpeed = 0;
				
				// if not immovable
				if (!immovable)
				{
					// if pressing down
					if (FlxG.keys.DOWN || FlxG.keys.S)
					{
						// set velocity downward
						velocity.y++;
					}
					
					// if pressing up
					if (FlxG.keys.UP || FlxG.keys.W)
					{
						// set velocity upward
						velocity.y--;
					}
					
					// if pressing right
					if (FlxG.keys.RIGHT || FlxG.keys.D)
					{
						// set velocity rightward
						velocity.x++;
					}
					
					// if pressing left
					if (FlxG.keys.LEFT || FlxG.keys.A)
					{
						// set velocity leftward
						velocity.x--;
					}
					
					// check whether moving or not
					idle = (velocity.x == 0 && velocity.y == 0);
					
					// if moving
					if (!idle)
					{
						// set path speed
						pathSpeed = SPEED;
						
						// set path angle
						pathAngle = FlxU.getAngle(_pZero, velocity);
						
						// set velocity according to angle and speed
						FlxU.rotatePoint(0, pathSpeed, 0, 0, pathAngle, velocity);
					}
				}
			}
			// if should follow the mouse
			else if (_followMouse)
			{
				// save the screen position of the mouse
				_mouseScreenPoint.x = FlxG.mouse.screenX;
				_mouseScreenPoint.y = FlxG.mouse.screenY;
				
				// get the center point of the player
				getMidpoint(_point);
				
				// get the distance from the mouse cursor
				var mouseDistance:Number = FlxU.getDistance(_point, FlxG.mouse);
				
				// if distance is beyond minimum range
				if (mouseDistance >= RANGE)
				{
					// if the tilemap exists
					if (tilemap)
					{
						// if the mouse has moved since the last time
						if (_mousePoint.x != FlxG.mouse.x || _mousePoint.y != FlxG.mouse.y)
						{
							// if the mouse is within the tilemap
							if (FlxG.mouse.x >= tilemap.x &&
								FlxG.mouse.y >= tilemap.y &&
								FlxG.mouse.x <= tilemap.x + tilemap.width &&
								FlxG.mouse.y <= tilemap.y + tilemap.height)
							{
								// if the mouse is over a wall
								if (tilemap.overlapsPoint(FlxG.mouse))
								{
									// if the path is not directly to the mouse
									if (path && path.head() != FlxG.mouse)
									{
										// stop following the path
										stopFollowingPath(true);
									}
								}
								else
								{
									// destroy the old path if it exists
									if (path) path.destroy();
									
									// find a new path to the mouse
									path = tilemap.findPath(_point, FlxG.mouse);
									
									// if the path has more than one node
									if (path.nodes.length > 1)
									{
										// remove the first node
										path.remove(path.head());
									}
									
									// follow the path
									followPath(path, SPEED);
									
									// save the mouse position
									_mousePoint.copyFrom(FlxG.mouse);
								}
							}
						}
					}
					
					// if path does not exist
					if (!path)
					{
						// create a new path directly to the mouse
						followPath(new FlxPath([FlxG.mouse]), SPEED);
					}
					
					// set the path speed again
					pathSpeed = SPEED;
				}
				else
				{
					// do not face toward mouse cursor
					pathSpeed = 0;
				}
				
				// check whether moving or not
				idle = (velocity.x == 0 && velocity.y == 0);
				
				// if the cursor exists
				if (cursor)
				{
					// show the cursor
					cursor.visible = true;
					
					// if walking
					if (pathSpeed > 0)
					{
						// show the cursor for walking
						cursor.walk();
					}
					else
					{
						// show the cursor for idle
						cursor.idle();
					}
				}
			}
			
			super.update();
		}
		
		public function get reading():Boolean
		{
			// return whether the letter is showing
			return (letter && letter.visible);
		}
		
		public function enableWalking():void
		{
			// allow walking
			allowWalking = true;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function disableWalking():void
		{
			// disallow walking
			allowWalking = false;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function enableReading():void
		{
			// allow reading
			allowReading = true;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function disableReading():void
		{
			// disallow reading
			allowReading = false;
			
			// refresh animation
			refreshAnimation();
		}
		
		public function showLetter(Animate:Boolean = true):void
		{
			// skip if letter does not exist
			if (!letter) return;
			
			// stop moving
			stopMoving();
			
			// play the letter showing animation
			if (Animate) play("show_letter");
			
			// show the letter
			letter.show();
		}
		
		public function hideLetter(Animate:Boolean = true):void
		{
			// skip if letter does not exist or is already hidden
			if (!(letter && letter.visible)) return;
			
			// stop moving
			stopMoving();
			
			// play the letter hiding animation
			if (Animate) play("hide_letter");
			
			// hide the letter
			letter.hide();
		}
		
		public function stopMoving():void
		{
			// face down
			facing = DOWN;
			
			// be idle
			idle = true;
			
			// do not face toward mouse cursor
			pathSpeed = 0;
			
			// stop velocity
			velocity.x = velocity.y = 0;
		}
		
	}

}