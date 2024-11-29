use context starter2024
include reactors
include image
import color as color

data Box:
  | box(center :: Point, width :: Number, height :: Number)
end

data Paddle:
  | paddle(center :: Point, x-velocity :: Number)
end

data Ball:
  | ball(center :: Point, x-velocity :: Number, y-velocity :: Number)
end

data State:
  | state(ball :: Ball, bricks :: List<Point>, paddle :: Paddle)
end

# constants used in multiple functions
window-width = 1000
window-height = 500
box-width = 100
box-height = 25
ball-diameter = 20
paddle-width = 100
paddle-height = 25
init-paddle-y = 450
init-ball-y = 400
init-ball-vel-x = 3
init-ball-vel-y = 4
max-row = 5
initial-row = 2
magnitude-multiplier = 1.05
paddle-velocity = 10

# testing variables
state1 = state(ball(point(100, 100), 50, 50), 
  [list: point(200, 200), point(300, 300)], 
  paddle(point(400, 400), 10))
state2 = state(ball(point(150, 150), 50, 50), 
  [list: point(200, 200), point(300, 300)], 
  paddle(point(410, 400), 10))
state3 = state(ball(point(200, 200), 50, -50),
  [list: point(300, 300)],
  paddle(point(420, 400), 10))

fun initial() -> State:
  doc: ```returns initial state, necessary because defining 
       as global constant causes a definition order dependency```
  state(ball(point(window-width / 2, init-ball-y), init-ball-vel-x, init-ball-vel-y), 
    blocks-row(0, initial-row), 
    paddle(point(window-width / 2, init-paddle-y), 0))
where:
  initial() is state(ball(point(window-width / 2, init-ball-y), init-ball-vel-x, init-ball-vel-y), 
    blocks-row(0, initial-row), 
    paddle(point(window-width / 2, init-paddle-y), 0))
end
  

fun get-color(a-point :: Point) -> color.Color:
  doc: "get a pseudorandom color for a brick located at a point"
  brightness-minimum = 64 # because dark colors are depressing
  color-mod-max = 256 

  _ = num-random-seed((a-point.x * window-height) + a-point.y) # randomly color bricks
  a-red = brightness-minimum + num-random(color-mod-max - brightness-minimum)
  a-blue = brightness-minimum + num-random(color-mod-max - brightness-minimum)
  a-green = brightness-minimum + num-random(color-mod-max - brightness-minimum)
  color.color(a-red, a-blue, a-green, 1)
where:
  get-color(point(0, 0)) is color.color(213, 73, 166, 1)
  get-color(point(200, 200)) is color.color(198, 223, 185, 1)
  get-color(point(300, 300)) is color.color(115, 98, 177, 1)
end

fun my-draw(a-state :: State) -> Image:
  doc: "create displayed image from state"
  canvas = rectangle(window-width, window-height, "outline", "black")
  
  canvas-bricks = a-state.bricks.foldl({(a-point, accumulated): 
      rect = rectangle(box-width, box-height, "solid", get-color(a-point))
      place-image(rect, a-point.x, a-point.y, accumulated)},
    canvas)
  
  a-circle = rectangle(ball-diameter, ball-diameter, "outline", "black")
  canvas-ball = place-image(a-circle, a-state.ball.center.x, a-state.ball.center.y, canvas-bricks)
  
  a-paddle = rectangle(paddle-width, paddle-height, "solid", "black")
  canvas-paddle = place-image(a-paddle, 
    a-state.paddle.center.x, a-state.paddle.center.y, canvas-ball)
  
  canvas-paddle
where:
  my-draw(state1) is place-image(
    rectangle(paddle-width, paddle-height, "solid", "black"), 400, 400, place-image(
      rectangle(ball-diameter, ball-diameter, "outline", "black"), 100, 100, place-image(
        rectangle(box-width, box-height, "solid", get-color(point(300, 300))), 
        300, 300, place-image(
          rectangle(box-width, box-height, "solid", get-color(point(200, 200))), 200, 200,
          rectangle(window-width, window-height, "outline", "black")))))
  my-draw(state2) is place-image(
    rectangle(paddle-width, paddle-height, "solid", "black"), 410, 400, place-image(
      rectangle(ball-diameter, ball-diameter, "outline", "black"), 150, 150, place-image(
        rectangle(box-width, box-height, "solid", get-color(point(300, 300))), 
        300, 300, place-image(
          rectangle(box-width, box-height, "solid", get-color(point(200, 200))), 200, 200,
          rectangle(window-width, window-height, "outline", "black")))))
end

fun update-ball(a-state :: State) -> Ball:
  doc: "handle the logic for moving and bouncing the ball during a tick"
  bricks = a-state.bricks.map({(a-point): box(a-point, box-width, box-height)})
  collision-boxes = [list: 
    box(point(0, 0), 2 * window-width, 0),
    box(point(0, 0), 0, 2 * window-height),
    box(point(window-width, window-height), 0, 2 * window-height),
  ].append(bricks)
  paddle-box = box(a-state.paddle.center, paddle-width, paddle-height)
  
  # see if the ball is colliding along the x-axis or the y-axis to flip the correct velocity
  a-ball = a-state.ball
  temp-ball-x = ball(point(a-ball.center.x + a-ball.x-velocity, a-ball.center.y), 
    a-ball.x-velocity, a-ball.y-velocity)
  temp-ball-y = ball(point(a-ball.center.x, a-ball.center.y + a-ball.y-velocity), 
    a-ball.x-velocity, a-ball.y-velocity)
  temp-ball-xy = ball(
    point(a-ball.center.x + a-ball.x-velocity, a-ball.center.y + a-ball.y-velocity), 
    a-ball.x-velocity, a-ball.y-velocity)
  
  {x-velocity; y-velocity} = ask:
    | collide-ball-boxes(a-ball, collision-boxes) then: 
      {a-ball.x-velocity; a-ball.y-velocity}
    | collide-ball-boxes(temp-ball-xy, [list: paddle-box]) then:
      collide-ball-paddle(temp-ball-xy, a-state.paddle)
    | collide-ball-boxes(temp-ball-x, collision-boxes) then: 
      {-1 * a-ball.x-velocity; a-ball.y-velocity}
    | collide-ball-boxes(temp-ball-y, collision-boxes) then: 
      {a-ball.x-velocity; -1 * a-ball.y-velocity}
    | collide-ball-boxes(temp-ball-xy, collision-boxes) then: 
      {-1 * a-ball.x-velocity; -1 * a-ball.y-velocity}
    | otherwise:
      {a-ball.x-velocity; a-ball.y-velocity}
  end
  ball(point(a-ball.center.x + a-ball.x-velocity, 
      a-ball.center.y + a-ball.y-velocity), x-velocity, y-velocity)
where:
  # test horizontal wall bounce
  update-ball(state(ball(point(100, 100), -105, 5), empty, paddle(point(400, 400), 0)))
    is ball(point(-5, 105), 105, 5)
  # test vertical wall bounce
  update-ball(state(ball(point(100, 100), 5, -105), empty, paddle(point(400, 400), 0)))
    is ball(point(105, -5), 5, 105)
  # test brick bounce
  update-ball(state(ball(point(100, 100), 105, 5), [list: point(200, 100)], 
      paddle(point(400, 400), 0)))
    is ball(point(205, 105), -105, 5)
  # test paddle bounce (note that the velocity calculation involves a square root)
  update-ball(state(ball(point(400, 300), 5, 105), empty, 
      paddle(point(400, 400), 0)))
    is-roughly ball(point(405, 405), ~78.04686092342214, ~78.04686092342214)
end

fun my-tick(a-state :: State) -> State:
  doc: "perform an update on state"
  new-ball = update-ball(a-state)
  
  new-bricks = a-state.bricks.filter({(a-point): 
      a-box = box(a-point, box-width, box-height)
      ball-box = box(new-ball.center, ball-diameter, ball-diameter)
      not(is-collide(ball-box, a-box))})
  
  a-paddle = a-state.paddle
  new-paddle = paddle(point(a-paddle.center.x + a-paddle.x-velocity, a-paddle.center.y), 
    a-paddle.x-velocity)
  
  # reset on win or lose
  if ((new-ball.center.y > window-height) or is-empty(new-bricks)):
    initial()
  else:
    state(new-ball, new-bricks, new-paddle)
  end
where:
  # test normal movement
  my-tick(state1) is state2
  # test brick break
  my-tick(state2) is state3
  # test reset conditions
  my-tick(state(ball(point(400, 400), 0, 400), [list: point(0, 0)], paddle(point(0, 0), 0)))
    is initial()
  my-tick(state(ball(point(400, 400), 0, 0), empty, paddle(point(0, 0), 0)))
    is initial()
end

fun is-collide(box1 :: Box, box2 :: Box) -> Boolean:
  doc: "check if two axis-aligned boxes overlap"
  x1 = box1.center.x
  y1 = box1.center.y
  width1 = box1.width
  height1 = box1.height
  x2 = box2.center.x
  y2 = box2.center.y
  width2 = box2.width
  height2 = box2.height
  
  x1-max = x1 + (width1 / 2)
  x1-min = x1 - (width1 / 2)
  y1-max = y1 + (height1 / 2)
  y1-min = y1 - (height1 / 2)
  x2-max = x2 + (width2 / 2)
  x2-min = x2 - (width2 / 2)
  y2-max = y2 + (height2 / 2)
  y2-min = y2 - (height2 / 2)
  
  (x1-max >= x2-min) and (x2-max >= x1-min) and (y1-max >= y2-min) and (y2-max >= y1-min)
where:
  # test fully contained box
  is-collide(box(point(10, 10), 20, 20), box(point(10, 10), 10, 10)) is true
  # test overlap on one side
  is-collide(box(point(10, 10), 20, 20), box(point(10, 20), 10, 10)) is true
  # test overlap on corner
  is-collide(box(point(10, 10), 20, 20), box(point(25, 25), 15, 15)) is true
  # test overlap on opposite sides
  is-collide(box(point(10, 10), 20, 20), box(point(10, 10), 10, 40)) is true
  # test edge and corner overlaps
  is-collide(box(point(10, 10), 20, 20), box(point(10, 30), 20, 20)) is true
  is-collide(box(point(10, 10), 20, 20), box(point(30, 30), 20, 20)) is true
  # test no overlap
  is-collide(box(point(10, 10), 20, 20), box(point(10, 40), 10, 10)) is false
  is-collide(box(point(10, 10), 20, 20), box(point(40, 10), 10, 10)) is false
  is-collide(box(point(10, 10), 20, 20), box(point(40, 40), 10, 10)) is false
end

fun collide-ball-boxes(a-ball :: Ball, boxes :: List<Box>) -> Boolean:
  doc: "a helper that checks if a ball collides with a list of boxes"
  ball-box = box(a-ball.center, ball-diameter, ball-diameter)
  boxes.map({(a-box): is-collide(ball-box, a-box)})
    .foldl({(a, b): a or b}, false)
where:
  collide-ball-boxes(ball(point(0, 0), 0, 0), empty) is false
  collide-ball-boxes(ball(point(0, 0), 0, 0), [list: box(point(100, 100), 50, 50)]) is false
  collide-ball-boxes(ball(point(0, 0), 0, 0), [list: box(point(25, 25), 50, 50)]) is true
  collide-ball-boxes(ball(point(0, 0), 0, 0), [list: box(point(25, 25), 5, 5)]) is false
  collide-ball-boxes(ball(point(0, 0), 0, 0), [list: box(point(100, 100), 50, 50), 
      box(point(10, 10), 50, 50), box(point(10, 10), 5, 5)]) is true
  collide-ball-boxes(ball(point(300, 400), 500, 600), [list: box(point(200, 100), 50, 100),
      box(point(350, 250), 1, 2)]) is false
end

fun collide-ball-paddle(a-ball :: Ball, a-paddle :: Paddle) -> {Number; Number}:
  doc: ```change velocity when ball collides in with paddle depending on where on the paddle the 
       collsion occurred to give player more control```
  magnitude = num-sqrt((a-ball.x-velocity * a-ball.x-velocity)
        + (a-ball.y-velocity * a-ball.y-velocity)) * magnitude-multiplier
  
  x-velocity = a-ball.center.x - a-paddle.center.x
  y-velocity = a-ball.center.y - a-paddle.center.y
  temp-magnitude = num-sqrt((x-velocity * x-velocity) + (y-velocity * y-velocity))
  
  {x-velocity * (magnitude / temp-magnitude); y-velocity * (magnitude / temp-magnitude)}
where:
  collide-ball-paddle(ball(point(1, 0), 1, 0), paddle(point(0, 0), 0)) is {1.05; 0}
  collide-ball-paddle(ball(point(1, 0), 0, 1), paddle(point(0, 0), 0)) is {1.05; 0}
  collide-ball-paddle(ball(point(1, 0), 3, 4), paddle(point(0, 0), 0)) is {5.25; 0}
  collide-ball-paddle(ball(point(4, 3), 1, 0), paddle(point(0, 0), 0)) is {0.84; 0.63}
  collide-ball-paddle(ball(point(9, 10), 0, 5), paddle(point(10, 10), 10)) is {-5.25; 0}
end

fun my-key(a-state :: State, key :: String) -> State:
  doc: "change the velocity of the paddle when the player presses any button"
  new-velocity = ask:
    | (key == "a") or (key == "left") then: -1 * paddle-velocity
    | (key == "d") or (key == "right") then: paddle-velocity
    | otherwise: 0
  end
  state(a-state.ball, a-state.bricks, 
    paddle(point(a-state.paddle.center.x, a-state.paddle.center.y), new-velocity))
where:
  my-key(state1, "left") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), -1 * paddle-velocity))
  my-key(state1, "a") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), -1 * paddle-velocity))
  my-key(state1, "right") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), paddle-velocity))
  my-key(state1, "d") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), paddle-velocity))
  my-key(state1, "random") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), 0))
  my-key(state1, "s") is state(ball(point(100, 100), 50, 50), 
    [list: point(200, 200), point(300, 300)], 
    paddle(point(400, 400), 0))
end

fun blocks-row(x-index :: Number, y-index :: Number) -> List<Point>:
  doc: "generate the initial list of blocks to hit"
  x = (x-index * box-width) + (box-width / 2)
  y = (y-index * box-height) + (box-height / 2)
  if (y-index >= max-row):
    empty
  else:
    if (x >= window-width):
      blocks-row(0, y-index + 1)
    else:
      link(point(x, y), blocks-row(x-index + 1, y-index))
    end
  end
where:
  blocks-row(0, 100) is empty
  blocks-row(0, 3) is [list: point(50, 87.5), point(150, 87.5), point(250, 87.5), point(350, 87.5), 
    point(450, 87.5), point(550, 87.5), point(650, 87.5), point(750, 87.5), point(850, 87.5), 
    point(950, 87.5), point(50, 112.5), point(150, 112.5), point(250, 112.5), point(350, 112.5), 
    point(450, 112.5), point(550, 112.5), point(650, 112.5), point(750, 112.5), point(850, 112.5), 
    point(950, 112.5)]
end

r = reactor:
  init: initial(),
  to-draw: my-draw,
  on-tick: my-tick,
  on-key: my-key
end

interact(r)
