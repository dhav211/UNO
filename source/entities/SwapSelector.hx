package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class SwapSelector extends FlxObject
{
	var players:Array<ComputerPlayer>;
	var playerNamesToSelect:Array<FlxText> = [];
	var box:FlxSprite;

	var isOpen:Bool = false;
	var currentPlayerIndex:Int = 0;

	var selected:FlxColor = FlxColor.YELLOW;
	var notSelected:FlxColor = FlxColor.WHITE;

	var playersHand:PlayersHand;
	var playState:PlayState; // Delete THIS!

	public function new(_playState:PlayState, _playersHand:PlayersHand)
	{
		super();
		playState = _playState; // DELETE THIS
		playersHand = _playersHand;
		players = SetPlayers(_playState);

		CreateBoxSprite(_playState);
		CreatePlayerNameButtons(_playState);
		SetPlayerNamePositions();

		box.visible = false;

		for (name in playerNamesToSelect)
			name.visible = false;
	}

	public function ChooseName()
	{
		if (isOpen)
		{
			if (FlxG.keys.anyJustPressed([DOWN]))
			{
				playerNamesToSelect[currentPlayerIndex].color = notSelected;

				currentPlayerIndex++;

				if (currentPlayerIndex >= playerNamesToSelect.length)
					currentPlayerIndex = 0;

				playerNamesToSelect[currentPlayerIndex].color = selected;
			}
			else if (FlxG.keys.anyJustPressed([UP]))
			{
				playerNamesToSelect[currentPlayerIndex].color = notSelected;

				currentPlayerIndex--;

				if (currentPlayerIndex < 0)
					currentPlayerIndex = playerNamesToSelect.length - 1;

				playerNamesToSelect[currentPlayerIndex].color = selected;
			}
		}
	}

	public function SwapCards()
	{
		if (isOpen && FlxG.keys.anyJustPressed([SPACE]))
		{
			playState._onSwapCards(playState.players[currentPlayerIndex + 1]);
			Hide();
		}
	}

	public function Show()
	{
		box.visible = true;

		for (name in playerNamesToSelect)
			name.visible = true;

		isOpen = true;
		currentPlayerIndex = 0;

		playerNamesToSelect[currentPlayerIndex].color = selected;
	}

	public function Hide()
	{
		box.visible = false;

		for (name in playerNamesToSelect)
			name.visible = false;

		isOpen = false;

		playersHand.CloseSwapSelection();
	}

	function SetPlayers(_playState:PlayState):Array<ComputerPlayer> // Fill players array with only computer players
	{
		var tempPlayers:Array<ComputerPlayer> = new Array<ComputerPlayer>();

		for (player in _playState.players)
		{
			if (Std.is(player, ComputerPlayer))
				tempPlayers.push(cast(player, ComputerPlayer));
		}

		return tempPlayers;
	}

	function CreateBoxSprite(_playState:PlayState)
	{
		var screenCenterX:Float = FlxG.width / 2;
		var screenCenterY:Float = FlxG.height / 2;

		box = new FlxSprite(screenCenterX - 36, screenCenterY - 36);
		box.loadGraphic(AssetPaths.color_selector_bg__png, false, 64, 64);
		_playState.add(box);
	}

	function CreatePlayerNameButtons(_playState:PlayState)
	{
		for (i in 0...3)
		{
			var playerName:FlxText = new FlxText(0, 0, 40, players[i].name);
			playerName.alignment = CENTER;
			playerNamesToSelect.push(playerName);
			_playState.add(playerNamesToSelect[i]);
		}
	}

	function SetPlayerNamePositions()
	{
		var screenCenterX:Float = FlxG.width / 2;
		var screenCenterY:Float = FlxG.height / 2;
		var spacing:Float = 16;
		var startingPositionY:Float = screenCenterY - (spacing + 8);
		var startingPositionX:Float = screenCenterX - 20;

		for (i in 0...3)
		{
			playerNamesToSelect[i].setPosition(startingPositionX, startingPositionY + (spacing * i));
		}
	}
}
