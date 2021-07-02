package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	public var boxOffsets:Map<String, Array<Dynamic>>;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitList:Map<String, CharacterPortrait>;
	var portraitAnim:String;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var pixelBox:Bool = true;
	var boxStyle:String = "";
	var lastBoxStyle:String = "";

	var textSound:String;
	var off_x:Int = -60;
	var off_y:Int = 4;
	var textbox_width:Float = 0.7;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		//Dictionaries
		boxOffsets = new Map<String, Array<Dynamic>>();
		portraitList = new Map<String, CharacterPortrait>();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		box = new FlxSprite(0, 45);
		
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				pixelBox = false;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal0', 24, true);
				box.animation.addByPrefix('loudOpen', 'speech bubble loud open', 24, false);
				box.animation.addByPrefix('loud', 'AHH speech bubble', 24, true);
				boxOffset('normal', 50, 15);
				//It was 50 before, and was centered pretty close. so bringing it to 40 moved it to the right, meaning DECREASING BRINGS TO THE RIGHT
				boxOffset('normalOpen', 40, 65);
				boxOffset('loud', 80, 28);
				boxOffset('loudOpen', 105, 35);
			case 'senpai':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
			case 'thorns':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
		}
		
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		this.dialogueList = dialogueList;
		
		if (dialogueList == null)
			return;

		var names:Array<String> = new Array<String>();
		var doAFlip = false;

		for (i in 0...dialogueList.length)
		{

			//Character name default to BF
			var newChar:String = "bf";

			//Get character name
			var lmost = dialogueList[i].indexOf(":");
			var rmost = dialogueList[i].indexOf(":",lmost+1);
			if (lmost != -1 && rmost != -1)
			{
				newChar = dialogueList[i].substring(lmost+1,rmost);
			}

			var portraitToAdd = new CharacterPortrait(0, 40, newChar, pixelBox);
			addPortrait(portraitToAdd);

			if (portraitToAdd.facingDir == 1)
			{

				if (pixelBox)
				{
					portraitToAdd.screenCenter(X);

				}
				//First place in the array
				else if (i == 0)
				{

					doAFlip = true;
					
				}

			}
			
		}
		
		getBoxStyle();
		boxFlip(doAFlip);
		var startAnimationAgain = box.animation.curAnim.name;

		if (pixelBox)
		{

			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));

		}
		else
		{

			box.setGraphicSize(Std.int(box.width * 1));

		}

		box.updateHitbox();
		//I literally only have this code here because I'm at my wit's end and I want to get this over with and I know it works, it's duplicate code but so what
		boxFlip(doAFlip);
		boxAnim(startAnimationAgain);
		add(box);

		var textcutoff = Std.int(FlxG.width * 0.6);

		if (!pixelBox)

			textcutoff = Std.int(FlxG.width * textbox_width);

		dropText = new FlxText(242, 502, textcutoff, "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFF7E7E7E;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, textcutoff, "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		//Offset non-pixel textbox
		if (!pixelBox) {

			swagDialogue.x += off_x;
			swagDialogue.y += off_y;
			dropText.x += off_x;
			dropText.y += off_y;
		
		}

	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	function addPortrait(portrait:CharacterPortrait)
	{

		add(portrait);
		portraitList.set(portrait.character, portrait);

	}

	function boxFlip(imFlipped:Bool):Void
	{

		if (pixelBox)
		{
			box.screenCenter(X);
			return;
		}
		else
		{
			
			box.flipX = imFlipped;
			box.screenCenter(X);
			if (!imFlipped)
			{
					
				//Add initial amount
				box.x += 40;

				// B U M P
				if (boxStyle != 'n')

					box.x += 20;

			}
			else
			{

				//Add initial amount
				box.x += 26;

				// B U M P
				if (boxStyle != 'n')

					box.x += 49;

			}

		}

	}

	function getBoxStyle():Void
	{

		lastBoxStyle = boxStyle;
		var lmost = dialogueList[0].indexOf("[");
		var rmost = dialogueList[0].indexOf("]",lmost);

		if (lmost != -1 && rmost != -1)
		{

			boxStyle = dialogueList[0].substring(lmost+1,rmost);
			var righthand = dialogueList[0].substring(0,lmost);
			var lefthand = dialogueList[0].substring(rmost+1);
			dialogueList[0] = righthand + lefthand;

		}
		else
		{
			
			boxStyle = "n";

		}

		if (lastBoxStyle != boxStyle) {

			if (boxStyle == "n")
			{
				boxAnim('normalOpen');

				if (!pixelBox)
					box.y = 443;
			}

			if (boxStyle == "l")
			{
				boxAnim('loudOpen');

				if (!pixelBox)
					box.y = 325;
			}

		}

	}

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitList.get('senpai').visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitList.get('senpai').color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				boxAnim('normal');
				dialogueOpened = true;

				if (!pixelBox)
				{
					swagDialogue.resetText(dialogueList[0]);
					swagDialogue.start(0.04, true);
				}
			}
			else if (box.animation.curAnim.name == 'loudOpen' && box.animation.curAnim.finished)
			{
				boxAnim('loud');
				dialogueOpened = true;
				if (!pixelBox)
				{
					swagDialogue.resetText(dialogueList[0]);
					swagDialogue.start(0.04, true);
				}
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{

			if (!isEnding)
			{
				
				switch (pixelBox)
				{

					case (true):
						FlxG.sound.play(Paths.sound('clickText'), 0.8);

					case (false):
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

				}

			}

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					swagDialogue.skip();

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						for (char in portraitList.keys()) {

							if (pixelBox)

								portraitList.get(char).visible = false;

							else

								portraitList.get(char).alpha -= 1 / 4;

						}
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				getBoxStyle();
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		if (!box.animation.name.toLowerCase().contains("open") || pixelBox)
		{
			swagDialogue.resetText(dialogueList[0]);
			swagDialogue.start(0.04, true);
		}
		else
		{

			swagDialogue.resetText(" ");
			swagDialogue.start(0.04, true);
			dropText.text = swagDialogue.text;

		}

		var charSound = 'pixelText';
		
		for (char in portraitList.keys())
		{

			var recieved = portraitList.get(char);

			if (char == curCharacter)
			{

				charSound = recieved.voice;
				
				if (!recieved.visible || (!pixelBox && (lastBoxStyle != boxStyle)))
				{

					recieved.visible = true;

					if (pixelBox)
						
						recieved.animation.play(portraitAnim);

					if (!box.animation.name.toLowerCase().contains("open") || pixelBox)

						recieved.enter();

					else
					{
						recieved.visible = false;
						new FlxTimer().start(0.15, function(tmr:FlxTimer)
						{
							recieved.visible = true;
							recieved.enter();
						}, 1);
					}

					var doAFlip:Bool = (!pixelBox && recieved.facingDir == 1) ? true : false;
					boxFlip(doAFlip);

				}
				
				if (!pixelBox)

					recieved.animation.play(portraitAnim);

			}
			else
			{

				recieved.visible = false;

			}

		}

		if (pixelBox)

			charSound = 'pixelText';

		swagDialogue.sounds = [FlxG.sound.load(Paths.sound(charSound), 0.6)];

		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitList.get('senpai').visible = false;

	}

	function cleanDialog():Void
	{
		//Get character name
		var lmost = dialogueList[0].indexOf(":");
		var rmost = dialogueList[0].indexOf(":",lmost+1);

		if (lmost != -1 && rmost != -1)
		{
			curCharacter = dialogueList[0].substring(lmost+1,rmost);
			var righthand = dialogueList[0].substring(0,lmost);
			var lefthand = dialogueList[0].substring(rmost+1);
			dialogueList[0] = righthand + lefthand;
		}

		//Character animation
		var lmost2 = dialogueList[0].indexOf("{");
		var rmost2 = dialogueList[0].indexOf("}",lmost2);
		var animLetter;

		if (lmost2 != -1 && rmost2 != -1)
		{

			animLetter = dialogueList[0].substring(lmost2+1,rmost2);
			var righthand = dialogueList[0].substring(0,lmost2);
			var lefthand = dialogueList[0].substring(rmost2+1);
			dialogueList[0] = righthand + lefthand;

		}
		else
		{
			
			animLetter = "n";

		}

		switch (animLetter)
		{
			case "n":
				portraitAnim = "normal";

			case "s":
				portraitAnim = "stressed";
		}

	}

	public function boxAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		box.animation.play(AnimName, Force, Reversed, Frame);

		if (!pixelBox)
		{

			var daOffset = boxOffsets.get(box.animation.name);
			if (daOffset != null)
			{
				box.offset.set(daOffset[0], daOffset[1]);
			}
			else
				box.offset.set(0, 0);

		}

	}

	//literally just copied from the Character code
	public function boxOffset(name:String, x:Float = 0, y:Float = 0)
	{
		boxOffsets[name] = [x, y];
	}

}