DEBUG = false
SPEED = 1600  // 10x
GRAVITY = 11000  // 10x
FLAP = 3200  // 10x
SPAWN_RATE = 1 / 1200
OPENING = 1000  // 10x
SCALE = 10  // 10x

HEIGHT = 3840  // 10x
WIDTH = 2880  // 10x
GAME_HEIGHT = 3360  // 10x
GROUND_HEIGHT = 640  // 10x
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
  spawntube = (openPos, flipped) ->
    tube = null
    tubeKey = if flipped then "tubeTop" else "tubeBottom"
    if flipped
      tubeY = floor(openPos - OPENING / 2 - 3200)  // 10x
    else
      tubeY = floor(openPos + OPENING / 2)
    
    if deadTubeTops.length > 0 and tubeKey == "tubeTop"
      tube = deadTubeTops.pop().revive()
      tube.reset(game.world.width, tubeY)
    else if deadTubeBottoms.length > 0 and tubeKey == "tubeBottom"
      tube = deadTubeBottoms.pop().revive()
      tube.reset(game.world.width, tubeY)
    else
      tube = tubes.create(game.world.width, tubeY, tubeKey)
      tube.body.allowGravity = false

    tube.body.velocity.x = -SPEED
    tube.scale.setTo(SCALE, SCALE)  // Scale up
    tube

  spawntubes = ->
    tubes.forEachAlive (tube) ->
      if tube.x + tube.width < game.world.bounds.left
        deadTubeTops.push tube.kill() if tube.key == "tubeTop"
        deadTubeBottoms.push tube.kill() if tube.key == "tubeBottom"
    
    invs.forEachAlive (inv) ->
      deadInvs.push inv.kill() if inv.x + inv.width < game.world.bounds.left

    tubeY = game.world.height / 2 + (Math.random()-0.5) * game.world.height * 0.2
    bottube = spawntube(tubeY)
    toptube = spawntube(tubeY, true)
    
    if deadInvs.length > 0
      inv = deadInvs.pop().revive().reset(toptube.x + toptube.width / 2, 0)
    else
      inv = invs.create(toptube.x + toptube.width / 2, 0)
      inv.width = 20  // 10x
      inv.height = game.world.height
      inv.body.allowGravity = false
    inv.body.velocity.x = -SPEED

  addScore = (_, inv) ->
    invs.remove inv
    score += 1
    scoreText.setText score
    scoreSnd.play()

  setGameOver = ->
    gameOver = true
    bird.body.velocity.y = 1000 if bird.body.velocity.y > 0
    bird.animations.stop()
    bird.frame = 1
    instText.setText "TOUCH\nTO TRY AGAIN"
    instText.renderable = true
    
    gameOverText.setText "GAME OVER\nHIGH SCORE\n" + score
    gameOverText.renderable = true
    
    tubes.forEachAlive (tube) -> tube.body.velocity.x = 0
    invs.forEach (inv) -> inv.body.velocity.x = 0
    
    game.time.events.remove(tubesTimer)
    game.time.events.add 1000, ->
      game.input.onTap.addOnce -> reset(); swooshSnd.play()

    hurtSnd.play()

  flap = ->
    start() unless gameStarted
    unless gameOver
      bird.body.gravity.y = 0
      bird.body.velocity.y = -1000
      tween = game.add.tween(bird.body.velocity).to(y:-FLAP, 25, Phaser.Easing.Bounce.In, true)
      tween.onComplete.add -> bird.body.gravity.y = GRAVITY
      flapSnd.play()

  preload = ->
    assets =
      spritesheet:
        bird: ["assets/bird.png", 360, 260]  // 10x
      image:
        tubeTop: ["assets/tube1.png"]
        tubeBottom: ["assets/tube2.png"]
        ground: ["assets/ground.png"]
        bg: ["assets/bg.png"]
    
    Object.keys(assets).forEach (type) ->
      Object.keys(assets[type]).forEach (id) ->
        game.load[type].apply game.load, [id].concat(assets[type][id])

  create = ->
    game.world.width = WIDTH
    game.world.height = HEIGHT
    
    bg = game.add.tileSprite(0, 0, WIDTH, HEIGHT, 'bg')
    bg.scale.setTo(SCALE, SCALE)
    
    tubes = game.add.group()
    invs = game.add.group()
    
    bird = game.add.sprite(0, 0, "bird")
    bird.anchor.setTo(0.5, 0.5)
    bird.animations.add "fly", [0,1,2], 10, true
    bird.body.collideWorldBounds = true
    bird.scale.setTo(SCALE, SCALE)
    
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground")
    ground.tileScale.setTo(SCALE, SCALE)
    
    reset()

  reset = ->
    gameStarted = false
    gameOver = false
    score = 0
    scoreText.setText "Flappy Bird"
    instText.setText "TOUCH TO FLAP\nbird WINGS"
    gameOverText.renderable = false
    bird.body.allowGravity = false
    bird.reset game.world.width * 0.3, game.world.height / 2
    bird.animations.play "fly"
    tubes.removeAll()
    invs.removeAll()

  state =
    preload: preload
    create: create
  
  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, parent, state, false, false)
  
WebFontConfig =
  google:
    families: [ 'Press+Start+2P::latin' ]
  active: main

