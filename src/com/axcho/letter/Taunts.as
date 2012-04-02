package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Taunts extends FlxGroup
	{
		
		public function Taunts()
		{
			super();
		}
		
		override public function update():void
		{
			super.update();
			
			// sort taunts by depth
			sort();
		}
		
		public function addTaunt(TauntAnimation:String, Time:Number = 1, Target:FlxObject = null):Taunt
		{
			// create a new taunt
			var taunt:Taunt = recycle(Taunt) as Taunt;
			
			// show the taunt
			taunt.show(TauntAnimation, Time, Target);
			
			// return the taunt
			return taunt;
		}
		
	}

}