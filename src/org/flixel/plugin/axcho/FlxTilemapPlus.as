package org.flixel.plugin.axcho 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import org.flixel.FlxTilemap;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class FlxTilemapPlus extends FlxTilemap
	{
		
		public function FlxTilemapPlus()
		{
			super();
		}
		
		override public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint = 0, TileHeight:uint = 0, AutoTile:uint = OFF, StartingIndex:uint = 0, DrawIndex:uint = 1, CollideIndex:uint = 1):FlxTilemap
		{
			// load the map without autotiling
			super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, OFF, StartingIndex, DrawIndex, CollideIndex);
			
			// if supposed to autotile
			if (AutoTile > OFF)
			{
				// now autotile
				auto = AutoTile;
				
				// for each tile
				var i:uint = totalTiles;
				while (i--)
				{
					// get the tile
					var tile:uint = getTileByIndex(i);
					
					// if tile is an autotile wall
					if (tile > 0 && tile < 16)
					{
						// autotile it
						autoTile(i);
						updateTile(i);
					}
				}
			}
			
			// return this for chaining
			return this;
		}
		
		static public function bitmapToColors(bitmapData:BitmapData):Array
		{
			var colors:Array = new Array();
			
			// walk image and export pixel values
			var row:uint = 0;
			var column:uint;
			var bitmapWidth:uint = bitmapData.width;
			var bitmapHeight:uint = bitmapData.height;
			while (row < bitmapHeight)
			{
				column = 0;
				while (column < bitmapWidth)
				{
					// save the color of this pixel
					colors.push(bitmapData.getPixel(column, row));
					column++;
				}
				row++;
			}
			return colors;
		}
		
		static public function imageToColors(ImageFile:Class):Array
		{
			return bitmapToColors((new ImageFile).bitmapData);
		}
		
		static public function bitmapToCSV(bitmapData:BitmapData, Colors:Array = null, Scale:uint = 1):String
		{
			// import and scale image if necessary
			if (Scale > 1)
			{
				var bd:BitmapData = bitmapData;
				bitmapData = new BitmapData(bitmapData.width * Scale, bitmapData.height * Scale);
				var mtx:Matrix = new Matrix();
				mtx.scale(Scale, Scale);
				bitmapData.draw(bd, mtx);
			}
			
			// populate colors array with defaults if necessary
			if (!Colors) Colors = [0xffffff, 0x000000];
			
			// walk image and export pixel values
			var row:uint = 0;
			var column:uint;
			var pixel:String;
			var i:String;
			var csv:String = "";
			var bitmapWidth:uint = bitmapData.width;
			var bitmapHeight:uint = bitmapData.height;
			while (row < bitmapHeight)
			{
				column = 0;
				while (column < bitmapWidth)
				{
					// find the color of this pixel
					pixel = "0";
					for (i in Colors)
					{
						var color:uint = Colors[i];
						if (color == bitmapData.getPixel(column, row))
						{
							pixel = i;
							break;
						}
					}
					
					// write the result to the string
					if (column == 0)
					{
						if (row == 0) csv += pixel;
						else csv += "\n" + pixel;
					}
					else csv += ", " + pixel;
					column++;
				}
				row++;
			}
			return csv;
		}
		
		static public function imageToCSV(ImageFile:Class, Colors:Array = null, Scale:uint = 1):String
		{
			return bitmapToCSV((new ImageFile).bitmapData, Colors, Scale);
		}
		
	}

}