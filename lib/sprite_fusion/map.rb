require_relative 'errors'
require_relative 'loader'
require_relative 'debug'

module SpriteFusion
  #
  # Provides an interface for loading and rendering a SpriteFusion map.
  class Map
    attr_reader :data

    def initialize(data_path, spritesheet)
      @data = SpriteFusion::Loader.new(data_path, spritesheet)
    end

    #
    # Renders a debug view of the map
    # Configurable via a block that yields a debug_config hash
    # Available configuration options:
    # - show_grid (default: false)
    # - target (default: nil) the grid will only be overlayed on the render target
    # - camera (default: nil) the camera to use for screen-to-world conversions for cell_info within the view
    # - cell_info (default: false) the cell info to display in the debug view
    # - collisions (default: false) the collisions to display in the debug view
    # @example
    #   def tick(args)
    #     args.state.camera ||= Camera.new # See example in /app/camera.rb otherwise roll your own!
    #     camera = args.state.camera
    #     scene = args.outputs[:scene]
    #
    #     args.state.world.debug do |config|
    #       config.show_grid = true
    #       config.target = scene
    #       config.camera = camera
    #       config.cell_info = true
    #       config.collisions = true
    #     end
    #   end
    def debug(&block)
      debug_config = {}

      yield(debug_config) if block_given?

      SpriteFusion::Debug.new(self, debug_config).render
    end

    #
    # Renders the map to the given target
    # Quick and easy way to simply render your map
    # @example
    #   def tick(args)
    #     args.state.world.render_to(args.outputs)
    #   end
    #
    #   def tick(args)
    #     scene = args.outputs[:scene]
    #     args.state.world.render_to(scene)
    #   end
    def render_to(target)
      target.sprites << tiles
    end

    #
    # Returns the tiles in correct order for rendering
    # Allows you to render the tiles how you want
    def tiles
      @tiles ||= data.tiles
    end

    #
    # Separate storage of collidable tiles
    # We store these separately so that we do not have to iterate through tiles that we know will
    # never be collidable
    def collidable_tiles
      @collidable_tiles ||= data.collidable_tiles
    end

    #
    # Returns the width in pixels of the map
    def width
      @width ||= data.map_width * data.tile_size
    end

    #
    # Returns the height in pixels of the map
    def height
      @height ||= data.map_height * data.tile_size
    end

    def tile_size
      @tile_size ||= data.tile_size
    end

    #
    # Returns the number of columns in the map provided by SpriteFusion data
    def columns
      @columns ||= data.map_width
    end

    #
    # Returns the number of rows in the map provided by SpriteFusion data
    def rows
      @rows ||= data.map_height
    end

    #
    # Returns all layers in the map in correct rendering order (last in first out)
    # Allows you to take control of rendering and parse through the layers how you want
    def layers
      @layers ||= data.layers
    end

    #
    # Get a layer by its name
    # Allows you to take control of rendering and render layers how you want
    def find_layer_by(name:)
      return @find_layer_by[name] if @find_layer_by&.key?(name)

      layer = layers.find { |layer| layer.name == name }

      raise(SpriteFusion::Errors::LayerNotFoundError, name) unless layer

      @find_layer_by ||= {}
      @find_layer_by[name] ||= layer
    end

    #
    # Returns the first collidable tile that intersects with the given rect
    def collision_for(rect)
      collidable_tiles.find do |tile|
        # Tolerance of 0.75 allows for some leeway in collision detection
        tile.collision_rect.intersect_rect?(rect, 0.75)
      end
    end

    #
    # Predicate helper for checking if a rect collides with the map
    # @example
    #   def tick(args)
    #     args.state.player ||= { x: 0, y: 0, w: 16, h: 16 }
    #
    #     if args.state.world.collides?(args.state.player)
    #       puts 'collided'
    #     end
    #   end
    def collides?(rect)
      !!collision_for(rect)
    end

    #
    # Returns a cell at the given column and row position
    # Generally easier to position things when thinking in terms of a grid vs pixels
    # I.e. spawn my character at cell(3, 5) instead of x: 24, y: 40 or something along those lines
    def cell(col, row)
      raise(SpriteFusion::Errors::CellOutOfBoundsError, col, row) if out_of_bounds(col, row)

      {
        col: col,
        row: row,
        x: col * tile_size,
        y: row * tile_size,
        w: tile_size,
        h: tile_size
      }
    end

    #
    # Returns the cell at the given pixel position
    # @example
    #   cell_at(100, 200)
    #   # => { col: 5, row: 10, x: 100, y: 200, w: 16, h: 16 }
    def cell_at(x, y)
      col = x.idiv(tile_size)
      row = y.idiv(tile_size)

      return nil if out_of_bounds(col, row)

      cell(col, row)
    end

    private

    #
    # Returns whether the given column and row are out of bounds
    def out_of_bounds(col, row)
      col.negative? || row.negative? || col >= columns || row >= rows
    end
  end
end
