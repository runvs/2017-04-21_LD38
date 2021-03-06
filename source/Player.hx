package;

import Tool;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Player extends FlashSprite
{
    //#################################################################

    var _accelFactor    : Float;

	public var _state      : PlayState;

	var _facing         : Facing;
	
	var dustparticles : MyParticleSystem;
	var dustTime : Float = 0;
	
	var healthMax : Float = 1;
	
	var inInteractionAnim : Float = 0;

	public var Exhaustion : Float;
	public var Hunger     : Float;
	public var Warmth     : Float;

	private var _exhaustionBar : HudBar;
	private var _hungerBar     : HudBar;
	private var _warmthBar     : HudBar;

	private var _exhaustionTimer : Float;
	private var _hungerTimer     : Float;
	private var _warmthTimer     : Float;
	
	private var _placeCoolDown : Float = 0;
	
	private var _chopSound : FlxSound;
	
	
	
    public function new(playState: PlayState)
    {
        super();

		loadGraphic(AssetPaths.Hero__png, true, 16, 16);
		animation.add("walk_south", [0, 4, 8,  12], 8);
		animation.add("walk_west",  [1, 5, 9,  13], 8);
		animation.add("walk_north", [2, 6, 10, 14], 8);
		animation.add("walk_east",  [3, 7, 11, 15], 8);
		animation.add("idle", [0]);
		animation.add("stick", [16, 17], 8);
		animation.add("axe", [18, 19], 4);
		animation.add("pick", [20, 21], 4);
		animation.add("fish", [22,23,24,25,26,27], 8);
		animation.play("idle");

		dustparticles = new MyParticleSystem();
		dustparticles.mySize = 500;

		_facing = Facing.SOUTH;
		
		_accelFactor = GP.PlayerMovementAcceleration;
		drag         = GP.PlayerMovementDrag;
		maxVelocity  = GP.PlayerMovementMaxVelocity;

		_state = playState;

		setPosition(GP.WorldSizeInTiles /2 * GP.TileSize, GP.WorldSizeInTiles /2 * GP.TileSize);
		
		health = healthMax = GP.PlayerHealthMaxDefault;

		Exhaustion = 0.9;
		Hunger     = 0.55;
		Warmth     = 0.8;
		
		var barWidth = 60;
		_exhaustionBar = new HudBar(FlxG.width - barWidth,  2, barWidth, 11, false, FlxColor.GREEN , "fatigue");
		_hungerBar     = new HudBar(FlxG.width - barWidth, 18, barWidth, 11, false, FlxColor.GRAY,  "hunger");
		_warmthBar     = new HudBar(FlxG.width - barWidth, 34, barWidth, 11, false, FlxColor.RED  , "warmth");
		

		_exhaustionTimer = GP.ExhaustionTimer;
		_hungerTimer = GP.HungerTimer;
		_warmthTimer = GP.WarmthTimer;
		
		_chopSound = FlxG.sound.load(AssetPaths.chop__ogg, 0.5);
    }

    //#################################################################

    public override function update(elapsed: Float)
    {
        super.update(elapsed);
		
		keepPlayerOnMap();	
		
		dustparticles.update(elapsed);
		
		inInteractionAnim -= elapsed;
		
		CheckHealthCondition();
		
		_placeCoolDown -= elapsed;
		
		switch _facing
		{
			case Facing.EAST:
				if(inInteractionAnim <= 0)
					animation.play("walk_east", false);
				
				
			case Facing.WEST:
				if(inInteractionAnim <= 0)
					animation.play("walk_west", false);
				
				
			case Facing.NORTH:
				if(inInteractionAnim <= 0)
					animation.play("walk_north", false);
				
				
			case Facing.SOUTH:
				if(inInteractionAnim <= 0)
					animation.play("walk_south", false);
				
			
			case Facing.NORTHEAST:
				if(inInteractionAnim <= 0)
					animation.play("walk_north", false);
				
			case Facing.NORTHWEST:
				if(inInteractionAnim <= 0)
					animation.play("walk_north", false);
				
				
			case Facing.SOUTHEAST:
				if(inInteractionAnim <= 0)
					animation.play("walk_south", false);
			
				
			case Facing.SOUTHWEST:
				if(inInteractionAnim <= 0)
					animation.play("walk_south", false);
				
			
		}

        
		var l : Float = velocity.distanceTo(new FlxPoint());
		if (l <= GP.PlayerMovementMaxVelocity.x / 8)
		{
			if( inInteractionAnim <= 0 )
				animation.play("idle", false);
		}
		else
		{
			CreateDustParticles();
		}
		
		handleInput();

		_exhaustionTimer -= elapsed;
		if(_exhaustionTimer <= 0.0)
		{
			_exhaustionTimer += GP.ExhaustionTimer;
			getTired(GP.ExhaustionTickFactor);
		}

		_hungerTimer -= elapsed;
		if(_hungerTimer <= 0.0)
		{
			_hungerTimer += GP.HungerTimer;
			getHungry(GP.HungerTickFactor);
		}

		_warmthTimer -= elapsed;
		if(_warmthTimer <= 0.0)
		{
			_warmthTimer += GP.WarmthTimer;
			getCold(GP.WarmthTickFactor);
		}

		_exhaustionBar.health = Exhaustion;
		_exhaustionBar.update(elapsed);

		_hungerBar.health = Hunger;
		_hungerBar.update(elapsed);

		_warmthBar.health = Warmth;
		_warmthBar.update(elapsed);
    }
	
	function CheckHealthCondition() 
	{
		alive = (Exhaustion > 0 && Warmth > 0 && Hunger > 0);
	}

    //#################################################################

    function handleInput()
    {
        var vx : Float = MyInput.xVal * _accelFactor;
		var vy : Float = MyInput.yVal * _accelFactor;
		var l : Float = Math.sqrt(vx * vx + vy * vy);

		if (l >= 25)
		{
			if(vx > 0)
			{
				_facing = Facing.EAST;
				if(vy > 0) _facing = Facing.SOUTHEAST;
				if(vy < 0) _facing = Facing.NORTHEAST;
			}
			else if(vx < 0)
			{
				_facing = Facing.WEST;
				if(vy > 0) _facing = Facing.SOUTHWEST;
				if(vy < 0) _facing = Facing.NORTHWEST;
			}
			else
			{
				if(vy > 0) _facing = Facing.SOUTH;
				if(vy < 0) _facing = Facing.NORTH;
			}
		}
		acceleration.set(vx, vy);
		
		
		handleInteraction();
    }

	function CreateDustParticles():Void 
	{
		dustTime -= FlxG.elapsed;
		if (dustTime <= 0)
		{
			dustTime += 0.25;
			dustparticles.Spawn( 5,
			function (s : FlxSprite) : Void
			{
				s.alive = true;
				var T : Float = 0.85;
				s.setPosition(x + GP.rng.float(0, this.width) , y + height + GP.rng.float( -4, 0) );
				s.alpha = GP.rng.float(0.125, 0.35);
				FlxTween.tween(s, { alpha:0 }, T, { onComplete: function(t:FlxTween) : Void { s.alive = false; } } );
				var v : Float = GP.rng.float(0.75, 1.2);
				s.scale.set(v, v);
				FlxTween.tween(s.scale, { x: 2.5, y:2.5 }, T);
			},
			function(s:FlxSprite) : Void 
			{
				s.makeGraphic(5, 5, FlxColor.TRANSPARENT);
				s.drawCircle(3, 3, 2, GP.ColorDustParticles);
			});
		}
	}
	
	function keepPlayerOnMap():Void 
	{
		if (x < 0) x = 0;
		if (x > GP.TileSize * GP.WorldSizeInTiles - this.width) x = GP.TileSize * GP.WorldSizeInTiles - this.width;
		if (y < 0) y = 0;
		if (y > GP.TileSize * GP.WorldSizeInTiles - this.height) y = GP.TileSize * GP.WorldSizeInTiles - this.height;
	}
	
	function handleInteraction():Void 
	{
		if (inInteractionAnim < 0)
		{
			if (MyInput.InteractButtonPressed)
			{
				var i : Item  = _state._inventory.getActiveTool();
				
				if ( i == null)
				{
					interactWithWorld(null);
				}
				else if (Std.is(i, Tool))
				{
					//trace("u have tool");
					var t : Tool = cast i;
					if (t.toolCanBeUsedWithDestroyable)
					{
						//trace("destroyable");
						interactWithWorld(t);
					}
					else if (t.toolCanBePlacedInWorld)
					{
						//trace("place out");
						PlaceItemInWorld(_state._inventory.ActiveSlot);
					}
				}
				else
				{
					interactWithWorld(null);	// chop with stupid item
				}
			}
		}
	}
	
	function PlaceItemInWorld(s:InventorySlot) 
	{
		if (_placeCoolDown <= 0)
		{
			var i : Item = s.Item;
			if (!Std.is(i, Tool)) return;
			var t : Tool = cast i;
			if (t == null || !t.toolCanBePlacedInWorld) return;
			
			t.UseTool(this);
			
			s.Quantity--;
			if (s.Quantity == 0)
			{
				s.Item = null;
			}
			_placeCoolDown  = 0.5;
		}
	}
	
	function interactWithWorld(t : Tool):Void 
	{
		InteractWithDestroyables(t);
		InteractWithPlaceables();
	}
	
	function InteractWithPlaceables() 
	{
		var p : Placeable = _state._level.getPlaceableInRange(this);
		if (p == null) return;
		
		p.Use(this);
		
	}
	function InteractWithDestroyables(t : Tool):Void 
	{
		
		var d : Destroyables = _state._level.getDestroyableInRange(this);
		if (d == null) return;
		
		if (inInteractionAnim <= 0)
		{
			_chopSound.play();
		}
		this.animation.play("pick", true);
		inInteractionAnim = 0.5;
	
		var quality : Float = 0.3;
		if (d.toolUsage == 0) quality *= 2;
		if (t != null)
		{
			quality = t.toolQuality;
			t.toolLifeTime -= d.toolUsage * 0.85;
		}
		
		
		d.takeDamage(0.35 * quality);
		if (d.toolUsage == 0)	// Shrubs
		{
			getTired((1 - quality) * GP.ExhaustionFactor * 0.5);
			getHungry((1 - quality) * GP.HungerFactor * 0.5);
			getCold((1 - quality) * -GP.WarmthFactor * 0.5);
		}
		else// Rocks/Trees
		{
			getTired((1 - quality) * GP.ExhaustionFactor * 0.85);
			getHungry((1 - quality) * GP.HungerFactor * 0.58);
			getCold((1 - quality) * -GP.WarmthFactor * 0.85);
		}
		
		if (d.x < x) 
		{
			TurnPlayerLeftForInteraction();
		}
	}
	
	public function getTired(amount : Float) : Void
	{
		Exhaustion -= amount;
		if (Exhaustion > 1 ) Exhaustion = 1;
		
	}

	public function getHungry(amount : Float) : Void
	{
		Hunger -= amount;
		if (Hunger > 1 ) Hunger = 1;
	}

	public function getCold(amount : Float) : Void
	{
		Warmth -= amount;
		if (Warmth > 1 ) Warmth = 1;
	}
	
	function TurnPlayerLeftForInteraction():Void 
	{
		this.scale.set( -1, 1);
		new FlxTimer().start(0.5, function(t) : Void {this.scale.set( 1, 1); } );
	}
	
	
 
	public override function draw() 
	{
		dustparticles.draw();
		
		super.draw();
	}

    //#################################################################

	public function drawHud()
	{
		_exhaustionBar.draw();
		_hungerBar.draw();
		_warmthBar.draw();
	}

    //#################################################################
	
	
	public function restoreHealth()
	{
		health = healthMax;
	}
}