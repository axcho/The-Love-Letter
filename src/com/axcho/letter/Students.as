package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Students extends FlxGroup
	{
		
		public var taunts:Taunts;
		public var target:FlxObject;
		public var tilemap:FlxTilemap;
		public var catcher:FlxObject;
		public var stateCounts:Array;
		public var findingPath:Boolean;
		
		public function Students()
		{
			super();
			target = null;
			taunts = null;
			tilemap = null;
			catcher = null;
			stateCounts = [0, 0, 0, 0, 0, 0];
			findingPath = false;
			
			FlxG.watch(stateCounts, "0", "IDLE");
			FlxG.watch(stateCounts, "1", "TALK");
			FlxG.watch(stateCounts, "2", "WANDER");
			FlxG.watch(stateCounts, "3", "TRAVEL");
			FlxG.watch(stateCounts, "4", "FOLLOW");
			FlxG.watch(stateCounts, "5", "PURSUE");
		}
		
		override public function preUpdate():void
		{
			// not finding a path
			findingPath = false;
			
			// reset state counts
			stateCounts[Student.IDLE] = 0;
			stateCounts[Student.TALK] = 0;
			stateCounts[Student.WANDER] = 0;
			stateCounts[Student.TRAVEL] = 0;
			stateCounts[Student.FOLLOW] = 0;
			stateCounts[Student.PURSUE] = 0;
			
			// for each member
			var i:uint = length;
			while (i--)
			{
				// if member is a student
				if (members[i] is Student)
				{
					// get the student
					var student:Student = members[i] as Student;
					
					// if the student exists
					if (student.exists)
					{
						// count which state it is in
						stateCounts[student.state]++;
					}
				}
			}
			
			super.preUpdate();
		}
		
		override public function update():void
		{
			super.update();
			
			// if the target exists
			if (target)
			{
				// check whether any student has caught the target
				FlxG.overlap(this, target, onStudentHitTarget);
			}
			
			// collide students with each other
			FlxG.collide(this);
			
			// collide students and tilemap
			FlxG.collide(this, tilemap);
			
			// sort students by depth
			sort();
		}
		
		public function countStudents():uint
		{
			// count the number of students
			var studentCount:uint = 0;
			
			// for each member
			var i:uint = length;
			while (i--)
			{
				// if member is a student
				if (members[i] is Student)
				{
					// get the student
					var student:Student = members[i];
					
					// if the student exists
					if (student.exists)
					{
						// count the student
						studentCount++;
					}
				}
			}
			
			// return the number of students
			return studentCount;
		}
		
		public function makeStudents(StudentCount:uint = 1):void
		{
			// make a point
			var point:FlxPoint = new FlxPoint();
			
			// fill the group with students
			for (var i:int = 0; i < StudentCount; i++)
			{
				// if tilemap exists
				if (tilemap)
				{
					// find a point that is not in a wall
					var inWall:Boolean = true;
					while (inWall)
					{
						// get a random point in the tilemap
						point.x = FlxG.random() * tilemap.width;
						point.y = FlxG.random() * tilemap.height;
						
						// check whether it is in a wall
						inWall = tilemap.overlapsPoint(point);
					}
				}
				else
				{
					// get a random point on the screen
					point.x = FlxG.random() * FlxG.width;
					point.y = FlxG.random() * FlxG.height;
				}
				
				// add a student there
				addStudent(point.x, point.y);
			}
		}
		
		public function addStudent(X:Number = 0, Y:Number = 0):Student
		{
			// create a new student
			var student:Student = recycle(Student) as Student;
			student.reset(X, Y);
			
			// tell it about target and taunts and tilemap
			student.target = target;
			student.taunts = taunts;
			student.tilemap = tilemap;
			student.students = this;
			
			// return it
			return student;
		}
		
		private function onStudentHitTarget(StudentObject:FlxObject, TargetObject:FlxObject):void 
		{
			// save the student as the catcher
			catcher = StudentObject;
		}
		
	}

}