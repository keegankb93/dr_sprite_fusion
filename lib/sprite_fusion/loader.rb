module SpriteFusion
  #
  # Loads a map based on SpriteFusion json data and png
  class Loader
    # SpriteFusion will pack your tileset into columns of 8
    TILESET_COLUMNS = 8

    attr_reader :spritesheet, :tile_size, :tileset_columns, :map_width, :map_height, :layers

    def initialize(data_path = nil, spritesheet = nil)
      @spritesheet = spritesheet

      parse(data_path)
    end

    def to_h
      {
        tile_size: @tile_size,
        map_height: @map_height,
        map_width: @map_width,
        layers: @layers
      }
    end

    private

    def parse(data_path)
      data = DR.parse_json_file(data_path)

      @tile_size = data['tileSize']
      @map_width = data['mapWidth']
      @map_height = data['mapHeight']
      @layers = parse_layers(data['layers'])
    end

    def parse_layers(raw_layers)
      parsed_layers = []

      raw_layers.each do |layer|
        # Layers are parsed in reverse order so that they render in the correct order "last in first out"
        # We could probably just reverse this at render time, but this is probably marginally more efficient
        parsed_layers.unshift({
                                name: layer['name'],
                                collider: layer['collider'],
                                tiles: parse_tiles(layer['tiles'])
                              })
      end

      parsed_layers
    end

    def parse_tiles(raw_tiles)
      raw_tiles.map { |t| create_tile(t) }
    end

    def create_tile(raw_tile)
      id = raw_tile['id'].to_i

      {
        x: raw_tile['x'] * tile_size,
        y: (@map_height - raw_tile['y'] - 1) * @tile_size,
        w: tile_size,
        h: tile_size,
        tile_x: tile_x_for(id),
        tile_y: tile_y_for(id),
        tile_w: tile_size,
        tile_h: tile_size,
        path: @spritesheet
      }
    end

    #
    # Returns the x position of the tile in the spritesheet
    # @param id [Integer] the tile id
    def tile_x_for(id)
      (id % TILESET_COLUMNS) * @tile_size
    end

    #
    # Returns the y position of the tile in the spritesheet
    # @param id [Integer] the tile id
    def tile_y_for(id)
      id.idiv(TILESET_COLUMNS) * tile_size
    end
  end
end
