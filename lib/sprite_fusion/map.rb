require_relative 'errors'
require_relative 'loader'
require_relative 'debug'

module SpriteFusion
  # Provides access to loading and rendering a SpriteFusion map.
  # TODO: Memoizing everything may not be the play especially just for the accessors
  class Map
    attr_reader :data

    def initialize(data_path, spritesheet)
      @data = SpriteFusion::Loader.new(data_path, spritesheet)
    end

    def debug(&block)
      debug_config = {}

      yield(debug_config) if block_given?

      SpriteFusion::Debug.new(self, debug_config).render
    end

    def layers
      @layers ||= data.layers
    end

    #
    # Render all sprites for the map in the order they appear in layers (last in first out)
    def sprites
      @sprites ||= layers.flat_map { |layer| layer[:tiles] }
    end

    #
    # Explicit layer rendering via name
    def sprites_for_layer(name)
      return @sprites_for_layer[name] if @sprites_for_layer&.key?(name)

      layer = find_layer_by_name(name)

      raise(SpriteFusion::Errors::LayerNotFoundError, name) unless layer

      @sprites_for_layer ||= {}
      @sprites_for_layer[name] ||= layer[:tiles]
    end

    def width
      @width ||= data.map_width * data.tile_size
    end

    def tile_size
      @tile_size ||= data.tile_size
    end

    def height
      @height ||= data.map_height * data.tile_size
    end

    def columns
      @columns ||= data.map_width
    end

    def rows
      @rows ||= data.map_height
    end

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

    def cell_at(x, y)
      col = x.idiv(tile_size)
      row = y.idiv(tile_size)

      return nil if out_of_bounds(col, row)

      cell(col, row)
    end

    private

    def out_of_bounds(col, row)
      col.negative? || row.negative? || col >= columns || row >= rows
    end

    def find_layer_by_name(name)
      layers.find { |layer| layer.name == name }
    end
  end
end
