package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class SickNote extends FlxSprite
{

	var extraZoom:Float;

	public function new(data:Int, X:Float, Y:Float)
	{

		super();

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':

				frames = Paths.getSparrowAtlas('weeb/pixelUI/NOTE_assets_SICK_pixel');
				animation.addByPrefix('purplesplash', 'left_confirm_SICK', 24, false);
				animation.addByPrefix('bluesplash', 'down_confirm_SICK', 24, false);
				animation.addByPrefix('greensplash', 'up_confirm_SICK', 24, false);
				animation.addByPrefix('redsplash', 'right_confirm_SICK', 24, false);
				extraZoom = PlayState.daPixelZoom;

			default:

				frames = Paths.getSparrowAtlas('NOTE_assets_SICK');
				animation.addByPrefix('purplesplash', 'left_confirm_SICK', 24, false);
				animation.addByPrefix('bluesplash', 'down_confirm_SICK', 24, false);
				animation.addByPrefix('greensplash', 'up_confirm_SICK', 24, false);
				animation.addByPrefix('redsplash', 'right_confirm_SICK', 24, false);
				extraZoom = 1;

		}

		adjustNote(data, X, Y);
		
	}

	public function adjustNote(data:Int, X:Float, Y:Float):Void
	{

		//SHUT UP LOL
		scale.set(1,1);

		switch (data)
		{
			case (0):
			{
				animation.play('purplesplash');
			}
			case (1):
			{
				animation.play('bluesplash');
			}
			case (2):
			{
				animation.play('greensplash');
			}
			case (3):
			{
				animation.play('redsplash');
			}
		}

		updateHitbox();

		x = X;
		y = Y;

		if (extraZoom == 1)
		{

			offset.set(0.325 * width, 0.35 * height);

		}
		else
		{

			offset.set(-44, -27);

		}
		
		scrollFactor.set(0, 0);
		setGraphicSize(Std.int(width * extraZoom));

	}

	override function update(elapsed:Float)
	{

		if (animation.finished)
		{

			kill();

		}
		else
		{

			super.update(elapsed);

		}

	}

}
