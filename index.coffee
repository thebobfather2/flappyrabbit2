DEBUG = false;
SCALE = 10; // Scaling factor
SPEED = 1600; // 10x original speed
GRAVITY = 11000; // 10x original gravity
FLAP = 3200; // 10x original flap force
SPAWN_RATE = 1 / 120; // Adjusted spawn rate
OPENING = 1000; // 10x original pipe opening

HEIGHT = 3840; // 10x original height
WIDTH = 2880; // 10x original width
GAME_HEIGHT = 3360;
GROUND_HEIGHT = 640;
GROUND_Y = HEIGHT - GROUND_HEIGHT;

parent = document.querySelector("#screen");
gameStarted = undefined;
gameOver = undefined;

deadTubeTops = [];
deadTubeBottoms = [];
deadInvs = [];

bg = null;
tubes = null;
invs = null;
bird = null;
ground = null;
score = null;
scoreText = null;
instText = null;
gameOverText = null;

flapSnd = null;
scoreSnd = null;
hurtSnd = null;
fallSnd = null;
swooshSnd = null;

tubesTimer = null;

githubHtml = `<iframe src="http://ghbtns.com/github-btn.html?user=hyspace&repo=flappy&type=watch&count=true&size=large"
  allowtransparency="true" frameborder="0" scrolling="0" width="150" height="30"></iframe>`;

floor = Math.floor;

main = () => {
  preload = () => {
    assets = {
      spritesheet: {
        bird: ["assets/bird.png", 1080, 260], // Updated to match your new image size
      },
      image: {
        tubeTop: ["assets/tube1.png"],
        tubeBottom: ["assets/tube2.png"],
        ground: ["assets/ground.png"],
        bg: ["assets/bg.png"],
      },
      audio: {
        flap: ["assets/sfx_wing.mp3"],
        score: ["assets/sfx_point.mp3"],
        hurt: ["assets/sfx_hit.mp3"],
        fall: ["assets/sfx_die.mp3"],
        swoosh: ["assets/sfx_swooshing.mp3"],
      },
    };

    Object.keys(assets).forEach((type) => {
      Object.keys(assets[type]).forEach((id) => {
        game.load[type].apply(game.load, [id].concat(assets[type][id]));
      });
    });
  };

  create = () => {
    console.log("Game started");
    game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL;
    game.stage.scale.setScreenSize(true);
    game.world.width = WIDTH;
    game.world.height = HEIGHT;
    
    // Background
    bg = game.add.tileSprite(0, 0, WIDTH, HEIGHT, "bg");

    // Pipes
    tubes = game.add.group();
    invs = game.add.group();

    // Bird setup
    bird = game.add.sprite(WIDTH * 0.3, HEIGHT / 2, "bird");
    bird.anchor.setTo(0.5, 0.5);
    bird.animations.add("fly", [0, 1, 2], 10, true);
    bird.body.collideWorldBounds = true;
    bird.body.setPolygon(240,10, 340,160, 300,320, 200,240, 120,340, 20,120, 140,20);
    bird.scale.setTo(SCALE, SCALE);
    
    // Ground
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground");
    ground.tileScale.setTo(SCALE, SCALE);

    // Score display
    scoreText = game.add.text(WIDTH / 2, HEIGHT / 4, "", { font: "160px 'Press Start 2P'", fill: "#fff", stroke: "#430", strokeThickness: 40, align: "center" });
    scoreText.anchor.setTo(0.5, 0.5);

    // Instructions text
    instText = game.add.text(WIDTH / 2, HEIGHT - HEIGHT / 4, "TOUCH TO FLAP", { font: "80px 'Press Start 2P'", fill: "#fff", stroke: "#430", strokeThickness: 20, align: "center" });
    instText.anchor.setTo(0.5, 0.5);

    // Game over text
    gameOverText = game.add.text(WIDTH / 2, HEIGHT / 2, "", { font: "160px 'Press Start 2P'", fill: "#fff", stroke: "#430", strokeThickness: 40, align: "center" });
    gameOverText.anchor.setTo(0.5, 0.5);
    gameOverText.scale.setTo(SCALE, SCALE);

    // Controls
    game.input.onDown.add(flap);
    reset();
  };

  update = () => {
    console.log("Bird position:", bird.x, bird.y);
    console.log("Bird visible:", bird.visible);

    if (gameStarted) {
      if (!gameOver) {
        bird.angle = Math.min(90, Math.max(-30, (90 * (FLAP + bird.body.velocity.y) / FLAP) - 180));
        bird.animations.play();
        game.physics.overlap(bird, tubes, setGameOver);
        game.physics.overlap(bird, invs, addScore);
        setGameOver() if bird.body.bottom >= GROUND_Y;
      } else {
        bird.body.velocity.y = 0;
        bird.body.allowGravity = false;
      }
    } else {
      bird.y = (HEIGHT / 2) + 80 * Math.cos(game.time.now / 200);
      bird.angle = 0;
    }
    ground.tilePosition.x -= game.time.physicsElapsed * SPEED;
  };

  reset = () => {
    gameStarted = false;
    gameOver = false;
    bird.body.allowGravity = false;
    bird.reset(WIDTH * 0.3, HEIGHT / 2);
    bird.angle = 0;
    bird.animations.play("fly");
    score = 0;
    scoreText.setText("Flappy Bird");
    instText.setText("TOUCH TO FLAP");
  };

  state = { preload, create, update };
  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, parent, state);
};

WebFontConfig = {
  google: { families: ["Press+Start+2P::latin"] },
  active: main,
};
