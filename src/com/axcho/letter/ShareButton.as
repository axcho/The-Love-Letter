package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author knivel
	 */
	public class ShareButton extends FlxButton
	{
		
		private var _onClick:Function;
		
		public function ShareButton(X:Number = 0, Y:Number = 0, Graphic:Class = null, OnClick:Function = null) 
		{
			super(X, Y, null, OnClick);
			
			// load the graphic if it exists
			if (Graphic) loadGraphic(Graphic, true);
			
			// set up button states
			addAnimation("up", [0]);
			addAnimation("hover", [1]);
			play("up");
			
			// set up button sounds
			setSounds(Data.SndButtonHover, 1.0, null, 0, Data.SndButtonClick, 1.0);
		}
		
		override public function update():void
		{
			// take care of the normal button update
			updateButton();
			
			// change appearance based on frame
			switch (frame) 
			{
				case HIGHLIGHT:
					play("hover");
				break;
				case PRESSED:
				case NORMAL:
				default:
					play("up");
				break;
			}
		}
		
	}
	
}