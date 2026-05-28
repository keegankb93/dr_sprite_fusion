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
      debug_config.grid = true
      debug_config.cell_info = true
    end

    args.state.player ||= {}
    args.state.player.x    ||= 0
    args.state.player.y    ||= 0
    args.state.player.size ||= 32

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
      player.x += args.inputs.directional_angle.vector_x * 2
      player.y += args.inputs.directional_angle.vector_y * 2

      player.x = player.x.clamp(0, world.width - player.size)
      player.y = player.y.clamp(0, world.height - player.size)
    end

    camera.handle_camera_inputs(args)
    camera.follow(player, world)

    scene = args.outputs[:scene]
    scene.w = world.width
    scene.h = world.height

    scene.sprites << world.sprites

    scene.sprites << {
      x: player.x,
      y: player.y,
      w: player.size,
      h: player.size,
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

    args.outputs.sprites << camera.viewport_sprite

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
