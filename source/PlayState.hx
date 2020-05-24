package;

import DeckBuilder;
import entities.Card;
import entities.ColorSelector;
import entities.ComputerPlayer;
import entities.Player;
import entities.PlayersHand;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	public var players:Array<Player> = [];

	var deck:Array<Card> = [];

	public var cardsToPlay:Array<Card> = [];
	public var playedCards:Array<Card> = [];

	public var currentPlayer:Player;
	public var nextPlayer:Player;
	public var player:Player;
	public var turnOrder:Int = 1;
	public var lastPlayedCard:Card;

	var isGameEnded:Bool = false;

	var deckBuilder:DeckBuilder = new DeckBuilder();
	var topBar:TopBar;
	var endGame:EndGame;

	override public function create()
	{
		super.create();

		StartGame();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isGameEnded)
		{
			currentPlayer.update();
		}
		else if (isGameEnded)
		{
			endGame.ChooseSelection();
			endGame.Select();
		}
	}

	function StartGame()
	{
		topBar = new TopBar();
		add(topBar);
		endGame = new EndGame(this);
		add(endGame);
		endGame.visible = false;
		deck = deckBuilder.BuildDeck();
		deckBuilder.ShuffleDeck(deck);
		players = CreatePlayers();
		deckBuilder.StackCardsToPlay(cardsToPlay, deck);
		deckBuilder.DealInitialCards(players, cardsToPlay);
		topBar.SetUp(players);

		for (i in 1...4)
		{
			_onUpdateCardCount(i - 1, players[i].cards.length);
		}

		SetInitialLastPlayedCard();

		player = players[0];
		currentPlayer = player;
		player.SetPlayerHands();
		player.playerHands.UpdateHand();
	}

	public function RestartGame()
	{
		// Remove all cards from everywhere but the deck
		for (p in players)
		{
			for (i in 0...p.cards.length)
				p.cards.pop();
		}

		for (i in 0...cardsToPlay.length)
		{
			cardsToPlay.pop();
		}

		for (i in 0...playedCards.length)
		{
			playedCards.pop();
		}

		deckBuilder.ShuffleDeck(deck);
		deckBuilder.StackCardsToPlay(cardsToPlay, deck);
		deckBuilder.DealInitialCards(players, cardsToPlay);

		for (i in 1...4)
		{
			_onUpdateCardCount(i - 1, players[i].cards.length);
		}

		SetInitialLastPlayedCard();

		currentPlayer = player;
		player.playerHands.UpdateHand();

		isGameEnded = false;
	}

	public function EndGame(_winner:Player)
	{
		var winnerName:String = "";
		remove(lastPlayedCard);
		player.playerHands.RemoveHand();

		if (Std.is(_winner, ComputerPlayer))
			winnerName = cast(_winner, ComputerPlayer).name;
		else if (!Std.is(_winner, ComputerPlayer))
			winnerName = "You";

		endGame.visible = true;
		endGame.Show(winnerName);
		isGameEnded = true;
	}

	public function GoToNextPlayer(_skip:Bool)
	{
		currentPlayer = GetNextPlayer(_skip);
	}

	function CreatePlayers():Array<Player>
	{
		var temp_players:Array<Player> = [];
		var names:Array<String> = [
			"Bob", "Dale", "Steve", "Randy", "Becky", "Susan", "Sarah", "Harry", "Bill", "Don", "Phil", "Ally", "Bonnie", "Sally", "Daniel"
		];

		temp_players.push(new Player(this, topBar));

		for (i in 0...3)
		{
			temp_players.push(new ComputerPlayer(this, topBar, i, names));
		}

		return temp_players;
	}

	function SetInitialLastPlayedCard()
	{
		lastPlayedCard = new Card(0, 0, RED, NONE, 0);
		var startingCard:Card = null;

		while (startingCard == null) // This makes sure that it will never be a wild card at start
		{
			startingCard = cardsToPlay.pop();

			if (startingCard.cardColor == WILD)
			{
				cardsToPlay.insert(0, startingCard);
				startingCard = null;
			}
		}

		playedCards.push(startingCard);
		lastPlayedCard.cardColor = startingCard.cardColor;
		lastPlayedCard.cardNumber = startingCard.cardNumber;
		lastPlayedCard.specialCard = startingCard.specialCard;
		lastPlayedCard.loadGraphic(lastPlayedCard.SetGraphic(), false, 32, 48);
		lastPlayedCard.x = (FlxG.width / 2) - (lastPlayedCard.width / 2);
		lastPlayedCard.y = (FlxG.height / 2) - (lastPlayedCard.height / 2);
		topBar.SetCurrentColor(lastPlayedCard.cardColor);
		add(lastPlayedCard);
	}

	public function DrawCard():Card
	{
		var cardToDraw:Card = null;

		if (cardsToPlay.length > 0) // grab first card from the cardToPlay deck
		{
			cardToDraw = cardsToPlay.pop();
		}
		else // Out of cards, so put all cards in played cards, except lastPlayedCard, in cardsToPlay deck then shuffle, then grab first card
		{
			trace("out of cards!");
			for (card in playedCards)
			{
				if (card != lastPlayedCard)
				{
					cardsToPlay.push(card);
					playedCards.remove(card);
				}
			}

			deckBuilder.ShuffleDeck(cardsToPlay);
			cardToDraw = cardsToPlay.pop();
		}

		return cardToDraw;
	}

	function GetNextPlayer(_skip:Bool):Player // Determines next player by getting index of player in array and adding the turnOrder var.
		// Also factors in if skip card has been played, and will adjust accordingly
	{
		var currentPlayerIndex:Int = 0;

		if (!_skip)
			currentPlayerIndex = players.indexOf(currentPlayer) + turnOrder;
		else
			currentPlayerIndex = players.indexOf(currentPlayer) + (turnOrder * 2); // If skip card is played go ahead 2 spaces instead of 1

		if (currentPlayerIndex >= players.length)
		{
			if (!_skip)
				currentPlayerIndex = 0;
			else
				currentPlayerIndex = 1; // Same is done here, make sure to go ahead or behind one so player is skipped
		}
		else if (currentPlayerIndex < 0)
		{
			if (!_skip)
				currentPlayerIndex = players.length - 1;
			else
				currentPlayerIndex = players.length - 2;
		}

		return players[currentPlayerIndex];
	}

	public function _onSetLastPlayedCard(_card:Card)
	{
		remove(_card);
		playedCards.push(_card);
		currentPlayer.cards.remove(_card);

		lastPlayedCard.cardColor = _card.cardColor;
		lastPlayedCard.cardNumber = _card.cardNumber;
		lastPlayedCard.specialCard = _card.specialCard;
		lastPlayedCard.loadGraphic(lastPlayedCard.SetGraphic(), false, 32, 48);

		topBar.SetCurrentColor(lastPlayedCard.cardColor);
	}

	public function _onAddCardToDisplay(_card:Card)
	{
		add(_card);
	}

	public function _onRemoveCardToDisplay(_card:Card)
	{
		remove(_card);
	}

	public function _onWildCardSetColor(_cardColor)
	{
		lastPlayedCard.cardColor = _cardColor;
		topBar.SetCurrentColor(_cardColor);
	}

	public function _onUpdateCardCount(_order:Int, _amount:Int)
	{
		topBar.SetCardCountAmount(_order, _amount);
	}

	public function _onReverseCard()
	{
		if (turnOrder > 0)
			turnOrder = -1;
		else if (turnOrder < 0)
			turnOrder = 1;

		topBar.turnOrder = turnOrder;
	}

	public function _onDrawCards(_amount)
	{
		var playerToAddCards:Player = GetNextPlayer(false);

		for (i in 0..._amount)
			playerToAddCards.cards.push(cardsToPlay.pop());

		if (Std.is(playerToAddCards, ComputerPlayer))
		{
			var order = players.lastIndexOf(playerToAddCards) - 1;
			topBar.SetCardCountAmount(order, playerToAddCards.cards.length);
		}
	}

	public function _onSwapCards(_swappingPlayer:Player)
	{
		var swappingPlayersCards:Array<Card> = GetCardsToSwap(_swappingPlayer.cards);
		var currentPlayersCards:Array<Card> = GetCardsToSwap(currentPlayer.cards);

		SwapCards(currentPlayer.cards, swappingPlayersCards);
		SwapCards(_swappingPlayer.cards, currentPlayersCards);

		if (Std.is(_swappingPlayer, ComputerPlayer))
		{
			topBar.SetCardCountAmount(cast(_swappingPlayer, ComputerPlayer).order, _swappingPlayer.cards.length);
			trace("a computer player got their hand swapped by another comptuer player");
		}
		else if (!Std.is(_swappingPlayer, ComputerPlayer))
		{
			player.playerHands.UpdateHand();
			trace("player got his hand swapped");
		}
	}

	function GetCardsToSwap(_playersCard:Array<Card>):Array<Card>
	{
		var tempHand:Array<Card> = [];

		while (_playersCard.length > 0)
			tempHand.push(_playersCard.pop());

		return tempHand;
	}

	function SwapCards(_playersHand:Array<Card>, _cardsToSwap:Array<Card>)
	{
		while (_cardsToSwap.length > 0)
			_playersHand.push(_cardsToSwap.pop());
	}
}
