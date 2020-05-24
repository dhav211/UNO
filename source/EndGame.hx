import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.system.System;
import openfl.Lib;

class EndGame extends FlxTypedGroup<FlxText>
{
	var endGameText:FlxText = new FlxText(0, 0, FlxG.width, "", 16);
	var restart:FlxText = new FlxText(0, 0, FlxG.width, "Restart", 16);
	var quit:FlxText = new FlxText(0, 0, FlxG.width, "Quit", 16);
	var playState:PlayState;

	var currentSelectionIndex = 0;

	public function new(_playState:PlayState)
	{
		super();

		playState = _playState;

		endGameText.alignment = CENTER;
		restart.alignment = CENTER;
		quit.alignment = CENTER;

		endGameText.setPosition(0, (FlxG.height / 2) - 18);
		restart.setPosition(0, ((FlxG.height / 2) - 18) + 36);
		quit.setPosition(0, ((FlxG.height / 2) - 18) + 56);

		add(endGameText);
		add(restart);
		add(quit);
	}

	public function ChooseSelection()
	{
		if (FlxG.keys.anyJustPressed([UP]))
		{
			currentSelectionIndex--;

			if (currentSelectionIndex < 0)
			{
				currentSelectionIndex = 1;
			}

			if (currentSelectionIndex == 0)
			{
				restart.color = FlxColor.YELLOW;
				quit.color = FlxColor.WHITE;
			}
			else if (currentSelectionIndex == 1)
			{
				restart.color = FlxColor.WHITE;
				quit.color = FlxColor.YELLOW;
			}
		}
		else if (FlxG.keys.anyJustPressed([DOWN]))
		{
			currentSelectionIndex++;

			if (currentSelectionIndex > 1)
			{
				currentSelectionIndex = 0;
			}

			if (currentSelectionIndex == 0)
			{
				restart.color = FlxColor.YELLOW;
				quit.color = FlxColor.WHITE;
			}
			else if (currentSelectionIndex == 1)
			{
				restart.color = FlxColor.WHITE;
				quit.color = FlxColor.YELLOW;
			}
		}
	}

	public function Select()
	{
		if (FlxG.keys.anyJustPressed([SPACE]))
		{
			if (currentSelectionIndex == 0)
			{
				playState.RestartGame();
				Hide();
			}
			if (currentSelectionIndex == 1)
			{
				System.exit(0);
			}
		}
	}

	public function Show(_winnerName:String)
	{
		endGameText.text = _winnerName + " won the game!";

		endGameText.visible = true;
		restart.visible = true;
		quit.visible = true;

		currentSelectionIndex = 0;
		restart.color = FlxColor.YELLOW;
	}

	public function Hide()
	{
		endGameText.visible = false;
		restart.visible = false;
		quit.visible = false;
	}
}
