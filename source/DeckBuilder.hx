package;

import entities.Card;
import entities.Player;
import flixel.math.FlxRandom;

class DeckBuilder
{
	var random:FlxRandom = new FlxRandom();

	public function new() {}

	public function BuildDeck():Array<Card>
	{
		var deck:Array<Card> = new Array<Card>();

		for (i in 0...4)
		{
			AddColoredNumberedCards(deck, GetColor(i));
			AddSpecialColoredCards(deck, GetColor(i));
		}

		AddWildCards(deck);

		return deck;
	}

	public function DealInitialCards(_players:Array<Player>, _cardsToPlay:Array<Card>)
	{
		for (player in _players)
		{
			for (i in 0...7)
			{
				player.cards.push(_cardsToPlay.pop());
			}
		}
	}

	public function StackCardsToPlay(_cardsToPlay:Array<Card>, _deck:Array<Card>):Array<Card>
	{
		for (i in 0..._deck.length)
			_cardsToPlay.push(_deck[i]);

		return _cardsToPlay;
	}

	public function ShuffleDeck(_deck:Array<Card>)
	{
		random.shuffle(_deck);
	}

	function AddColoredNumberedCards(_deck:Array<Card>, _color:CardColor)
	{
		for (i in 0...10)
		{
			_deck.push(new Card(0, 0, _color, NONE, i));

			if (i > 0) // There are only one zero cards in the deck, so this will add an extra non-zero card to the deck
			{
				_deck.push(new Card(0, 0, _color, NONE, i));
			}
		}
	}

	function AddSpecialColoredCards(_deck:Array<Card>, _color:CardColor)
	{
		for (i in 0...2)
		{
			_deck.push(new Card(0, 0, _color, REVERSE, 10));
			_deck.push(new Card(0, 0, _color, DRAW_2, 11));
			_deck.push(new Card(0, 0, _color, SKIP, 12));
		}
	}

	function AddWildCards(_deck:Array<Card>)
	{
		for (i in 0...4)
		{
			_deck.push(new Card(0, 0, WILD, DRAW_4, 0));
			_deck.push(new Card(0, 0, WILD, CHOOSE_COLOR, 1));
		}

		_deck.push(new Card(0, 0, WILD, SWAP, 2));
		_deck.push(new Card(0, 0, WILD, SWAP, 2));
	}

	function GetColor(_index:Int):CardColor
	{
		switch _index
		{
			case 0:
				return RED;

			case 1:
				return GREEN;

			case 2:
				return YELLOW;

			case 3:
				return BLUE;

			default:
				trace("PROBLEM: GetColor function");
				return RED;
		}
	}
}
