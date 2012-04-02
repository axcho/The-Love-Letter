package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class StopState extends FlxState
	{
		
		private const TEXT_COLOR:uint = 0xffffffff;
		private const SHADOW_COLOR:uint = 0xff005784;
		private const BACKGROUND_COLOR:uint = 0xfff7e26b;
		private const TRANSITION_COLOR:uint = 0xff1b2632;
		
		private var _cursor:Cursor;
		private var _bouncyText:BouncyText;
		private var _sharePanel:SharePanel;
		private var _background:FlxButton;
		
		override public function create():void
		{
			super.create();
			
			// fade in
			FlxG.flash(FlxG.bgColor, 2.0);
			
			// set the background color
			FlxG.bgColor = BACKGROUND_COLOR;
			
			// add a solid background as a button
			_background = new FlxButton(0, 0, null, onClick);
			_background.makeGraphic(FlxG.width, FlxG.height, BACKGROUND_COLOR);
			add(_background);
			
			// add "the end" bouncy text
			_bouncyText = new BouncyText(BouncyText.THE_END, 48);
			add(_bouncyText);
			
			// add the share panel
			_sharePanel = new SharePanel("The Love Letter", "http://axcho.com/theloveletter/", "I just met my secret admirer in The Love Letter! You can play it here:", "Spread the love");
			add(_sharePanel);
			
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
			
			// if the mouse is not on the support panel
			if (!_sharePanel.overlapsPoint(FlxG.mouse.getScreenPosition()))
			{
				// stop responding to clicks
				_sharePanel.active = false;
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
			// switch to the menu state
			FlxG.switchState(new MenuState());
		}
		
	}
	
}