require_relative 'loader'
require_relative 'renderer'

module SpriteFusion
  # Provides access to loading and rendering a SpriteFusion map.
  class Map
    attr_reader :data

    def initialize(data_path, spritesheet)
      @data = SpriteFusion::Loader.new(data_path, spritesheet)
      @renderer = SpriteFusion::Renderer.new(@data)
    end

    def render(args)
      @renderer.render(args)
    end

    def layers
      data.layers
    end

    def layer_names
      data.layers.map(&:name)
    end

    def tile_size
      data.tile_size
    end

    def map_width
      data.map_width
    end

    def map_height
      data.map_height
    end
  end
end
