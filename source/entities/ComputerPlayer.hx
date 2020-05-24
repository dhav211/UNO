package entities;

import entities.Card;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import haxe.macro.Expr.Case;

class ComputerPlayer extends Player
{
	var timer:FlxTimer = new FlxTimer();
	var playState:PlayState;
	var cardToPlay:Card;

	public var order:Int = 0;
	public var name:String = "";

	var setPlayerNameColor:FlxTypedSignal<Int->FlxColor->Void> = new FlxTypedSignal<Int->FlxColor->Void>();

	override public function new(_playstate:PlayState, _topBar:TopBar, _order:Int, _nameList:Array<String>)
	{
		super(_playstate, _topBar);

		playState = _playstate;
		order = _order;
		name = SetRandomName(_nameList);
		timer.time = 1;

		setPlayerNameColor.add(_topBar._onSetCurrentPlayerNameColor);
	}

	public override function update()
	{
		if (isRoundStarted)
		{
			if (cardToPlay == null)
			{
				cardToPlay = GetCardToPlay();
			}
			else if (cardToPlay != null)
			{
				playstate._onSetLastPlayedCard(cardToPlay);

				if (cardToPlay.specialCard != NONE)
				{
					switch (cardToPlay.specialCard)
					{
						case DRAW_2:
							playstate._onDrawCards(2);
						case DRAW_4:
							playstate._onDrawCards(4);
						case REVERSE:
							playstate._onReverseCard();
						case SKIP:
							isSkipCardPlayed = true;
						case SWAP:
							SwapCards();
						case _:
							// No special card functions required
					}
				}

				if (cardToPlay.cardColor == WILD)
				{
					playstate._onWildCardSetColor(GetWildCardColor());
				}

				EndRound();
			}
		}
		else
		{
			if (!timer.active)
			{
				timer.start(1, onTimerFinished);
				setArrowPosition.dispatch(order);
				setPlayerNameColor.dispatch(order, FlxColor.YELLOW);
			}
		}
	}

	public override function StartRound()
	{
		cardToPlay = null;
		isRoundStarted = true;
		isSkipCardPlayed = false;
	}

	public override function EndRound()
	{
		if (cards.length == 0)
			playState.EndGame(this);
		isRoundStarted = false;
		playstate._onUpdateCardCount(order, cards.length);
		playstate.GoToNextPlayer(isSkipCardPlayed);

		setPlayerNameColor.dispatch(order, FlxColor.WHITE);
	}

	function SwapCards()
	{
		var playerToSwap:Player = GetPlayerWithFewestCards();

		if (playerToSwap != this)
		{
			playState._onSwapCards(playerToSwap);
		}
	}

	function GetPlayerWithFewestCards():Player
	{
		var currentPlayer:Player = playState.players[0];

		for (player in playState.players)
		{
			if (player != currentPlayer && player.cards.length < currentPlayer.cards.length)
				currentPlayer = player;
		}

		return currentPlayer;
	}

	function SetRandomName(_nameList:Array<String>):String
	{
		var nameToSet:String = "";
		var random:FlxRandom = new FlxRandom();

		for (name in _nameList)
		{
			var randomChoice = random.int(0, _nameList.length - 1);
			var randomName:String = _nameList[randomChoice];
			nameToSet = randomName;
			_nameList.remove(randomName);
		}

		return nameToSet;
	}

	function GetCardToPlay():Card
	{
		var lastPlayedCard:Card = playstate.lastPlayedCard;
		var cardFound:Card = null;
		var hasWildCard:Bool = false;

		while (cardFound == null)
		{
			for (card in cards)
			{
				if (card.cardColor == lastPlayedCard.cardColor || card.cardNumber == lastPlayedCard.cardNumber)
				{
					cardFound = card;
				}
			}

			if (cardFound == null) // Search for wild card
			{
				for (card in cards)
				{
					if (card.cardColor == WILD)
					{
						cardFound = card;
						hasWildCard = true;
					}
				}
				if (!hasWildCard)
					cards.push(playstate.DrawCard()); // Draw a card
			}
		}

		return cardFound;
	}

	function GetWildCardColor():CardColor // Checks which card color is most common in hand, then returns that as a the color to use
	{
		var redCount:Int = 0;
		var blueCount:Int = 0;
		var yellowCount:Int = 0;
		var greenCount:Int = 0;

		var mostCommonColor:CardColor = RED;

		for (card in cards) // gather all color amount in the entire hand
		{
			if (card.cardColor == RED)
				redCount++;
			else if (card.cardColor == BLUE)
				blueCount++;
			else if (card.cardColor == GREEN)
				greenCount++;
			else if (card.cardColor == YELLOW)
				yellowCount++;
		}

		if (blueCount > redCount) // Red will be set as the default color, but then this will check each color and see if any is higher than the other.
			mostCommonColor = BLUE;
		if (yellowCount > blueCount)
			mostCommonColor = YELLOW;
		if (greenCount > yellowCount)
			mostCommonColor = GREEN;

		return mostCommonColor;
	}

	function onTimerFinished(_timer:FlxTimer)
	{
		StartRound();
	}
}
