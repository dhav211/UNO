package entities;

import flixel.FlxSprite;

enum CardColor
{
	RED;
	BLUE;
	GREEN;
	YELLOW;
	WILD;
}

enum SpecialCard
{
	DRAW_2;
	DRAW_4;
	REVERSE;
	CHOOSE_COLOR;
	SKIP;
	SWAP;
	NONE;
}

class Card extends FlxSprite
{
	public var cardColor:CardColor;
	public var specialCard:SpecialCard;
	public var cardNumber:Int;

	public function new(x:Float, y:Float, _cardColor:CardColor, _specialCard:SpecialCard, _cardNumber:Int)
	{
		super(x, y);

		cardColor = _cardColor;
		specialCard = _specialCard;
		cardNumber = _cardNumber;

		loadGraphic(SetGraphic(), false, 32, 48);
	}

	public function SetGraphic():String
	{
		switch (cardColor)
		{
			case RED:
				switch cardNumber
				{
					case 0:
						return AssetPaths.Red0__png;
					case 1:
						return AssetPaths.Red1__png;
					case 2:
						return AssetPaths.Red2__png;
					case 3:
						return AssetPaths.Red3__png;
					case 4:
						return AssetPaths.Red4__png;
					case 5:
						return AssetPaths.Red5__png;
					case 6:
						return AssetPaths.Red6__png;
					case 7:
						return AssetPaths.Red7__png;
					case 8:
						return AssetPaths.Red8__png;
					case 9:
						return AssetPaths.Red9__png;
					case 10:
						return AssetPaths.RedReverse__png;
					case 11:
						return AssetPaths.RedDraw2__png;
					case 12:
						return AssetPaths.RedSkip__png;
				}

			case BLUE:
				switch cardNumber
				{
					case 0:
						return AssetPaths.Blue0__png;
					case 1:
						return AssetPaths.Blue1__png;
					case 2:
						return AssetPaths.Blue2__png;
					case 3:
						return AssetPaths.Blue3__png;
					case 4:
						return AssetPaths.Blue4__png;
					case 5:
						return AssetPaths.Blue5__png;
					case 6:
						return AssetPaths.Blue6__png;
					case 7:
						return AssetPaths.Blue7__png;
					case 8:
						return AssetPaths.Blue8__png;
					case 9:
						return AssetPaths.Blue9__png;
					case 10:
						return AssetPaths.BlueReverse__png;
					case 11:
						return AssetPaths.BlueDraw2__png;
					case 12:
						return AssetPaths.BlueSkip__png;
				}

			case GREEN:
				switch cardNumber
				{
					case 0:
						return AssetPaths.Green0__png;
					case 1:
						return AssetPaths.Green1__png;
					case 2:
						return AssetPaths.Green2__png;
					case 3:
						return AssetPaths.Green3__png;
					case 4:
						return AssetPaths.Green4__png;
					case 5:
						return AssetPaths.Green5__png;
					case 6:
						return AssetPaths.Green6__png;
					case 7:
						return AssetPaths.Green7__png;
					case 8:
						return AssetPaths.Green8__png;
					case 9:
						return AssetPaths.Green9__png;
					case 10:
						return AssetPaths.GreenReverse__png;
					case 11:
						return AssetPaths.GreenDraw2__png;
					case 12:
						return AssetPaths.GreenSkip__png;
				}

			case YELLOW:
				switch cardNumber
				{
					case 0:
						return AssetPaths.Yellow0__png;
					case 1:
						return AssetPaths.Yellow1__png;
					case 2:
						return AssetPaths.Yellow2__png;
					case 3:
						return AssetPaths.Yellow3__png;
					case 4:
						return AssetPaths.Yellow4__png;
					case 5:
						return AssetPaths.Yellow5__png;
					case 6:
						return AssetPaths.Yellow6__png;
					case 7:
						return AssetPaths.Yellow7__png;
					case 8:
						return AssetPaths.Yellow8__png;
					case 9:
						return AssetPaths.Yellow9__png;
					case 10:
						return AssetPaths.YellowReverse__png;
					case 11:
						return AssetPaths.YellowDraw2__png;
					case 12:
						return AssetPaths.YellowSkip__png;
				}

			case WILD:
				switch (cardNumber)
				{
					case 0:
						return AssetPaths.DrawFour__png;
					case 1:
						return AssetPaths.ChooseColor__png;
					case 2:
						return AssetPaths.Swap__png;
				}
		}

		return AssetPaths.Blue0__png;
	}
}
