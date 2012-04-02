package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class MenuState extends FlxState
	{
		
		[Embed(source = 'data/img_title_screen.png')] private const ImgTitleScreen:Class;
		
		private const TEXT_COLOR:uint = 0xffffffff;
		private const SHADOW_COLOR:uint = 0xff005784;
		private const BACKGROUND_COLOR:uint = 0xff31a2f2;
		private const TRANSITION_COLOR:uint = 0xff1b2632;
		
		private var _cursor:Cursor;
		private var _instructions:FlxText;
		private var _credits:FlxText;
		private var _title:FlxButton;
		private var _bouncyText:BouncyText;
		
		private var _knivelButton:MenuButton;
		private var _axchoButton:MenuButton;
		private var _teoButton:MenuButton;
		
		override public function create():void
		{
			super.create();
			
			// fade in
			FlxG.flash(FlxG.bgColor, 1.0);
			
			// set the background color
			FlxG.bgColor = BACKGROUND_COLOR;
			
			// add the title screen as a button
			_title = new FlxButton(0, 0, null, onClick);
			_title.loadGraphic(ImgTitleScreen);
			add(_title);
			
			// add the bouncy title text
			_bouncyText = new BouncyText(BouncyText.THE_LOVE_LETTER, 24, 6);
			add(_bouncyText);
			
			// add the credits text
			_credits = new FlxText(0, 216, FlxG.width, "art by Pat Kemp . code by axcho . music by teoacosta");
			_credits.alignment = "center";
			_credits.color = SHADOW_COLOR;
			add(_credits);
			
			// set up knivel button
			_knivelButton = new MenuButton(29, _credits.y, null, onKnivelClick);
			_knivelButton.label = new FlxText(0, 0, 100, "art by Pat Kemp");
			_knivelButton.label.color = TEXT_COLOR;
			_knivelButton.label.shadow = SHADOW_COLOR;
			_knivelButton.makeGraphic(82, 14, 0x0);
			add(_knivelButton);
			
			// set up axcho button
			_axchoButton = new MenuButton(118, _credits.y, null, onAxchoClick);
			_axchoButton.label = new FlxText(0, 0, 80, "code by axcho");
			_axchoButton.label.color = TEXT_COLOR;
			_axchoButton.label.shadow = SHADOW_COLOR;
			_axchoButton.makeGraphic(73, 14, 0x0);
			add(_axchoButton);
			
			// set up teoacosta button
			_teoButton = new MenuButton(197, _credits.y, null, onTeoClick);
			_teoButton.label = new FlxText(0, 0, 100, "music by teoacosta");
			_teoButton.label.color = TEXT_COLOR;
			_teoButton.label.shadow = SHADOW_COLOR;
			_teoButton.makeGraphic(97, 14, 0x0);
			add(_teoButton);
			
			// add the instructions text
			_instructions = new FlxText(0, 196, FlxG.width, "click to begin");
			_instructions.alignment = "center";
			_instructions.color = TEXT_COLOR;
			_instructions.shadow = SHADOW_COLOR;
			add(_instructions);
			
			// add the cursor
			_cursor = new Cursor();
			add(_cursor);
			
			// fade in the music
			FlxG.playMusic(Data.SndSchoolMusic);
			FlxG.music.fadeIn(2.0);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// if music exists
			if (FlxG.music)
			{
				// destroy the music
				FlxG.music.destroy();
				FlxG.music = null;
			}
		}
		
		private function onClick():void
		{
			// skip if not active
			if (!active) return;
			
			// if no buttons are pressed
			if (_knivelButton.status != FlxButton.PRESSED &&
				_axchoButton.status != FlxButton.PRESSED &&
				_teoButton.status != FlxButton.PRESSED)
			{
				// stop responding to clicks
				_knivelButton.active = false;
				_axchoButton.active = false;
				_teoButton.active = false;
				active = false;
				
				// start fading out to play game
				FlxG.bgColor = TRANSITION_COLOR;
				FlxG.fade(FlxG.bgColor, 1.0, onFade);
				FlxG.music.fadeOut(2.0);
				
				// play sound effect
				FlxG.play(Data.SndHighlight);
			}
		}
		
		private function onFade():void
		{
			// switch to the play state
			FlxG.switchState(new PlayState());
		}
		
		private function onKnivelClick():void
		{
			// open knivel's website
			FlxU.openURL("http://patkemp.com/");
		}
		
		private function onAxchoClick():void
		{
			// open axcho's website
			FlxU.openURL("http://axcho.com/");
		}
		
		private function onTeoClick():void
		{
			// open teoacosta's website
			FlxU.openURL("http://teoacosta.com/");
		}
		
	}

}