DEBUG = false
SPEED = 1600  # 10x
GRAVITY = 11000  # 10x
FLAP = 3200  # 10x
SPAWN_RATE = 1 / 1200
OPENING = 1000  # 10x
SCALE = 10  # 10x

HEIGHT = 3840  # 10x
WIDTH = 2880  # 10x
GAME_HEIGHT = 3360  # 10x
GROUND_HEIGHT = 640  # 10x
GROUND_Y = HEIGHT - GROUND_HEIGHT

parent = document.querySelector("#screen")
gameStarted = undefined
gameOver = undefined

deadTubeTops = []
deadTubeBottoms = []
deadInvs = []

bg = null
tubes = null
invs = null
bird = null
ground = null

score = null
scoreText = null
instText = null
gameOverText = null

flapSnd = null
scoreSnd = null
hurtSnd = null
fallSnd = null
swooshSnd = null

tubesTimer = null

floor = Math.floor

main = ->
  console.log("Initializing game...")

  preload = ->
    console.log("Loading assets...")
    assets =
      spritesheet:
        bird: [
          "assets/bird.png"
          360  # Updated width (10x original 36)
          260  # Updated height (10x original 26)
        ]

      image:
        tubeTop: ["assets/tube1.png"]
        tubeBottom: ["assets/tube2.png"]
        ground: ["assets/ground.png"]
        bg: ["assets/bg.png"]

      audio:
        flap: ["assets/sfx_wing.mp3"]
        score: ["assets/sfx_point.mp3"]
        hurt: ["assets/sfx_hit.mp3"]
        fall: ["assets/sfx_die.mp3"]
        swoosh: ["assets/sfx_swooshing.mp3"]

    Object.keys(assets).forEach (type) ->
      Object.keys(assets[type]).forEach (id) ->
        game.load[type].apply game.load, [id].concat(assets[type][id])
        console.log("Loaded asset:", id, assets[type][id])
        return
      return
    return

  create = ->
    console.log("Creating game objects...")
    
    # Set world dimensions
    Phaser.Canvas.setSmoothingEnabled(game.context, false)
    game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
    game.stage.scale.setScreenSize(true)
    game.world.width = WIDTH
    game.world.height = HEIGHT

    # Draw bg
    bg = game.add.tileSprite(0, 0, WIDTH, HEIGHT, 'bg')

    # Add tubes
    tubes = game.add.group()
    invs = game.add.group()

    # Add bird
    bird = game.add.sprite(500, 500, "bird")  # Start at visible position
    bird.anchor.setTo 0.5, 0.5
    bird.scale.setTo SCALE, SCALE  # Scale up bird
    console.log("Bird created at:", bird.x, bird.y, "Visible:", bird.visible)

    # Add ground
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground")

    # Add text elements
    scoreText = game.add.text(game.world.width / 2, game.world.height / 4, "",
      font: "160px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 40
      align: "center"
    )
    scoreText.anchor.setTo 0.5, 0.5

    # Add instructions text
    instText = game.add.text(game.world.width / 2, game.world.height - game.world.height / 4, "",
      font: "80px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 20
      align: "center"
    )
    instText.anchor.setTo 0.5, 0.5

    # Add game over text
    gameOverText = game.add.text(game.world.width / 2, game.world.height / 2, "",
      font: "160px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 40
      align: "center"
    )
    gameOverText.anchor.setTo 0.5, 0.5
    gameOverText.visible = false

    # Add sounds
    flapSnd = game.add.audio("flap")
    scoreSnd = game.add.audio("score")
    hurtSnd = game.add.audio("hurt")
    fallSnd = game.add.audio("fall")
    swooshSnd = game.add.audio("swoosh")

    # Add controls
    game.input.onDown.add flap

    # Reset game
    reset()
    return

  reset = ->
    console.log("Game reset!")
    gameStarted = false
    gameOver = false
    score = 0
    scoreText.setText "Flappy Bird"
    instText.setText "TOUCH TO FLAP"
    gameOverText.visible = false
    bird.body.allowGravity = false
    bird.reset game.world.width * 0.3, game.world.height / 2
    bird.animations.play "fly"
    tubes.removeAll()
    invs.removeAll()
    return

  update = ->
    console.log("Update running... Bird position:", bird.x, bird.y, "Visible:", bird.visible)

    if gameStarted
      if not gameOver
        # Check collisions
        game.physics.overlap bird, tubes, ->
          console.log("Bird hit a tube!")
          setGameOver()
          fallSnd.play()
        setGameOver() if bird.body.bottom >= GROUND_Y
      else
        # Game over animation
        tween = game.add.tween(bird).to(angle: 90, 100, Phaser.Easing.Bounce.Out, true);
        if bird.body.bottom >= GROUND_Y + 30
          bird.y = GROUND_Y - 130
          bird.body.velocity.y = 0
          bird.body.allowGravity = false

    else
      # Idle bird movement before the game starts
      bird.y = (game.world.height / 2) + 80 * Math.cos(game.time.now / 200)
      bird.angle = 0

    return

  setGameOver = ->
    console.log("Game Over! Final score:", score)
    gameOver = true
    bird.body.velocity.y = 1000  # 10x
    bird.animations.stop()
    bird.frame = 1
    instText.setText "TOUCH TO RESTART"
    instText.renderable = true
    gameOverText.setText "GAME OVER"
    gameOverText.visible = true

    # Stop tubes
    tubes.forEachAlive (tube) ->
      tube.body.velocity.x = 0
      return

    game.time.events.add 1000, ->
      game.input.onTap.addOnce ->
        reset()
        swooshSnd.play()

    hurtSnd.play()
    return

  flap = ->
    console.log("Flap triggered!")
    start()  unless gameStarted
    unless gameOver
      bird.body.gravity.y = 0
      bird.body.velocity.y = -1000
      tween = game.add.tween(bird.body.velocity).to(y:-FLAP, 25, Phaser.Easing.Bounce.In,true)
      tween.onComplete.add ->
        bird.body.gravity.y = GRAVITY
      flapSnd.play()
    return

  state =
    preload: preload
    create: create
    update: update

  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, parent, state, false, false)
  return

main()
