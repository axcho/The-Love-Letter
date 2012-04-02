package com.axcho.letter 
{
	import org.flixel.*;
	import org.flixel.plugin.axcho.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class PlayState extends FlxState
	{
		
		[Embed(source = 'data/txt_script.txt', mimeType = 'application/octet-stream')] public const TxtScript:Class;
		
		private const TRANSITION_COLOR:uint = 0xff1b2632;
		
		public var cursor:Cursor;
		public var advice:Advice;
		public var speech:Speech;
		public var letter:Letter;
		public var hearticles:Hearticles;
		public var cover:Cover;
		public var clock:Clock;
		public var taunts:Taunts;
		public var kitty:Kitty;
		public var girl:Girl;
		public var player:Player;
		public var students:Students;
		public var school:School;
		public var script:FlxScript;
		
		public var firstTry:Boolean;
		
		override public function create():void
		{
			super.create();
			
			// fade in
			FlxG.flash(FlxG.bgColor, 1.0);
			
			// check whether this is the first try or not
			firstTry = (FlxG.level == 0);
			
			// create a school tilemap
			school = new School();
			add(school);
			
			// create a group of taunts
			taunts = new Taunts();
			
			// create a new player
			player = new Player();
			player.tilemap = school;
			
			// create a group of students
			students = new Students();
			students.taunts = taunts;
			students.target = player;
			students.tilemap = school;
			add(students);
			
			// add the player
			students.add(player);
			
			// create the girl
			girl = new Girl();
			girl.target = player;
			girl.tilemap = school;
			girl.students = students;
			
			// create the kitty
			kitty = new Kitty();
			kitty.tilemap = school;
			kitty.students = students;
			
			// tell the school about these
			school.students = students;
			
			// add the taunts
			add(taunts);
			
			// add the clock
			clock = new Clock();
			clock.forward = false;
			add(clock);
			
			// add the cover
			cover = new Cover();
			add(cover);
			
			// add the hearticles
			hearticles = new Hearticles();
			add(hearticles);
			
			// add the letter
			letter = new Letter();
			letter.callback = onReadLetter;
			add(letter);
			
			// add the speech
			speech = new Speech();
			add(speech);
			
			// add the advice
			advice = new Advice();
			add(advice);
			
			// add the cursor
			cursor = new Cursor();
			add(cursor);
			
			// tell the player about these
			player.letter = letter;
			player.cursor = cursor;
			
			// add the script
			script = new FlxScript(TxtScript, [this, FlxScript, FlxG, Data]);
			script.start();
			
			// make the camera follow the player
			FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN);
			FlxG.camera.setBounds(school.x, school.y, school.width, school.height, true);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// destroy the script
			script.destroy();
			script = null;
			
			// if music exists
			if (FlxG.music)
			{
				// destroy the music
				FlxG.music.destroy();
				FlxG.music = null;
			}
		}
		
		public function kittyFound():void
		{
			// report the event to Kongregate
			if (FlxAPI.kongregate) FlxAPI.kongregate.stats.submit("Cat Scare", 1);
		}
		
		public function gameOver(Won:Boolean = false):void
		{
			// stop the script
			script.stop();
			
			// count the number of tries
			FlxG.level++;
			
			// start fading out to title screen
			FlxG.bgColor = TRANSITION_COLOR;
			FlxG.fade(FlxG.bgColor, 3.0, (Won) ? onFadeToEnd : onFadeToMenu, true);
			
			// report the event to Kongregate
			if (FlxAPI.kongregate) FlxAPI.kongregate.stats.submit((Won) ? "Kisses" : "Humiliations", 1);
		}
		
		private function onFadeToMenu():void
		{
			// go back to title screen
			FlxG.switchState(new MenuState());
		}
		
		private function onFadeToEnd():void
		{
			// go back to end screen
			FlxG.switchState(new StopState());
		}
		
		private function onReadLetter():void
		{
			// report the remaining time to Kongregate
			if (FlxAPI.kongregate) FlxAPI.kongregate.stats.submit("Read Speed", int(clock.startTime - clock.time));
		}
		
	}

}