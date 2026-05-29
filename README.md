# dr_sprite_fusion

A simple DragonRuby importer for [SpriteFusion](https://www.spritefusion.com/) maps.

This takes a SpriteFusion JSON export and its generated `spritesheet.png` and allows you to render it in your DragonRuby game.

## Disclaimer

There may be bugs, edge cases and potential performance optimizations that can still be made. Feel free to create an issue and I'll take a look or if you have a solution feel free to make a pull request.

## Installation

For now, copy the `lib/sprite_fusion` directory into your DragonRuby project.

Then require the map class:

```ruby
require 'lib/sprite_fusion/map'
```

## Basic Usage

```ruby
require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.render_to(args.output)
  end
end
```

## Rendering to a specific output

You can render to a specific output by passing it to `render_to`:

```ruby
require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    scene = args.outputs[:scene]
    args.state.world.render_to(scene)
  end
end
```


## Control your own rendering

If you want to have more granular control over rendering there are a few methods available:


You can render a specific layer by name:

```ruby
require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.outputs.sprites << args.state.world.find_layer_by(name: 'Ground').tiles
  end
end
```

```ruby
require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.outputs.sprites << %w[Water Ground Objects].flat_map do |layer_name|
      args.state.world.find_layer_by(name: layer_name).tiles
    end
  end
end
```

Render the tiles yourself:

```ruby
module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.outputs.sprites << args.state.world.tiles
  end
end
```

Render the layers yourself:

```ruby
module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.outputs.sprites << args.state.world.layers.flat_map(&:tiles)
  end
end
```

## Collisions

SpriteFusion exports layers as collision layers or you can use custom attributes to define a custom hitbox

You'll mainly use the `collides?` method to check for collisions

```ruby
module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.render_to(args.outputs)

    args.state.player ||= { x: 0, y: 0, width: 16, height: 16 }

    if args.inputs.directional_angle
      dx = args.inputs.directional_angle.vector_x * 2
      dy = args.inputs.directional_angle.vector_y * 2

      next_player = player.merge(x: player.x + dx) # get next pos
      player.x += dx unless world.collides?(next_player) # check for collisions before moving

      next_player = player.merge(y: player.y + dy) # get next pos
      player.y += dy unless world.collides?(next_player) # check for collisions before moving

      player.x = player.x.clamp(0, world.width - player.w)
      player.y = player.y.clamp(0, world.height - player.h)
    end
    
  end
end
```

If your tile needs a more custom hitbox, you can define it in the tile's attributes:

``` IMAGE HERE ```


## Custom attributes

Alongside the above hitbox definition, you can define custom attributes for anything you need and handle it
however you want.

```json
{
  "attributes": {
    "health": 100
  }
}
```

Will be available in the tile's `attributes` hash.

## Debug Rendering

Then render debug information:

```ruby
module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.debug do |debug_config|
      debug_config.target = :scene
      debug_config.camera = args.state.camera
      debug_config.grid = true
      debug_config.cell_info = true
      debug_config.collisions = true
    end
  end
end
```

Debug rendering is useful for checking tile bounds, collision layers, map dimensions, or coordinate issues while working on an imported map.

## Full Example

```ruby
require 'lib/sprite_fusion/map'
require 'lib/sprite_fusion/debug'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    # Render layers manually.
    args.state.world.sprites_for_layer('Water')
    args.state.world.sprites_for_layer('Ground')
    args.state.world.sprites_for_layer('Objects')

    # Optional debug overlay. Note: this can be rendered in any order since it uses $args.outputs.debug
    args.state.world.debug do |debug_config|
      debug_config.target = :scene
      debug_config.camera = args.state.camera # This is your own camera
      debug_config.grid = true
      debug_config.cell_info = true
    end
  end
end
```

## Notes

SpriteFusion packs exported tiles into fixed-width rows. This importer assumes the SpriteFusion tileset layout and converts tile ids into DragonRuby source rectangles automatically.

SpriteFusion map coordinates are converted into DragonRuby-friendly sprite hashes, so the resulting tiles can be pushed directly into `args.outputs.sprites`.
