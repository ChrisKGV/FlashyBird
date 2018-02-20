package {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;

	public class FlappyBird extends MovieClip {
		public static var SPACEBAR: uint = 32;
		public var bird: Bird;
		public var jump: Number;
		public var pipes: Array;
		public var pipe: Pipe;
		public var score: int;
		public var highScore: int = 0;
		public var gameStart: Boolean;
		public var isFlapping: Boolean;
		public var hitPipe: Boolean;
		public var point: PointSound;
		public var wing: WingSound;
		public var hit: HitSound;
		public var initialXPosition: Number;
		public var altitude: Number;
		public var newGameBtn: NewGame;

		public function FlappyBird() {
			Initialize();
		}

		public function Initialize() {
			startBtn.x = 300;
			startBtn.y = 75;

			point = new PointSound();
			wing = new WingSound();
			hit = new HitSound();
			newGameBtn = new NewGame();

			gameStart = false;
			hitPipe = false;
			score = 0;

			bird = new Bird(155, 300);
			addChildAt(bird, 3);
			jump = 0;

			pipes = new Array();
			initialXPosition = 840;
			createPipes();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			addEventListener(Event.ENTER_FRAME, gameLoop);
		}

		public function keyDown(event: KeyboardEvent): void {
			if (event.keyCode == SPACEBAR) {
				startBtn.x = -600;
				jump = -11;
				isFlapping = true;
				gameStart = true;
				wing.play();
				bird.wing.rotation += 60;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			}
		}

		public function keyUp(event: KeyboardEvent): void {
			if (event.keyCode == SPACEBAR) {
				isFlapping = false;
				bird.wing.rotation -= 60;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			}
		}

		public function createPipes(): void {
			for (var i: Number = 1; i <= 3; i++) {
				altitude = Math.random() * 400 + 100;
				pipe = new Pipe(initialXPosition, altitude);
				initialXPosition += 300;
				addChildAt(pipe, 1);
				pipes.push(pipe);
			}
		}

		public function gameLoop(event: Event): void {
			rotateBird();
			updateScore();
			checkGameState();
		}

		public function rotateBird(): void {
			if (gameStart && jump >= 4 && !isFlapping) {
				bird.rotation += 5;
				if (bird.rotation > 90)
					bird.rotation = 90;
			} else if (jump < 0)
				bird.rotation = -35;
		}

		public function updateScore(): void {
			txtScore.text = "Score: " + score;
			if (score > highScore)
				highScore = score;
			txtHighScore.text = "High Score: " + highScore;

		}

		public function checkGameState(): void {
			if (gameStart) {
				//Gravity and Jump
				jump += .7;
				bird.y += jump;

				//Check Lower Bound
				if (bird.y >= 575) {
					bird.y = 575;
					if (bird.hitTestObject(floor))
						hit.play();
					GameOver();
				}
				//Check Upper Bound
				if (bird.y <= 25)
					bird.y = 25;

				for (var i in pipes) {
					pipes[i].x -= 3;
					//Reset pipe if exit screen
					if (pipes[i].x + 45 == 0) {
						pipes[i].x = 840;
						pipes[i].y = Math.random() * 400 + 100;
					}
					//Check bird collision with pipe
					if (pipes[i].hitTestPoint(bird.x, bird.y, true)) {
						hit.play();
						hitPipe = true;
					}
					if (pipes[i].hitTestPoint(bird.x + bird.wRadius, bird.y, true)) {
						hit.play();
						hitPipe = true;
					}
					if (pipes[i].hitTestPoint(bird.x - bird.wRadius, bird.y, true)) {
						hit.play();
						hitPipe = true;
					}
					if (pipes[i].hitTestPoint(bird.x, bird.y + bird.hRadius, true)) {
						hit.play();
						hitPipe = true;
					}
					if (pipes[i].hitTestPoint(bird.x, bird.y - bird.hRadius, true)) {
						hit.play();
						hitPipe = true;
					}
					//Add 1 to score if bird passes pipe
					if (bird.x - 50 == pipes[i].x) {
						score += 1;
						point.play();
					}
				}
			}
			//Send to game over screen after hitting a pipe
			if (hitPipe) {
				jump += .7;
				bird.y += jump;
				bird.rotation += 5;
				if (bird.rotation > 90)
					bird.rotation = 90;
				if (bird.y >= 575)
					bird.y = 575;
				GameOver();
			}
		}

		public function GameOver(): void {
			gameStart = false;
			newGameBtn.visible = true;

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);

			addChild(newGameBtn);
			newGameBtn.addEventListener(MouseEvent.CLICK, StartNewGame);
		}

		public function StartNewGame(event: MouseEvent): void {
			newGameBtn.removeEventListener(MouseEvent.CLICK, StartNewGame);
			for (var i: Number = 0; i < 3; i++)
				removeChild(pipes[i]);
			removeChild(bird);
			newGameBtn.visible = false;
			score = 0;
			updateScore();
			Initialize();
		}

	}

}