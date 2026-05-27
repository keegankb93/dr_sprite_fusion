require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.render(args)
  end
end
