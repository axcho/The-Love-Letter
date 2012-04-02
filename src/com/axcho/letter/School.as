package com.axcho.letter 
{
	import flash.utils.Dictionary;
	import org.flixel.*;
	import org.flixel.plugin.axcho.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class School extends FlxTilemapPlus
	{
		
		public var students:Students;
		public var lockers:FlxGroup;
		public var doors:FlxGroup;
		
		[Embed(source = 'data/img_map.png')] private const ImgMap:Class;
		[Embed(source = 'data/img_tiles.png')] private const ImgTiles:Class;
		[Embed(source = 'data/img_legend.png')] private const ImgLegend:Class;
		
		private const LOCKER_LEFT_TILE:uint = 17;
		private const LOCKER_CENTER_TILE:uint = 18;
		private const LOCKER_RIGHT_TILE:uint = 19;
		private const DOOR_TILE:uint = 20;
		private const ENTRY_TILE:uint = 25;
		
		private var _lockersByName:Dictionary;
		
		public function School()
		{
			super();
			students = null;
			
			// create a group of lockers
			lockers = new FlxGroup();
			
			// create a group of doors
			doors = new FlxGroup();
			
			// keep track of lockers by name also
			_lockersByName = new Dictionary();
			
			// load the map from an image
			loadMap(FlxTilemapPlus.imageToCSV(ImgMap, FlxTilemapPlus.imageToColors(ImgLegend)), ImgTiles, 16, 16, ALT, 0, 0);
			
			// stop autotile
			auto = OFF;
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// destroy the lockers
			lockers.destroy();
			
			// destroy the doors
			doors.destroy();
			
			// clear the lockers by name
			_lockersByName = null;
		}
		
		override public function update():void
		{
			super.update();
			
			// update the lockers
			lockers.preUpdate();
			lockers.update();
			lockers.postUpdate();
			
			// update the doors
			doors.preUpdate();
			doors.update();
			doors.postUpdate();
		}
		
		override public function draw():void
		{
			super.draw();
			
			// draw the lockers
			lockers.draw();
			
			// draw the doors 
			doors.draw();
		}
		
		public function getEntryPoint():FlxPoint
		{
			// get the positions of all the entry tiles
			var entryPositions:Array = getTileCoords(ENTRY_TILE);
			
			// choose a random entry
			var randomEntryIndex:uint = uint(FlxG.random() * entryPositions.length);
			
			// get the entry position
			var entryPosition:FlxPoint = entryPositions[randomEntryIndex];
			
			// return the position
			return entryPosition;
		}
		
		public function getLocker(LockerName:String):Locker
		{
			// return the locker of the given name
			return _lockersByName[LockerName] as Locker;
		}
		
		public function addLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker does not yet exist
			if (!locker)
			{
				// get the positions of all the locker tiles
				var lockerPositions:Array = getTileCoords(LOCKER_CENTER_TILE, false);
				lockerPositions = lockerPositions.concat(getTileCoords(LOCKER_LEFT_TILE, false));
				lockerPositions = lockerPositions.concat(getTileCoords(LOCKER_RIGHT_TILE, false));
				
				// create a new locker
				locker = lockers.recycle(Locker) as Locker;
				
				// add the locker by the given name
				_lockersByName[LockerName] = locker;
				
				// find a new locker that is on screen in eight tries
				var tries:uint = 8;
				while (tries > 0)
				{
					// choose a random locker
					var randomLockerIndex:uint = uint(FlxG.random() * lockerPositions.length);
					
					// get the locker position
					var lockerPosition:FlxPoint = lockerPositions[randomLockerIndex];
					
					// reset the locker at that position
					locker.reset(lockerPosition.x, lockerPosition.y);
					
					// if locker is on screen and does not overlap with any other locker
					if (locker.onScreen() && !FlxG.overlap(lockers, locker))
					{
						// found it!
						tries = 0;
					}
					else
					{
						// keep trying
						tries--;
					}
				}
			}
		}
		
		public function removeLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker exists
			if (locker)
			{
				// kill it
				locker.kill();
				
				// remove it by name
				delete _lockersByName[LockerName];
			}
		}
		
		public function openLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker exists
			if (locker)
			{
				// open the locker
				locker.open();
				
				// play the open sound
				FlxG.play(Data.SndLockerOpen, 0.25);
			}
		}
		
		public function closeLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker exists
			if (locker)
			{
				// close the locker
				locker.close();
			}
		}
		
		public function highlightLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker exists
			if (locker)
			{
				// highlight the locker
				locker.highlight();
				
				// play the highlight sound
				FlxG.play(Data.SndHighlight);
			}
		}
		
		public function unhighlightLocker(LockerName:String):void
		{
			// get the locker of the given name
			var locker:Locker = getLocker(LockerName);
			
			// if locker exists
			if (locker)
			{
				// open the locker
				locker.unhighlight();
			}
		}
		
		public function addDoors():void
		{
			// get the positions of all the door tiles
			var doorPositions:Array = getTileCoords(DOOR_TILE, false);
			
			// for each door position
			for (var i:String in doorPositions)
			{
				// get the door position
				var doorPosition:FlxPoint = doorPositions[i];
				
				// create a new door there
				var door:Door = doors.recycle(Door) as Door;
				door.reset(doorPosition.x, doorPosition.y);
			}
		}
		
		public function removeDoors():void
		{
			// clear all the existing doors
			doors.clear();
		}
		
		public function openDoors():void
		{
			// open all doors
			doors.callAll("open");
			
			// play the open sound
			FlxG.play(Data.SndDoorOpen);
		}
		
		public function closeDoors():void
		{
			// close all doors
			doors.callAll("close");
			
			// play the close sound
			FlxG.play(Data.SndDoorClose);
		}
		
		public function areStudentsOut(StudentCount:uint = 1):Boolean
		{
			// return whether at least the given number of students are out
			return (students.countStudents() >= StudentCount);
		}
		
		public function areStudentsIn(StudentCount:uint = 0):Boolean
		{
			// return whether all students are in except the given number
			return (students.countStudents() <= StudentCount);
		}
		
		public function sendOutStudent(student:Student):void
		{
			// get a random door
			var door:Door = doors.getRandom() as Door;
			
			// get the center point of the door
			door.getMidpoint(_point);
			
			// reset the student there
			student.reset(_point.x, _point.y);
			
			// make the student wander
			student.state = Student.WANDER;
			
			// give the student some downward velocity!
			student.velocity.y += _tileHeight;
			
			// play talk sound
			student.playTalkSound();
		}
		
		public function bringInStudent(student:Student):void
		{
			// get a random door
			var door:Door = doors.getRandom() as Door;
			
			// make the student target the door
			student.target = door;
			
			// make the student travel to it
			student.state = Student.TRAVEL;
		}
		
		public function sendOutStudents(StudentCount:uint = 1, Delay:Number = 0):void
		{
			// if there is only one student
			if (StudentCount == 1)
			{
				// send out the student immediately
				onStudentTimer(null);
			}
			// if there is no delay
			else if (Delay == 0)
			{
				// for each student to send out
				for (var i:int = 0; i < StudentCount; i++)
				{
					// send out a student
					onStudentTimer(null);
				}
			}
			else
			{
				// create a new timer
				var studentTimer:FlxTimer = new FlxTimer();
				
				// send out a student when the timer completes
				studentTimer.start(Delay, StudentCount, onStudentTimer);
			}
		}
		
		public function bringInStudents():void
		{
			// for each student
			var i:int = students.length;
			while (i--)
			{
				// get the basic object
				var basic:FlxBasic = students.members[i];
				
				// if the basic object is a student and not the girl
				if (basic is Student && !(basic is Girl))
				{
					// get the student
					var student:Student = basic as Student;
					
					// if student exists
					if (student.exists)
					{
						// bring in the student to a random door
						bringInStudent(student);
					}
				}
			}
		}
		
		private function onStudentTimer(Timer:FlxTimer):void
		{
			// add a new student
			var student:Student = students.addStudent();
			
			// send out the student from a random door
			sendOutStudent(student);
		}
		
	}

}