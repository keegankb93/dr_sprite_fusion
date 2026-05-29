require 'lib/sprite_fusion/map'
require 'app/camera'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    world = args.state.world
    world.debug do |debug_config|
      debug_config.target = :scene
      debug_config.camera = args.state.camera
      debug_config.collisions = true
      debug_config.grid = true
      debug_config.cell_info = true
    end

    args.state.player ||= {}
    args.state.player.x    ||= world.cell(0, 3).x
    args.state.player.y    ||= world.cell(0, 3).y
    args.state.player.w    ||= 16
    args.state.player.h    ||= 16

    args.state.enemy ||= {}
    args.state.enemy.x    ||= world.cell(5, 3).x
    args.state.enemy.y    ||= world.cell(5, 3).y
    args.state.enemy.size ||= 16

    args.state.camera ||= Camera.new(x: 0, y: 0)

    world  = args.state.world
    player = args.state.player
    enemy  = args.state.enemy
    camera = args.state.camera

    if args.inputs.directional_angle
      dx = args.inputs.directional_angle.vector_x * 2
      dy = args.inputs.directional_angle.vector_y * 2

      next_player = player.merge(x: player.x + dx)
      player.x += dx unless world.collides?(next_player)

      next_player = player.merge(y: player.y + dy)
      player.y += dy unless world.collides?(next_player)

      player.x = player.x.clamp(0, world.width - player.w)
      player.y = player.y.clamp(0, world.height - player.h)
    end

    camera.handle_camera_inputs(args)
    camera.follow(player, world)

    scene = args.outputs[:scene]
    scene.w = world.width
    scene.h = world.height

    world.render_to(scene)

    scene.sprites << {
      x: player.x,
      y: player.y,
      w: player.w,
      h: player.h,
      path: :solid,
      r: 0,
      g: 0,
      b: 255
    }

    scene.sprites << {
      x: enemy.x,
      y: enemy.y,
      w: enemy.size,
      h: enemy.size,
      path: :solid,
      r: 255,
      g: 0,
      b: 0
    }

    args.outputs.sprites << camera.viewport_for(:scene)

    args.outputs.primitives << {
      x: Grid.w - 360,
      y: 80.from_top,
      w: 360,
      h: 80,
      r: 0,
      g: 0,
      b: 0,
      a: 128
    }.solid!

    args.outputs.primitives << {
      x: Grid.w - 350,
      y: 10.from_top,
      text: 'arrow keys to move around',
      r: 255,
      g: 255,
      b: 255
    }.label!

    args.outputs.primitives << {
      x: Grid.w - 350,
      y: 30.from_top,
      text: '+/- to change zoom of camera',
      r: 255,
      g: 255,
      b: 255
    }.label!
  end
end
