package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Kitty extends Student
	{
		
		[Embed(source = 'data/img_kitty.png')] private const ImgKitty:Class;
		
		public function Kitty(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			
			// load the kitty graphics
			loadGraphic(ImgKitty, true, false, 16, 16);
			
			// set up bounding box
			offset.x = 3;
			offset.y = 8;
			width = 9;
			height = 8;
		}
		
	}

}