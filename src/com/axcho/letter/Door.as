package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Door extends FlxSprite
	{
		
		[Embed(source = 'data/img_door_open.png')] private const ImgDoorOpen:Class;
		
		public function Door(X:Number = 0, Y:Number = 0)
		{
			super(X, Y, ImgDoorOpen);
			
			// set up bounding box
			offset.x = 0;
			offset.y = 16;
			width = 16;
			height = 2;
			
			// reset
			reset(X, Y);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X + offset.x, Y + offset.y);
			
			// start as closed
			visible = false;
		}
		
		public function open():void
		{
			// open the door
			visible = true;
		}
		
		public function close():void
		{
			// close the door
			visible = false;
		}
		
	}

}