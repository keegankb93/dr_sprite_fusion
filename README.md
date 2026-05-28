# dr_sprite_fusion

A simple DragonRuby importer for [SpriteFusion](https://www.spritefusion.com/) maps.

This takes a SpriteFusion JSON export and its generated `spritesheet.png`, then converts the map into DragonRuby-compatible sprite hashes.

## Disclaimer

This is an early version. There are probably bugs, missing features, and performance optimizations that have not been implemented yet.

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

    args.state.world.render(args)
  end
end
```

## Rendering a Specific Layer

You can render a specific layer by name:

```ruby
require 'lib/sprite_fusion/map'

module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.render_layer(args, 'Ground')
  end
end
```

This is useful if you want to control render order manually:

```ruby
args.state.world.render_layer(args, 'Water')
args.state.world.render_layer(args, 'Ground')
args.state.world.render_layer(args, 'Objects')
```

## Debug Rendering

You can include the debug helper:

```ruby
require 'lib/sprite_fusion/map'
require 'lib/sprite_fusion/debug'
```

Then render debug information:

```ruby
module Main
  def tick(args)
    args.state.world ||= SpriteFusion::Map.new(
      'maps/map.json',
      'maps/spritesheet.png'
    )

    args.state.world.render(args)
    args.state.world.render_debug(args)
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
    args.state.world.render_layer(args, 'Water')
    args.state.world.render_layer(args, 'Ground')
    args.state.world.render_layer(args, 'Objects')

    # Optional debug overlay.
    args.state.world.render_debug(args)
  end
end
```

## Notes

SpriteFusion packs exported tiles into fixed-width rows. This importer assumes the SpriteFusion tileset layout and converts tile ids into DragonRuby source rectangles automatically.

SpriteFusion map coordinates are converted into DragonRuby-friendly sprite hashes, so the resulting tiles can be pushed directly into `args.outputs.sprites`.
