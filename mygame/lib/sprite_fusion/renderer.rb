module SpriteFusion
  #
  # Renders a map loaded from the SpriteFusion loader.
  class Renderer
    attr_reader :map

    def initialize(map)
      @map = map
    end

    def render(args)
      args.outputs.sprites << sprites
    end

    def sprites
      map.layers.flat_map { |layer| layer[:tiles] }
    end
  end
end
