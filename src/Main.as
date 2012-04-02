package  
{
	import com.axcho.letter.*;
	import org.flixel.*;
	import org.flixel.plugin.axcho.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass = "Preloader")]
	
	/**
	 * ...
	 * @author axcho
	 */
	public class Main extends FlxGame
	{
		
		public function Main()
		{
			super(320, 240, MenuState, 2);
			
			// connect to Kongregate
			FlxAPI.connect(this);
		}
		
	}

}