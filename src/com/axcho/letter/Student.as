package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Student extends Person
	{
		
		static public const IDLE:uint = 0;
		static public const TALK:uint = 1;
		static public const WANDER:uint = 2;
		static public const TRAVEL:uint = 3;
		static public const FOLLOW:uint = 4;
		static public const PURSUE:uint = 5;
		
		public var target:FlxObject;
		public var tilemap:FlxTilemap;
		public var students:Students;
		
		[Embed(source = 'data/img_student_01.png')] protected const ImgStudent01:Class;
		[Embed(source = 'data/img_student_02.png')] protected const ImgStudent02:Class;
		[Embed(source = 'data/img_student_03.png')] protected const ImgStudent03:Class;
		[Embed(source = 'data/img_student_04.png')] protected const ImgStudent04:Class;
		protected const ImgStudents:Array = [ImgStudent01, ImgStudent02, ImgStudent03, ImgStudent04];
		
		protected const IDLE_DRAG:Number = 256;
		protected const IDLE_TIME_MIN:Number = 0.5;
		protected const IDLE_TIME_MAX:Number = 2.0;
		protected const TALK_TIME_MIN:Number = 0.5;
		protected const TALK_TIME_MAX:Number = 2.0;
		protected const TALK_RANGE_MIN:Number = 8;
		protected const TALK_RANGE_MAX:Number = 24;
		protected const WANDER_SPEED:Number = 24;
		protected const TRAVEL_SPEED:Number = 48;
		protected const FOLLOW_SPEED:Number = 32;
		protected const FOLLOW_RANGE:Number = 32;
		protected const FOLLOW_LIMIT:uint = 8;
		protected const PURSUE_SPEED:Number = 48;
		protected const PURSUE_RANGE:Number = 8;
		protected const PURSUE_LIMIT:uint = 8;
		
		protected const HAIR_COLOR:uint = 0xffa3ce27;
		protected const SKIN_COLOR:uint = 0xfff7e26b;
		protected const HAIR_AND_SKIN_COLORS:Array =
		[
			{ hair:0xffa46422, skin:0xfff7e26b }, // brown hair, fair skin
			{ hair:0xfff7e26b, skin:0xfff7e26b }, // blonde hair, fair skin
			{ hair:0xffeb8931, skin:0xfff7e26b }, // orange hair, fair skin
			{ hair:0xff493c2b, skin:0xffa46422 } // dark brown hair, brown skin
		];
		
		protected var _talkers:Array;
		
		protected var _state:uint;
		protected var _timer:Number;
		protected var _followTimer:int;
		protected var _followPoint:FlxPoint;
		protected var _targetPoint:FlxPoint;
		protected var _targetVisible:Boolean;
		protected var _targetReading:Boolean;
		protected var _talkCount:uint;
		
		public function Student(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			target = null;
			tilemap = null;
			students = null;
			
			_talkers = new Array();
			_followPoint = new FlxPoint();
			_targetPoint = new FlxPoint();
			
			// reset
			reset(X, Y);
		}
		
		override public function destroy():void
		{
			// stop following the path
			stopFollowingPath(true);
			
			super.destroy();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X - width / 2, Y - height / 2);
			
			// load a random student graphic
			var randomImage:Class = FlxG.getRandom(ImgStudents) as Class;
			loadGraphic(randomImage, true, false, 16, 16, true);
			
			// randomize the skin and hair color
			var hairAndSkinColor:Object = FlxG.getRandom(HAIR_AND_SKIN_COLORS);
			replaceColor(HAIR_COLOR, hairAndSkinColor.hair);
			replaceColor(SKIN_COLOR, hairAndSkinColor.skin);
			
			// set up bounding box
			offset.x = 3;
			offset.y = 8;
			width = 9;
			height = 8;
			
			// start by facing down
			facing = DOWN;
			
			// start in an idle state
			state = IDLE;
			
			// reset properties
			_timer = 0;
			_followTimer = 0;
			_targetVisible = false;
			_talkCount = 0;
		}
		
		override public function update():void
		{
			// get the center point of the student
			getMidpoint(_point);
			
			// if target exists
			if (target)
			{
				// get the center point of the target
				target.getMidpoint(_targetPoint);
				
				// get the angle to the target
				var targetAngle:Number = FlxU.getAngle(_point, _targetPoint);
				
				// get the angle required to turn toward the target
				var turningAngle:Number = FlxU.abs(targetAngle - pathAngle);
				
				// if facing away from target
				if (turningAngle > 90 && turningAngle < 270)
				{
					// target is not visible
					_targetVisible = false;
				}
				// if tilemap exists
				else if (tilemap)
				{
					// check whether target is visible to student
					_targetVisible = tilemap.ray(_point, _targetPoint, null, 2);
				}
				else
				{
					// target is visible
					_targetVisible = true;
				}
				
				// check whether the target is reading the letter
				_targetReading = (target is Player && (target as Player).reading);
			}
			else
			{
				// target is not visible
				_targetVisible = false;
				
				// target is not reading
				_targetReading = false;
			}
			
			// if target exists and is visible
			if (target && _targetVisible)
			{
				// set the follow point to the latest target point
				_followPoint.copyFrom(_targetPoint);
			}
			
			// count down the follow timer
			_followTimer--;
			
			// if alive
			if (alive)
			{
				// update according to current state
				switch (_state) 
				{
					case IDLE:
						updateIdle();
					break;
					case TALK:
						updateTalk();
					break;
					case WANDER:
						updateWander();
					break;
					case TRAVEL:
						updateTravel();
					break;
					case FOLLOW:
						updateFollow();
					break;
					case PURSUE:
						updatePursue();
					break;
				}
			}
			else
			{
				// stop moving
				pathSpeed = 0;
			}
			
			super.update();
		}
		
		override public function tease(Time:Number = 2):void
		{
			// if target is visible
			if (_targetVisible)
			{
				// tease the target mercilessly!
				super.tease();
			}
		}
		
		override public function greet(Time:Number = 1):void
		{
			// if taunts exist and old taunt does not
			if (taunts && !taunt)
			{
				// play talk sound
				playTalkSound();
			}
			
			super.greet();
		}
		
		public function get idling():Boolean
		{
			return (_state == IDLE);
		}
		
		public function get talking():Boolean
		{
			return (_state == TALK);
		}
		
		public function get wandering():Boolean
		{
			return (_state == WANDER);
		}
		
		public function get traveling():Boolean
		{
			return (_state == TRAVEL);
		}
		
		public function get following():Boolean
		{
			return (_state == FOLLOW);
		}
		
		public function get pursuing():Boolean
		{
			return (_state == PURSUE);
		}
		
		public function get state():uint
		{
			return _state;
		}
		
		public function set state(State:uint):void
		{
			// set the new state
			_state = State;
			
			// start the new state
			switch (_state) 
			{
				case IDLE:
					startIdle();
				break;
				case TALK:
					startTalk();
				break;
				case WANDER:
					startWander();
				break;
				case TRAVEL:
					startTravel();
				break;
				case FOLLOW:
					startFollow();
				break;
				case PURSUE:
					startPursue();
				break;
			}
		}
		
		public function playTalkSound():void
		{		
			// play random talk sound
			var sound:FlxSound = FlxG.play(FlxG.getRandom(Data.SndStudentTalks) as Class, 0.25);
			
			// make the sound pan based on distance from target
			getMidpoint(_point);
		}
		
		public function talkWith(OtherStudent:Student):void
		{
			// if not talking
			if (!talking)
			{
				// start talking
				state = TALK;
			}
			
			// if not talking with the other student
			if (_talkers.indexOf(OtherStudent) < 0)
			{
				// add the other student to the list of talkers
				_talkers.push(OtherStudent);
			}
		}
		
		public function startIdle():void
		{
			//FlxG.log("idle");
			
			// set the state
			_state = IDLE;
			
			// start idle timer
			_timer = FlxG.random() * (IDLE_TIME_MAX - IDLE_TIME_MIN) + IDLE_TIME_MIN;
			
			// be idle
			idle = true;
			
			// set the drag
			drag.x = drag.y = IDLE_DRAG;
			
			// allow collisions in any direction
			allowCollisions = ANY;
			
			// stop following a path
			stopFollowingPath(true);
		}
		
		public function startTalk():void
		{
			//FlxG.log("talk");
			
			// set the state
			_state = TALK;
			
			// reset talk count
			_talkCount = 0;
			
			// reset talk timer
			_timer = 0;
			
			// be idle
			idle = true;
			
			// set the drag
			drag.x = drag.y = IDLE_DRAG;
			
			// allow collisions in any direction
			allowCollisions = ANY;
			
			// stop following a path
			stopFollowingPath(true);
		}
		
		public function startWander(Target:FlxObject = null):void
		{
			//FlxG.log("wander");
			
			// set the state
			_state = WANDER;
			
			// get the center point of the student again
			getMidpoint(_point);
			
			// if the target exists
			if (Target)
			{
				// get the center point of the target
				Target.getMidpoint(_followPoint);
			}
			
			// stop following a path
			stopFollowingPath(true);
			
			// if tilemap exists
			if (tilemap)
			{
				// if the target does not exist
				if (!Target)
				{
					// if could not find a random point on the floor in four tries
					if (!getRandomFloorPoint(_followPoint, null, 4))
					{
						// switch to an idle state for a bit
						state = IDLE;
						return;
					}
				}
				
				// get a path to the point
				path = tilemap.findPath(_point, _followPoint);
				
				// if the path does not exist
				if (!path)
				{
					// look in the area around the student
					_rect.make(_point.x - width * 2, _point.y - height * 2, width * 4, height * 4);
					
					// if could not find a random point on the floor nearby in eight tries
					if (!getRandomFloorPoint(_point, _rect, 8))
					{
						// switch to an idle state for a bit
						state = IDLE;
						return;
					}
					
					// get a path from the random point to the point
					path = tilemap.findPath(_point, _followPoint);
					
					// if the path still does not exist
					if (!path)
					{
						// switch to an idle state for a bit
						state = IDLE;
						return;
					}
				}
				
				// if the path has more than one node
				if (path.nodes.length > 1)
				{
					// trim off the first path node
					path.remove(path.head());
					
					// if the path still has more than one node
					if (path.nodes.length > 1)
					{
						// trim off the last path node
						path.remove(path.tail());
					}
				}
			}
			else
			{
				// if the target does not exist
				if (!Target)
				{
					// get a random point on the screen
					_followPoint.x = FlxG.random() * FlxG.width;
					_followPoint.y = FlxG.random() * FlxG.height;
				}
				
				// create a new path directly to the point
				path = new FlxPath([_followPoint]);
			}
			
			// follow the path
			followPath(path, WANDER_SPEED);
			
			// be not idle!
			idle = false;
			
			// clear the drag
			drag.x = drag.y = 0;
			
			// do not collide with anything
			allowCollisions = NONE;
		}
		
		public function startTravel():void
		{
			//FlxG.log("travel");
			
			// set the state
			_state = TRAVEL;
			
			// stop following a path
			stopFollowingPath(true);
			
			// be not idle!
			idle = false;
			
			// clear the drag
			drag.x = drag.y = 0;
			
			// do not collide with anything
			allowCollisions = NONE;
		}
		
		public function startFollow():void
		{
			//FlxG.log("follow");
			
			// set the state
			_state = FOLLOW;
			
			// if there are too many students following
			if (students && students.stateCounts[FOLLOW] >= FOLLOW_LIMIT)
			{
				// switch to a wander state for a bit
				state = WANDER;
				return;
			}
			
			// allow collisions in any direction
			allowCollisions = ANY;
			
			// reset the follow timer
			resetFollowTimer();
			
			// stop following a path
			stopFollowingPath(true);
			
			// recalculate the path to the target
			recalculatePathToFollow();
			
			// start following the path
			followPath(path, FOLLOW_SPEED);
		}
		
		public function startPursue():void
		{
			//FlxG.log("pursue");
			
			// set the state
			_state = PURSUE;
			
			// if there are too many students pursuing
			if (students && students.stateCounts[PURSUE] >= PURSUE_LIMIT)
			{
				// switch to a wander state for a bit
				state = WANDER;
				return;
			}
			
			// allow collisions in any direction
			allowCollisions = ANY;
			
			// reset the follow timer
			resetFollowTimer();
			
			// stop following a path
			stopFollowingPath(true);
			
			// recalculate the path to the target
			recalculatePathToFollow();
			
			// start following the path
			followPath(path, PURSUE_SPEED);
		}
		
		protected function updateIdle():void
		{
			// if students exist
			if (students)
			{
				// get a random student
				var student:Student = students.getRandom() as Student;
				
				// if the student exists and is a different student
				if (student && student.exists && student != this)
				{
					// if the student is idling or talking or wandering
					if (student.idling || student.talking || student.wandering)
					{
						// get the distance to the student
						var dx:Number = student.x - x;
						var dy:Number = student.y - y;
						var distance2:Number = dx * dx + dy * dy;
						
						// if the student is the right distance away
						if (distance2 < TALK_RANGE_MAX * TALK_RANGE_MAX && distance2 > TALK_RANGE_MIN * TALK_RANGE_MIN)
						{
							// say something
							talk();
							
							// talk with the student
							talkWith(student);
							
							// tell the other student to talk
							student.talkWith(this);
							
							// no longer idle
							return;
						}
					}
				}
			}
			
			// if target is visible
			if (target && _targetVisible && onScreen())
			{
				// say random greeting
				greet();
				
				// switch to a follow state
				state = FOLLOW;
				return;
			}
			else
			{
				// advance timer
				_timer -= FlxG.elapsed;
				
				// if timer is up
				if (_timer <= 0)
				{
					// switch to a wander state
					state = WANDER;
				}
			}
		}
		
		protected function updateTalk():void
		{
			// stop talking if touching anything
			var shouldStopTalking:Boolean = (touching != NONE);
			
			// remember whether any other student is talking
			var anyoneTalking:Boolean = false;
			
			// choose a student to look at
			var followStudent:Student = (_talkers.length > 0) ? _talkers[_talkers.length - 1] : null;
			
			// for each student that this student is talking with
			var i:uint = _talkers.length;
			while (i--)
			{
				// get the student
				var student:Student = _talkers[i];
				
				// if the student is in a talk state
				if (student.talking)
				{
					// if the student is saying something
					if (student.taunt)
					{
						// remember that another student is talking
						anyoneTalking = true;
						
						// look at this student
						followStudent = student;
					}
				}
				else
				{
					// remove the student from the list of talkers
					_talkers.splice(i, 1);
				}
			}
			
			// if there is a student to look at
			if (followStudent)
			{
				// get the center point of the student
				followStudent.getMidpoint(_followPoint);
				
				// face toward the student
				pathAngle = FlxU.getAngle(_point, _followPoint);
				pathSpeed = 1;
			}
			
			// if there are no other students to talk with
			if (_talkers.length <= 0)
			{
				// stop talking!
				shouldStopTalking = true;
			}
			
			// if not already talking and no other students are talking
			if (!taunt && !anyoneTalking)
			{
				// advance timer
				_timer -= FlxG.elapsed;
				
				// if timer is up
				if (_timer <= 0)
				{
					// if the student has said enough
					if (_talkCount >= _talkers.length)
					{
						// stop talking
						shouldStopTalking = true;
					}
					else
					{
						// say something!
						talk();
						
						// count this
						_talkCount++;
						
						// start talk timer
						_timer = FlxG.random() * (TALK_TIME_MAX - TALK_TIME_MIN) + TALK_TIME_MIN;
					}
				}
			}
			
			// if should stop talking
			if (shouldStopTalking)
			{
				// clear the list of talkers
				_talkers.length = 0;
				
				// start wandering
				state = WANDER;
				return;
			}
		}
		
		protected function updateWander():void
		{
			// if target exists
			if (target)
			{
				// if target is visible
				if (_targetVisible && onScreen())
				{
					// say random greeting
					greet();
					
					// switch to a follow state
					state = FOLLOW;
					return;
				}
			}
			
			// if reached the end of the path or just touched something
			if (pathSpeed == 0 || touching != NONE)
			{
				// switch to an idle state for a bit
				state = IDLE;
				return;
			}
		}
		
		protected function updateTravel():void
		{
			// if path exists
			if (path)
			{
				// if reached the end of the path
				if (pathSpeed == 0)
				{
					// destroy the path
					path.destroy();
					path = null;
					
					// die!!!
					kill();
					return;
				}
			}
			// if path does not exist but target exists
			else if (target)
			{
				// if tilemap exists
				if (tilemap)
				{
					// get a path to the target point
					path = tilemap.findPath(_point, _targetPoint);
					
					// if the path exists and has more than one node
					if (path && path.nodes.length > 1)
					{
						// trim off the first path node
						path.remove(path.head());
					}
				}
				
				// if path still does not exist
				if (!path)
				{
					// create a new path directly to the point
					path = new FlxPath([_targetPoint]);
				}
				
				// follow the path
				followPath(path, TRAVEL_SPEED);
			}
		}
		
		protected function updateFollow():void
		{
			// if target exists
			if (target)
			{
				// if target is visible and reading
				if (_targetVisible && _targetReading)
				{
					// say !
					say("!");	
					
					// switch to a pursue state
					state = PURSUE;
					return;
				}
				
				// recalculate the path to the target
				recalculatePathToFollow();
				
				// get the distance from the follow point
				var followDistance:Number = FlxU.getDistance(_point, _followPoint);
				
				// calculate the minimum follow distance
				var minFollowDistance:Number = (_targetVisible) ? FOLLOW_RANGE : PURSUE_RANGE;
				
				// if distance is further than minimum distance
				if (followDistance >= minFollowDistance)
				{
					// move slower if just ran into something
					pathSpeed = ((touching & facing) != NONE) ? FOLLOW_SPEED / 2 : FOLLOW_SPEED;
					
					// clear the drag
					drag.x = drag.y = 0;
				}
				else
				{
					// stop following the path
					stopFollowingPath(true);
					
					// face toward the target
					pathAngle = FlxU.getAngle(_point, _followPoint);
					pathSpeed = 1;
					
					// set the drag
					drag.x = drag.y = IDLE_DRAG;
					
					// if target is not visible
					if (!_targetVisible)
					{
						// say ?
						say("?");
						
						// revert to an idle state
						state = IDLE;
						return;
					}
				}
				
				// check whether moving or not
				idle = (velocity.x == 0 && velocity.y == 0);
			}
			else
			{
				// revert to an idle state
				state = IDLE;
				return;
			}
		}
		
		protected function updatePursue():void
		{
			// if target exists
			if (target)
			{
				// if target is not visible or not reading
				if (!_targetVisible || !_targetReading)
				{
					// switch to a follow state
					state = FOLLOW;
					return
				}
				
				// recalculate the path to the target
				recalculatePathToFollow();
				
				// get the distance from the follow point
				var followDistance:Number = FlxU.getDistance(_point, _followPoint);
				
				// if distance is further than minimum range
				if (followDistance >= PURSUE_RANGE)
				{
					// if just ran into something
					if (touching & facing)
					{
						// if there is another path node
						if (_pathNodeIndex < path.nodes.length)
						{
							// get the current path node
							var node:FlxPoint = path.nodes[_pathNodeIndex];
							
							// get the distance from the node
							var dx:Number = node.x - _point.x;
							var dy:Number = node.y - _point.y;
							var dt:Number = FlxU.max(1, _followTimer);
							
							// if facing vertically
							if (facing & DOWN || facing & UP)
							{
								// add a horizontal offset
								node.x += (FlxG.random() - 0.5) * dy / dt;
							}
							// if facing horizontally
							else
							{
								// add a vertical offset
								node.y += (FlxG.random() - 0.5) * dx / dt;
							}
						}
					}
					
					// move at a pursuit speed
					pathSpeed = PURSUE_SPEED;
					
					// clear the drag
					drag.x = drag.y = 0;
				}
				else
				{
					// stop following the path
					stopFollowingPath(true);
					
					// face toward the target
					pathAngle = FlxU.getAngle(_point, _followPoint);
					pathSpeed = 1;
					
					// set the drag
					drag.x = drag.y = IDLE_DRAG;
				}
				
				// check whether moving or not
				idle = (velocity.x == 0 && velocity.y == 0);
			}
			else
			{
				// revert to an idle state
				state = IDLE;
				return;
			}
		}
		
		protected function resetFollowTimer():void
		{
			// set the follow timer to the number of students following or pursuing
			_followTimer = 1 + students.stateCounts[FOLLOW] + students.stateCounts[PURSUE];
		}
		
		protected function recalculatePathToFollow():void
		{
			// if the follow timer is up
			if (!students.findingPath && _followTimer <= 0)
			{
				// tell the students
				students.findingPath = true;
				
				// reset the follow timer
				resetFollowTimer();
				
				// destroy the path if it exists
				if (path) path.destroy();
				
				// get a path to the follow point
				path = tilemap.findPath(_point, _followPoint);
				
				// if the path exists and has more than one node
				if (path && path.nodes.length > 1)
				{
					// trim off the first path node
					path.remove(path.head());
				}
			}
			// if path exists
			else if (path)
			{
				// set the final destination to the follow point
				var destination:FlxPoint = path.nodes[path.nodes.length - 1];
				destination.x = _followPoint.x;
				destination.y = _followPoint.y;
				
				// do not start following the path again
				return;
			}
			
			// if the path does not exist
			if (!path)
			{
				// create a new path directly to the point
				path = new FlxPath([_followPoint]);
			}
			
			// start following the path
			followPath(path, pathSpeed);
		}
		
		protected function getRandomFloorPoint(Point:FlxPoint = null, Area:FlxRect = null, Tries:uint = 1):FlxPoint
		{
			// if point is not specified
			if (!Point)
			{
				// create a new point
				Point = new FlxPoint();
			}
			
			// if area is not specified
			if (!Area)
			{
				// use the default rect
				Area = _rect;
				
				// use the area of the screen
				Area.make(0, 0, FlxG.width, FlxG.height);
				
				// if tilemap exists
				if (tilemap)
				{
					// use the area of the tilemap
					Area.make(0, 0, tilemap.width, tilemap.height);
				}
			}
			
			// try to get a random point on the floor
			while (Tries > 0)
			{
				// get a random point in the tilemap
				Point.x = Area.x + FlxG.random() * Area.width;
				Point.y = Area.y + FlxG.random() * Area.height;
				
				// if tilemap exists and point is on a wall
				if (tilemap && tilemap.overlapsPoint(Point))
				{
					// try again
					Tries--;
				}
				else
				{
					// found it!
					return Point;
				}
			}
			
			// did not find a floor point
			return null;
		}
		
	}

}