package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;

using StringTools;

class CharacterPortrait extends FlxSprite
{

	//FACING LEFT IS -1, FACING RIGHT IS 1
	public var facingDir:Int = -1;
	public var voice:String = 'pixelText';
	public var character:String;
	var pixelChar:Bool;
	var startX:Float;
	var startY:Float;
	var entering:Bool;

	public function new(X:Float, Y:Float, Character:String, pixelChar:Bool)
	{

		super();

		this.entering = false;
		this.x = X;
		this.y = Y;
		this.character = Character;
		this.pixelChar = pixelChar;

		scrollFactor.set();
		visible = false;

		var directory = "portraits/";
		var zoom:Float = 1;

		if (pixelChar)
		{
			directory = "weeb/";
			zoom = PlayState.daPixelZoom * 0.9;
		}

		if ((character == 'senpai') && (PlayState.SONG.song.toLowerCase() == 'thorns'))
		{
			frames = Paths.getSparrowAtlas('${directory}${character}Portrait_tagless');
		}
		else
		{
			frames = Paths.getSparrowAtlas('${directory}${character}Portrait');
		}

		switch (character) {

			case 'bf':
				if (pixelChar)
				{
					animation.addByPrefix('normal', 'Boyfriend portrait enter', 24, false);
				}
				else
				{
					animation.addByIndices('normal', 'talking_tony_normal', [0], "", 24, false);
					animation.addByIndices('stressed', 'talking_tony_stressed', [0], "", 24, false);

					//Update positioning because hardcoding is funny
					x += 620;
					y += 90;
				}

			case 'gf':
				if (pixelChar)
				{
					animation.addByPrefix('normal', 'Girlfriend portrait enter', 24, false);
				}
				else
				{
					animation.addByIndices('normal', 'talking_shimo_normal', [0], "", 24, false);
					animation.addByIndices('stressed', 'talking_shimo_bummed', [0], "", 24, false);

					x += 400;
					y += 60;
				}

			case 'dad':
				animation.addByIndices('normal', 'talking_apex_normal', [0], "", 24, false);
				animation.addByIndices('stressed', 'talking_apex_smirk', [0], "", 24, false);

				facingDir = 1;
				y -= 10;
				x += 70;

			case 'spooky':
				animation.addByIndices('normal', 'talking_sb_normal', [0], "", 24, false);
				animation.addByIndices('stressed', 'talking_sb_angry', [0], "", 24, false);

				facingDir = 1;
				y -= 45;
				x += 40;

			case 'monster':
				animation.addByIndices('normal', 'talking_collector_normal', [0], "", 24, false);
				animation.addByIndices('stressed', 'talking_collector_crazy', [0], "", 24, false);

				facingDir = 1;
				y -= 10;
				x += 70;

			case 'pico':
				animation.addByIndices('normal', 'talking_john_normal', [0], "", 24, false);
				animation.addByIndices('stressed', 'talking_john_what', [0], "", 24, false);

				facingDir = 1;
				flipX = true;
				y += 80;
				x += 40;

			case 'mom':
				animation.addByIndices('normal', 'talking_ry_normal', [0], "", 24, false);
				animation.addByIndices('stressed', 'talking_ry_tired', [0], "", 24, false);

				facingDir = 1;
				x += 40;

				if (PlayState.curStage == 'mall')
					y -= 98;
				else
					y -= 10;

			case 'senpai':
				animation.addByPrefix('normal', 'Senpai Portrait Enter', 24, false);
				facingDir = 1;

		}

		voice = '${character}Text';

		if (!Assets.exists(Paths.sound(voice)))
		{
			voice = 'pixelText';
		}

		//Adjusting for the new textboxes and I don't want to change all of the values I already did lolol shoot me I guess
		if (!pixelChar)

			y -= 16;

		setGraphicSize(Std.int(width * zoom));
		updateHitbox();
		scrollFactor.set();
		startX = x;
		startY = y;

	}

	public function enter():Void
	{

		if (pixelChar)

			return;

		x = startX;
		y = startY;
		alpha = 0;

		entering = true;

	}

	override function update(elapsed:Float)
	{

		if (entering)
		{

			if (((x > startX-40) && (facingDir == -1))
			|| ((x < startX+40) && (facingDir == 1)))
			{

				if (facingDir == -1)
					x -= 5;
				else
					x += 5;

				alpha += 0.2;

				if (((x < startX-40) && (facingDir == -1))
				|| ((x > startX+40) && (facingDir == 1)))
				{

					if (facingDir == -1)
						x = startX-40;
					else
						x = startX+40;

					entering = false;

				}

				//DOESN'T MATTER BUT SHUT UP LOLOL
				if (alpha > 1)
					alpha = 1;

			}

		}

		super.update(elapsed);

	}

}
