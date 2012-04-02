package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class MenuButton extends FlxButton
	{
		
		public function MenuButton(X:Number = 0, Y:Number = 0, Label:String = null, OnClick:Function = null)
		{
			super(X, Y, Label, OnClick);
			
			// set up button sounds
			setSounds(Data.SndButtonHover, 1.0, null, 0, Data.SndButtonClick, 1.0);
		}
		
		override public function update():void
		{
			// take care of the normal button update
			updateButton();
			
			// if the label exists
			if (label)
			{
				// only show the label if the button is highlighted
				switch (frame) 
				{
					case HIGHLIGHT:
						label.alpha = 1.0;
					break;
					case PRESSED:
					case NORMAL:
					default:
						label.alpha = 0.0;
					break;
				}
			}
		}
		
	}

}