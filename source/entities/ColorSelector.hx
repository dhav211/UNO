package entities;

import entities.Card.CardColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;

enum ColorSelected
{
	RED;
	BLUE;
	GREEN;
	YELLOW;
}

class ColorSelector extends FlxObject
{
	var box:FlxSprite;
	var red:FlxSprite;
	var blue:FlxSprite;
	var green:FlxSprite;
	var yellow:FlxSprite;
	var playersHand:PlayersHand;
	var colors:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var currentColor:ColorSelected = RED;
	var tween:FlxTween;
	var isOpen:Bool = false;

	var wildCardSetColor:FlxTypedSignal<CardColor->Void> = new FlxTypedSignal<CardColor->Void>();

	public function new(_playState:PlayState, _playersHand:PlayersHand)
	{
		super();
		playersHand = _playersHand;
		AddSprites(_playState);
		_playState.add(colors);

		box.visible = false;
		red.visible = false;
		blue.visible = false;
		green.visible = false;
		yellow.visible = false;

		wildCardSetColor.add(_playState._onWildCardSetColor);
	}

	public function ChooseColor()
	{
		if (isOpen && !tween.active)
		{
			if (FlxG.keys.anyJustPressed([UP, DOWN]))
			{
				switch (currentColor)
				{
					case RED:
						currentColor = GREEN;
						ShrinkColor(red);
						SetToBackOfGroup(green);
						ExpandColor(green);
					case BLUE:
						currentColor = YELLOW;
						ShrinkColor(blue);
						SetToBackOfGroup(yellow);
						ExpandColor(yellow);
					case GREEN:
						currentColor = RED;
						ShrinkColor(green);
						SetToBackOfGroup(red);
						ExpandColor(red);
					case YELLOW:
						currentColor = BLUE;
						ShrinkColor(yellow);
						SetToBackOfGroup(blue);
						ExpandColor(blue);
				}
			}
			else if (FlxG.keys.anyJustPressed([RIGHT, LEFT]))
			{
				switch (currentColor)
				{
					case RED:
						currentColor = BLUE;
						ShrinkColor(red);
						SetToBackOfGroup(blue);
						ExpandColor(blue);
					case BLUE:
						currentColor = RED;
						ShrinkColor(blue);
						SetToBackOfGroup(red);
						ExpandColor(red);
					case GREEN:
						currentColor = YELLOW;
						ShrinkColor(green);
						SetToBackOfGroup(yellow);
						ExpandColor(yellow);
					case YELLOW:
						currentColor = GREEN;
						ShrinkColor(yellow);
						SetToBackOfGroup(green);
						ExpandColor(green);
				}
			}

			if (FlxG.keys.anyJustPressed([SPACE]))
			{
				switch (currentColor)
				{
					case RED:
						wildCardSetColor.dispatch(RED);
					case BLUE:
						wildCardSetColor.dispatch(BLUE);
					case GREEN:
						wildCardSetColor.dispatch(GREEN);
					case YELLOW:
						wildCardSetColor.dispatch(YELLOW);
				}

				Hide();
			}
		}
	}

	public function Hide()
	{
		box.visible = false;
		red.visible = false;
		blue.visible = false;
		green.visible = false;
		yellow.visible = false;

		isOpen = false;

		switch (currentColor)
		{
			case RED:
				red.scale.set(1, 1);

			case BLUE:
				blue.scale.set(1, 1);

			case GREEN:
				green.scale.set(1, 1);

			case YELLOW:
				yellow.scale.set(1, 1);
		}

		playersHand.CloseColorSelection();
	}

	public function Show()
	{
		box.visible = true;
		red.visible = true;
		blue.visible = true;
		green.visible = true;
		yellow.visible = true;

		isOpen = true;
		currentColor = RED;

		SetToBackOfGroup(red);
		ExpandColor(red);
	}

	function ExpandColor(_color:FlxSprite)
	{
		tween = FlxTween.tween(_color, {"scale.x": 1.5, "scale.y": 1.5}, 0.3);
	}

	function ShrinkColor(_color:FlxSprite)
	{
		tween = FlxTween.tween(_color, {"scale.x": 1, "scale.y": 1}, 0.3);
	}

	function SetToBackOfGroup(_color:FlxSprite) // Moves a color to back of the group by removing and reinserting it
	{
		colors.remove(_color);
		colors.insert(colors.length, _color);
	}

	function AddSprites(_playState:PlayState)
	{
		var screenCenterX = FlxG.width / 2;
		var screenCenterY = FlxG.height / 2;

		box = new FlxSprite(screenCenterX - 36, screenCenterY - 36);
		box.loadGraphic(AssetPaths.color_selector_bg__png, false, 64, 64);
		_playState.add(box);

		red = new FlxSprite(screenCenterX - 24, screenCenterY - 26);
		red.loadGraphic(AssetPaths.red__png, false, 24, 26);
		colors.add(red);

		blue = new FlxSprite(screenCenterX, screenCenterY - 26);
		blue.loadGraphic(AssetPaths.blue__png, false, 24, 26);
		colors.add(blue);

		green = new FlxSprite(screenCenterX - 24, screenCenterY);
		green.loadGraphic(AssetPaths.green__png, false, 24, 26);
		colors.add(green);

		yellow = new FlxSprite(screenCenterX, screenCenterY);
		yellow.loadGraphic(AssetPaths.yellow__png, false, 24, 26);
		colors.add(yellow);
	}
}
