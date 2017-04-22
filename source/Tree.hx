package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author 
 */
class Tree extends FlashSprite
{
	public var visited : Bool = false;
	public var collisionSprite : FlxSprite;
	
	public function new(X : Float, Y : Float ) 
	{
		super(X, Y);
		
		var r : Int = FlxG.random.int(1, 6);
		
		if (r == 1)
		{
			x -= 16;
			y -= 16;
			this.loadGraphic(AssetPaths.tree1__png, false, 32, 32);
			collisionSprite = new FlxSprite(x + 10, y + 24);
			collisionSprite.makeGraphic(10, 8);
		}
		else if (r == 2)
		{
			y -= 16;
			this.loadGraphic(AssetPaths.tree2__png, false, 16, 32);
			collisionSprite = new FlxSprite(x + 4, y + 24);
			collisionSprite.makeGraphic(6, 9);
		}
		else if (r == 3)
		{
			y -= 16;
			this.loadGraphic(AssetPaths.tree3__png, false, 16, 32);
			collisionSprite = new FlxSprite(x + 4, y + 24);
			collisionSprite.makeGraphic(6, 9);
		}
		else if (r == 4)
		{
			
			this.loadGraphic(AssetPaths.tree4__png, false, 16, 16);
			collisionSprite = new FlxSprite(x + 4, y + 12);
			collisionSprite.makeGraphic(8, 4);
		}
		else if (r == 5)
		{
			x -= 24;
			y -= 24;
			this.loadGraphic(AssetPaths.tree5__png, false, 48, 48);
			collisionSprite = new FlxSprite(x + 16, y + 32);
			collisionSprite.makeGraphic(16, 16);
		}
		else if (r == 6)
		{
			x -= 24;
			y -= 24;
			this.loadGraphic(AssetPaths.tree6__png, false, 48, 48);
			collisionSprite = new FlxSprite(x + 16, y + 32);
			collisionSprite.makeGraphic(16, 16);
		}
		
		this.immovable = true;
		this.collisionSprite.immovable = true;
		this.alpha = 0;
	}
	
	public inline function visitMe()
	{
		alpha = 1;
		visited = true;
	}
	
}