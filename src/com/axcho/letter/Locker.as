package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Locker extends FlxObject
	{
		[Embed(source = 'data/img_locker_open.png')] private const ImgLockerOpen:Class
		[Embed(source = 'data/img_locker_highlight.png')] private const ImgLockerHighlight:Class
		
		public var offset:FlxPoint;
		
		private var _open:FlxSprite;
		private var _highlight:FlxSprite;
		
		public function Locker(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			offset = new FlxPoint();
			
			// set up bounding box
			offset.x = 4;
			offset.y = 2;
			width = 8;
			height = 16;
			
			// create open locker sprite
			_open = new FlxSprite(X, Y, ImgLockerOpen);
			
			// set up open locker bounding box
			_open.offset.x = offset.x;
			_open.offset.y = offset.y;
			_open.width = width;
			_open.height = height;
			
			// create locker highlight sprite
			_highlight = new FlxSprite(X, Y);
			_highlight.loadGraphic(ImgLockerHighlight, true, false, 16, 32);
			
			// set up locker highlight bounding box
			_highlight.offset.x = offset.x;
			_highlight.offset.y = offset.y + 13;
			_highlight.width = width;
			_highlight.height = height;
			
			// set up flashing animation
			_highlight.addAnimation("flash", [0, 1, 2, 1], 8);
			
			// reset
			reset(X, Y);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X + offset.x, Y + offset.y);
			
			// start the locker open sprite as hidden
			_open.reset(x, y);
			_open.visible = false;
			
			// start the highlight sprite as hidden
			_highlight.reset(x, y);
			_highlight.visible = false;
		}
		
		override public function update():void
		{
			// keep elements lined up
			_open.x = _highlight.x = x;
			_open.y = _highlight.y = y;
			
			super.update();
			
			// update the open locker
			_open.preUpdate();
			_open.update();
			_open.postUpdate();
			
			// update the locker highlight
			_highlight.preUpdate();
			_highlight.update();
			_highlight.postUpdate();
		}
		
		override public function draw():void
		{
			super.draw();
			
			// draw the open locker
			if (_open.visible) _open.draw();
			
			// draw the locker highlight
			if (_highlight.visible) _highlight.draw();
		}
		
		public function open():void
		{
			// show the open locker sprite
			_open.visible = true;
		}
		
		public function close():void
		{	
			// show the open locker sprite
			_open.visible = false;
		}
		
		public function highlight():void
		{
			// show the highlight sprite
			_highlight.visible = true;
			
			// animate flash
			_highlight.play("flash");
		}
		
		public function unhighlight():void
		{	
			// hide the highlight sprite
			_highlight.visible = false;
		}
	}
}