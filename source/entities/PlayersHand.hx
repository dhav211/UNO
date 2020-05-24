package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;

enum SelectionState
{
	CARD;
	COLOR;
	SWAP_CARDS;
}

class PlayersHand
{
	var hand:Array<Card> = [];
	var cardSelected:Card;
	var player:Player;

	var cardSelectedIndex:Int;
	var handYPosition:Float;
	var tween:FlxTween;
	var playstate:PlayState;
	var drawCard:FlxSprite;
	var drawSelected:Bool = false;
	var currentSelectionState:SelectionState = CARD;

	var colorSelector:ColorSelector;
	var swapSelector:SwapSelector;

	var setLastPlayedCard:FlxTypedSignal<Card->Void> = new FlxTypedSignal<Card->Void>();
	var addCardToDisplay:FlxTypedSignal<Card->Void> = new FlxTypedSignal<Card->Void>();
	var removeCardToDisplay:FlxTypedSignal<Card->Void> = new FlxTypedSignal<Card->Void>();

	public function new(_playstate:PlayState, _playersCards:Array<Card>, _player:Player)
	{
		playstate = _playstate;
		for (card in _playersCards)
			hand.push(card);
		player = _player;

		setLastPlayedCard.add(_playstate._onSetLastPlayedCard);
		addCardToDisplay.add(_playstate._onAddCardToDisplay);
		removeCardToDisplay.add(_playstate._onRemoveCardToDisplay);

		colorSelector = new ColorSelector(_playstate, this);
		swapSelector = new SwapSelector(_playstate, this);
		playstate.add(colorSelector);
		playstate.add(swapSelector);

		LoadDrawCard();
	}

	public function update()
	{
		if (currentSelectionState == CARD)
		{
			ChooseCard();
			SelectCard();
			DrawCard();
		}
		else if (currentSelectionState == COLOR)
		{
			colorSelector.ChooseColor();
		}
		else if (currentSelectionState == SWAP_CARDS)
		{
			swapSelector.ChooseName();
			swapSelector.SwapCards();
		}
	}

	public function UpdateHand()
	{
		for (i in 0...hand.length)
		{
			removeCardToDisplay.dispatch(hand[i]);
		}

		// This bit here is odd, because the hand and player.cards are basically the same array, however when cards are swapped it causes trouble.
		// So this removes all cards from the hand, then adds the players cards back in. Odd, but it works

		while (hand.length > 0)
			hand.pop();

		for (card in player.cards)
			hand.push(card);

		for (i in 0...hand.length) // Finally adds the cards back to the play state
		{
			addCardToDisplay.dispatch(hand[i]);
		}

		SetCardPositions();
		cardSelectedIndex = 0;
		cardSelected = hand[cardSelectedIndex];

		if (currentSelectionState == CARD && player.isRoundStarted)
			tween = FlxTween.tween(hand[0], {x: hand[0].x, y: hand[0].y - 40}, 0.2);
	}

	function ChooseCard() // Lets player choose a card but arrow key input
	{
		if (FlxG.keys.anyPressed([RIGHT]) && !tween.active && hand.length > 1)
		{
			if (drawSelected)
			{
				drawCard.visible = false;
				drawSelected = false;
			}

			if (hand[cardSelectedIndex].y != handYPosition)
				tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y + 40}, 0.2);

			cardSelectedIndex++;

			if (cardSelectedIndex == hand.length)
				cardSelectedIndex = 0;

			cardSelected = hand[cardSelectedIndex];
			tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y - 40}, 0.2);
		}
		else if (FlxG.keys.anyPressed([LEFT]) && !tween.active)
		{
			if (drawSelected)
			{
				drawCard.visible = false;
				drawSelected = false;
			}

			if (hand[cardSelectedIndex].y != handYPosition)
				tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y + 40}, 0.2);

			cardSelectedIndex--;

			if (cardSelectedIndex == -1)
				cardSelectedIndex = hand.length - 1;

			cardSelected = hand[cardSelectedIndex];
			tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y - 40}, 0.2);
		}
	}

	function SelectCard()
	{
		if (FlxG.keys.anyJustPressed([SPACE]) && !drawSelected)
		{
			var lastPlayedCard:Card = playstate.lastPlayedCard;

			if (cardSelected.cardColor != WILD)
			{
				if (cardSelected.cardColor == lastPlayedCard.cardColor || cardSelected.cardNumber == lastPlayedCard.cardNumber)
				{
					tween = FlxTween.tween(cardSelected, {x: lastPlayedCard.x, y: lastPlayedCard.y}, 0.5, {onComplete: MakePlayedCardLastPlayedCard});

					if (cardSelected.specialCard == REVERSE)
					{
						playstate._onReverseCard();
					}
					else if (cardSelected.specialCard == DRAW_2)
					{
						playstate._onDrawCards(2);
					}
					else if (cardSelected.specialCard == SKIP)
					{
						player.isSkipCardPlayed = true;
					}
				}
			}
			else if (cardSelected.cardColor == WILD)
			{
				tween = FlxTween.tween(cardSelected, {x: lastPlayedCard.x, y: lastPlayedCard.y}, 0.5, {onComplete: MakePlayedCardLastPlayedCard});

				if (cardSelected.specialCard == DRAW_4)
				{
					playstate._onDrawCards(4);
				}
			}
		}
	}

	public function DrawCard()
	{
		if (FlxG.keys.anyJustPressed([UP]) && !tween.active && !drawSelected) // Activate the draw card sprite
		{
			drawSelected = true;
			drawCard.visible = true;

			if (hand[cardSelectedIndex].y != handYPosition)
				tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y + 40}, 0.2);
		}
		else if (FlxG.keys.anyJustPressed([DOWN]) && !tween.active && drawSelected) // Remove draw card sprite
		{
			drawSelected = false;
			drawCard.visible = false;

			tween = FlxTween.tween(hand[cardSelectedIndex], {x: hand[cardSelectedIndex].x, y: hand[cardSelectedIndex].y - 40}, 0.2);
		}

		if (FlxG.keys.anyJustPressed([SPACE]) && drawSelected) // Draw a card and add to the players hand
		{
			drawSelected = false;
			drawCard.visible = false;

			player.cards.push(playstate.DrawCard());
			UpdateHand();
		}
	}

	function MakePlayedCardLastPlayedCard(_tween:FlxTween)
	{
		setLastPlayedCard.dispatch(cardSelected);

		if (cardSelected.cardColor == WILD)
		{
			OpenColorSelector();
		}
		else
		{
			player.EndRound();
		}
	}

	function OpenColorSelector()
	{
		playstate.lastPlayedCard.visible = false;
		currentSelectionState = COLOR;
		colorSelector.Show();
	}

	function OpenSwapSelector()
	{
		playstate.lastPlayedCard.visible = false;
		currentSelectionState = SWAP_CARDS;
		swapSelector.Show();
	}

	public function CloseColorSelection()
	{
		if (cardSelected.specialCard != SWAP) // If not a swap card, then just proceed with ending the round
		{
			playstate.lastPlayedCard.visible = true;
			currentSelectionState = CARD;
			player.EndRound();
		}
		else if (cardSelected.specialCard == SWAP) // Once player chooses the wild card color, now would be the time to Select Player to swap cards with
		{
			currentSelectionState = SWAP_CARDS;
			OpenSwapSelector();
		}
	}

	public function CloseSwapSelection() // Similar as CloseColorSelection but with out swap card bullshit
	{
		playstate.lastPlayedCard.visible = true;
		currentSelectionState = CARD;
		player.EndRound();
	}

	function SetCardPositions()
	{
		var cardHeight:Int = 48;
		var cardWidth:Int = 32;
		var spacingWidth:Int = 8;
		var yPosition:Float = FlxG.height - cardHeight;
		handYPosition = yPosition;
		var cardHalfAmount:Float = hand.length / 2;
		var xStartingPosition:Float = (FlxG.width / 2) - (cardHalfAmount * spacingWidth) - (cardWidth / 2 - 4);
		var currentCard:Int = 0;

		for (card in hand)
		{
			card.setPosition(xStartingPosition + (currentCard * spacingWidth), yPosition);
			currentCard++;
		}
	}

	public function RemoveHand() // done for end game purposes.
	{
		for (card in hand)
			removeCardToDisplay.dispatch(card);
	}

	function LoadDrawCard()
	{
		drawCard = new FlxSprite();
		drawCard.loadGraphic(AssetPaths.draw__png, false, 99, 15);

		var xPos:Float = (FlxG.width / 2) - (drawCard.width / 2);
		var yPos:Float = FlxG.height - 76;

		drawCard.setPosition(xPos, yPos);
		drawCard.visible = false;
		playstate.add(drawCard);
	}

	function Sort() {}
}
