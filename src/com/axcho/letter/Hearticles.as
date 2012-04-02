package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Hearticles extends FlxEmitter
	{
		
		[Embed(source = 'data/img_hearticle.png')] private const ImgHearticle:Class
		
		public function Hearticles(X:Number = 0, Y:Number = 0, Size:Number = 8)
		{
			super(X, Y, Size);
			
			// set up emitter
			particleDrag.x = 2;
			setXSpeed( -8, 8);
			setYSpeed( -24, -16);
			setRotation(0, 0);
			
			// fill the emitter with hearticles
			var i:uint = Size;
			while (i--)
			{
				// add a hearticle
				var hearticle:FlxParticle = new FlxParticle();
				hearticle.loadGraphic(ImgHearticle, true, false, 7, 6);
				hearticle.randomFrame();
				add(hearticle);
			}
			
			// start hidden
			hide();
		}
		
		override public function emitParticle():void
		{
			// get a dead particle
			var hearticle:FlxParticle = getFirstAvailable(FlxParticle) as FlxParticle;
			
			// give it a random frame
			hearticle.randomFrame();
			
			// emit it
			super.emitParticle();
		}
		
		public function between(Object1:FlxObject, Object2:FlxObject):void
		{
			// get the first object midpoint
			Object1.getMidpoint(_point);
			
			// move to the midpoint
			x = _point.x;
			y = _point.y;
			
			// get the second object midpoint
			Object2.getMidpoint(_point);
			
			// move between midpoints
			x = (x + _point.x - width) / 2;
			y = (y + _point.y - height) / 2;
		}
		
		public function show():void
		{
			// appear
			visible = true;
			
			// start emitting
			start(false, 1.0, 0.25);
		}
		
		public function hide():void
		{
			// disappear
			visible = false;
			
			// stop emitting
			kill();
		}
		
	}

}