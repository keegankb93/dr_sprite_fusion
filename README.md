## Simple importer for SpriteFusion

This takes a JSON export from [SpriteFusion](https://www.spritefusion.com/) and converts it into a format suitable for use with [DragonRuby](https://www.dragonruby.org/).

All you need to do is tell the importer where your JSON file and tileset image is and it will do the rest.

#### Disclaimer

This is an initial version of the importer. There are likely to be bugs and performane optimizations have not been implemented yet.

## Usage

To use the importer, either clone this repository and copy the `lib/sprite_fusion` directory into your project, or add the `lib/sprite_fusion` directory to your project.

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
