package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Girl extends Student
	{
		
		[Embed(source = 'data/img_girl.png')] private const ImgGirl:Class;
		
		public function Girl(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			// set up animations
			addAnimation("show_blush", [0, 19, 20, 21, 22, 23, 24], 16, false);
			addAnimation("hide_blush", [24, 23, 22, 21, 20, 19, 0], 16, false);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			
			// load the girl graphics
			loadGraphic(ImgGirl, true, false, 16, 16);
			
			// set up bounding box
			offset.x = 3;
			offset.y = 8;
			width = 9;
			height = 8;
		}
		
		override protected function updateWander():void
		{
			// go faster if not on screen
			pathSpeed = (onScreen()) ? FOLLOW_SPEED : FOLLOW_SPEED * 2;
			
			super.updateWander();
		}
		
		override protected function updateFollow():void
		{
			// always know where the target is
			_targetVisible = true;
			_followPoint.copyFrom(_targetPoint);
			
			super.updateFollow();
		}
		
		override protected function updatePursue():void
		{
			// force pursuit even if not reading or visible
			_targetReading = true;
			
			// always know where the target is
			_targetVisible = true;
			_followPoint.copyFrom(_targetPoint);
			
			super.updatePursue();
		}
		
	}

}