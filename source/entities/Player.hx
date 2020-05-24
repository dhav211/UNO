package entities;

import flixel.util.FlxSignal;

class Player
{
	public var cards:Array<Card> = [];
	public var playstate:PlayState;

	public var isRoundStarted:Bool = false;
	public var isSkipCardPlayed:Bool = false;

	public var playerHands:PlayersHand;

	var setArrowPosition:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new(_playstate:PlayState, _topBar:TopBar)
	{
		playstate = _playstate;

		setArrowPosition.add(_topBar._onSetArrowPosition);
	}

	public function update()
	{
		if (isRoundStarted)
			playerHands.update();
		else
			StartRound();
	}

	public function SetPlayerHands()
	{
		playerHands = new PlayersHand(playstate, cards, this);
	}

	public function StartRound()
	{
		isRoundStarted = true;
		isSkipCardPlayed = false;
		playerHands.UpdateHand();

		setArrowPosition.dispatch(3); // Since function overloading is not possible, this 3 just lets the function know it's not computer player
	}

	public function EndRound()
	{
		if (cards.length == 0)
			playstate.EndGame(this);
		isRoundStarted = false;
		playerHands.UpdateHand();
		playstate.GoToNextPlayer(isSkipCardPlayed);
	}
}
