package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Cursor extends FlxSprite
	{
		
		[Embed(source = 'data/img_cursor.png')] private const ImgCursor:Class;
		
		public function Cursor()
		{
			super();
			
			// load the cursor graphics
			loadGraphic(ImgCursor, true, false, 16, 16);
			
			// set up bounding box
			offset.x = 8;
			offset.y = 8;
			width = 0;
			height = 0;
			
			// set up animations
			addAnimation("walk", [0, 1, 2, 1], 8);
			addAnimation("idle", [3]);
			addAnimation("arrow", [4]);
			
			// start as an arrow
			arrow();
		}
		
		override public function draw():void
		{
			// move to mouse position
			x = FlxG.mouse.x;
			y = FlxG.mouse.y;
			
			super.draw();
		}
		
		public function walk():void
		{
			// play walk animation
			play("walk");
			
			// set the offset
			offset.y = 14;
		}
		
		public function idle():void
		{
			// play idle animation
			play("idle");
			
			// set the offset
			offset.y = 8;
		}
		
		public function arrow():void
		{
			// play arrow animation
			play("arrow");
			
			// set the offset
			offset.y = 8;
		}
		
	}

}