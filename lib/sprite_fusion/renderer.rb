module SpriteFusion
  #
  # Renders a map loaded from the SpriteFusion loader.
  class Renderer
    attr_reader :map

    def initialize(map)
      @map = map
    end

    # TODO: I think we can do some yield/block shenanigans here so that the sprites can be
    #       rendered to w/e target
    def render(args)
      args.outputs.sprites << sprites
    end

    def sprites
      map.layers.flat_map { |layer| layer[:tiles] }
    end
  end
end
