package game;

import utilities.NoteVariables;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rawNoteData:Int = 0;

	public var modifiedByLua:Bool;
	public var modAngle:Float = 0;
	public var localAngle:Float = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 100 - ((PlayState.SONG.keyCount - 4) * 16);
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y = -2000;

		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;
		var isSchool:Bool = daStage == 'school' || daStage == "evil-school";

		switch (daStage)
		{
			/*
			case 'school' | 'evil-school':
				loadGraphic(Paths.image('ui/arrows-pixels', 'shared'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('ui/arrowEnds', 'shared'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			*/

			default:
				frames = Paths.getSparrowAtlas('ui skins/' + PlayState.SONG.ui_Skin + "/arrows/default", 'shared');

				animation.addByPrefix("default", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + "0");
				animation.addByPrefix("hold", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + " hold0");
				animation.addByPrefix("holdend", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + " hold end0");

				setGraphicSize(Std.int((width * Std.parseFloat(PlayState.instance.ui_Settings[0])) * (Std.parseFloat(PlayState.instance.ui_Settings[2]) - ((PlayState.SONG.keyCount - 4) * 0.06))));
				updateHitbox();
				
				antialiasing = PlayState.instance.ui_Settings[3] == "true";
		}

		x += swagWidth * noteData;
		animation.play("default");

		// trace(prevNote);
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			if(PlayState.SONG.ui_Skin != 'pixel')
				x += width / 2;

			animation.play("holdend");
			updateHitbox();

			if(PlayState.SONG.ui_Skin != 'pixel')
				x -= width / 2;

			if (PlayState.SONG.ui_Skin == 'pixel')
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play("hold");

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		if (mustPress)
		{
			// old ass code i guess \_(:/)_/
			/*
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
				canBeHit = true;
			else
				canBeHit = false;
			*/

			// taken from kade engine moment
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
