package org.flixel.plugin.axcho 
{
	import org.flixel.FlxBasic;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class ScriptManager extends FlxBasic
	{
		
		protected var _scripts:Array;
		
		public function ScriptManager()
		{
			super();
			
			// create a new list of scripts
			_scripts = new Array();
			
			// do not draw
			visible = false;
		}
		
		override public function destroy():void
		{
			// remove all the scripts
			clear();
			
			// remove the list of scripts
			_scripts = null;
		}
		
		override public function update():void
		{
			// for each script
			for (var i:String in _scripts)
			{
				// get the script
				var script:FlxScript = _scripts[i];
				
				// if the script exists and is not paused
				if (script && !script.paused)
				{
					// update the script
					script.update();
				}
			}
		}
		
		public function add(Script:FlxScript):void
		{
			// get the index of the script
			var index:int = _scripts.indexOf(Script);
			
			// if the script does not exist
			if (index < 0)
			{
				// add the script to the list
				_scripts.push(Script);
			}
		}
		
		public function remove(Script:FlxScript):void
		{
			// get the index of the script
			var index:int = _scripts.indexOf(Script);
			
			// if the script exists
			if (index >= 0)
			{
				// remove the script from the list
				_scripts.splice(index, 1);
			}
		}
		
		public function clear():void
		{
			// for each script
			for (var i:String in _scripts)
			{
				// get the script
				var script:FlxScript = _scripts[i];
				
				// if the script exists
				if (script)
				{
					// destroy it
					script.destroy();
				}
			}
			
			// empty out the list of scripts
			_scripts.length = 0;
		}
		
	}

}