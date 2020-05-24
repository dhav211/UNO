import entities.Card;
import entities.ComputerPlayer;
import entities.Player;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TopBar extends FlxTypedGroup<FlxObject>
{
	var divider:FlxSprite;
	var arrow:FlxText;

	var currentColor:FlxText;
	var playerNames:Array<FlxText>;
	var cardCounts:Array<FlxText>;

	public var turnOrder:Int = 1;

	public function new()
	{
		super();

		divider = new FlxSprite(0, 32);
		divider.loadGraphic(AssetPaths.top_divider__png, false, 320, 8);
		arrow = new FlxText(0, 0, 8, ">", 8);
		currentColor = new FlxText((FlxG.width / 2) - 20, 40, 40, "Red", 8);
		currentColor.alignment = CENTER;

		playerNames = new Array<FlxText>();
		cardCounts = new Array<FlxText>();

		add(divider);
		add(arrow);
		add(currentColor);
	}

	public function SetUp(_players:Array<Player>)
	{
		for (i in 0...3)
		{
			playerNames[i] = new FlxText(0, 0, 40);
			playerNames[i].alignment = CENTER;
			add(playerNames[i]);

			cardCounts[i] = new FlxText(0, 0, 40);
			cardCounts[i].alignment = CENTER;
			add(cardCounts[i]);
		}

		SetPlayerNames(_players);
		SetNamePositions();
		SetCardCountPositions();
	}

	public function SetCardCountAmount(_index:Int, _amount:Int)
	{
		cardCounts[_index].text = Std.string(_amount);
	}

	public function SetCurrentColor(_cardColor:CardColor)
	{
		currentColor.text = SetCurrentColorText(_cardColor);
		currentColor.color = SetCurrentColorFontColor(_cardColor);
	}

	function SetCurrentColorText(_cardColor:CardColor):String
	{
		switch (_cardColor)
		{
			case RED:
				return "Red";
			case BLUE:
				return "Blue";
			case GREEN:
				return "Green";
			case YELLOW:
				return "Yellow";
			case WILD:
				return "Wild";
		}
	}

	function SetCurrentColorFontColor(_cardColor:CardColor):FlxColor
	{
		switch (_cardColor)
		{
			case RED:
				return FlxColor.RED;
			case BLUE:
				return FlxColor.BLUE;
			case GREEN:
				return FlxColor.GREEN;
			case YELLOW:
				return FlxColor.YELLOW;
			case WILD:
				return FlxColor.WHITE;
		}
	}

	function SetPlayerNames(_players:Array<Player>)
	{
		var currentPlayerIndex:Int = 0;

		for (player in _players)
		{
			if (Std.is(player, ComputerPlayer))
			{
				var computerPlayer:ComputerPlayer = cast(player, ComputerPlayer);
				playerNames[currentPlayerIndex].text = computerPlayer.name;

				currentPlayerIndex++;
			}
		}
	}

	function SetNamePositions()
	{
		var startingPositionX:Float = FlxG.width / 4 - 20;
		var positionY:Float = 4;
		var spacing:Float = (FlxG.width / 2) - (FlxG.width / 4);

		for (i in 0...playerNames.length)
		{
			playerNames[i].setPosition(startingPositionX + (spacing * i), positionY);
		}
	}

	function SetCardCountPositions()
	{
		for (i in 0...cardCounts.length)
		{
			cardCounts[i].setPosition(playerNames[i].x, playerNames[i].y + 10);
		}
	}

	public function _onSetCurrentPlayerNameColor(_order:Int, _color:FlxColor)
	{
		playerNames[_order].color = _color;
	}

	public function _onSetArrowPosition(_order:Int)
	{
		if (_order < 3)
		{
			if (turnOrder > 0)
			{
				arrow.setPosition(playerNames[_order].x + 40, playerNames[_order].y);
				arrow.text = ">";
			}
			else if (turnOrder < 0)
			{
				arrow.setPosition(playerNames[_order].x - 10, playerNames[_order].y);
				arrow.text = "<";
			}
		}
		else if (_order >= 3)
		{
			if (turnOrder > 0)
			{
				arrow.setPosition(20, playerNames[0].y);
				arrow.text = ">";
			}
			else if (turnOrder < 0)
			{
				arrow.setPosition(FlxG.width - 20, playerNames[0].y);
				arrow.text = "<";
			}
		}
	}
}
