package com.axcho.letter 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author knivel
	 */
	public class BouncyCharacter extends FlxSprite
	{
		
		[Embed(source = 'data/img_char_d.png')] private var ImgCharD:Class;
		[Embed(source = 'data/img_char_e.png')] private var ImgCharE:Class;
		[Embed(source = 'data/img_char_h.png')] private var ImgCharH:Class;
		[Embed(source = 'data/img_char_l.png')] private var ImgCharL:Class;
		[Embed(source = 'data/img_char_n.png')] private var ImgCharN:Class;
		[Embed(source = 'data/img_char_o.png')] private var ImgCharO:Class;
		[Embed(source = 'data/img_char_r.png')] private var ImgCharR:Class;
		[Embed(source = 'data/img_char_t.png')] private var ImgCharT:Class;
		[Embed(source = 'data/img_char_v.png')] private var ImgCharV:Class;
		[Embed(source = 'data/img_char_the.png')] private var ImgCharThe:Class;
		[Embed(source = 'data/img_char_heart.png')] private var ImgCharHeart:Class;
		
		public function BouncyCharacter(X:Number = 0, Y:Number = 0, Character:String = null, FrameOffset:int = 0, FrameRate:Number = 8):void 
		{
			super(X, Y);
			
			// load the graphic for the character
			loadGraphic(getCharGraphic(Character), true, false, 16, 32);
			
			// offset animation frames
			var frames:Array = [0, 1, 2, 1];
			var offsetFrames:Array = new Array();
			for (var i:int = 0; i < frames.length; i++)
			{
				offsetFrames.push(frames[(i + FrameOffset) % 4]);
			}
			
			// set up animations
			addAnimation("bob", offsetFrames, FrameRate);
			play("bob");
		}
		
		private function getCharGraphic(Character:String):Class
		{
			// convert the character to lowercase
			Character = Character.toLowerCase();
			
			// get the graphic for the given character
			switch (Character) 
			{
				case "d": return ImgCharD; break;
				case "e": return ImgCharE; break;
				case "h": return ImgCharH; break;
				case "l": return ImgCharL; break;
				case "n": return ImgCharN; break;
				case "o": return ImgCharO; break;
				case "r": return ImgCharR; break;
				case "t": return ImgCharT; break;
				case "v": return ImgCharV; break;
				case "^": return ImgCharThe; break;
				case "*": return ImgCharHeart; break;
				default: return null; break;
			}
		}
	}
}