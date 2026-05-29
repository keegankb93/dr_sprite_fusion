module SpriteFusion
  #
  # Handles loading a map based on SpriteFusion json data and png tileset
  class Loader
    # SpriteFusion will pack your tileset into columns of 8
    TILESET_COLUMNS = 8

    attr_reader :spritesheet,
                :tile_size,
                :tileset_columns,
                :map_width,
                :map_height,
                :layers,
                :tiles,
                :collidable_tiles

    def initialize(data_path = nil, spritesheet = nil)
      @spritesheet = spritesheet

      parse(data_path)
    end

    def to_h
      {
        tile_size: tile_size,
        map_height: map_height,
        map_width: map_width,
        layers: layers
      }
    end

    private

    def parse(data_path)
      data = DR.parse_json_file(data_path)

      @tile_size = data['tileSize']
      @map_width = data['mapWidth']
      @map_height = data['mapHeight']
      @tiles = []
      @collidable_tiles = []
      @layers = parse_layers(data['layers'])
    end

    def parse_layers(raw_layers)
      raw_layers.reverse.map do |layer|
        parsed_tiles = parse_tiles_for(layer: layer)

        {
          name: layer['name'],
          collider: layer['collider'],
          tiles: parsed_tiles
        }
      end
    end

    def parse_tiles_for(layer:)
      layer['tiles'].map do |raw_tile|
        created_tile = create_tile(
          raw_tile,
          layer_name: layer['name'],
          collider: layer['collider']
        )

        # Track these separately so we can more efficiently check for collisions without checking
        # every tile every time
        tiles << created_tile
        collidable_tiles << created_tile if created_tile.collision_rect

        created_tile
      end
    end

    #
    # Creates a tile that conforms to what DragonRuby expects/wants to render
    def create_tile(raw_tile, layer_name:, collider:)
      # ID is the tile index into the tileset
      id = raw_tile['id'].to_i
      col, row = grid_position_for(raw_tile)
      x, y = position_for(col, row)

      # Attributes are custom properties that are defined on a per tile/tile instance basis
      attrs = raw_tile['attributes'] || {}

      {
        layer: layer_name,
        collision_rect: collision_rect_for(attrs, collider, x, y),
        col: col,
        row: row,
        x: x,
        y: y,
        w: tile_size,
        h: tile_size,
        tile_x: tile_x_for(id),
        tile_y: tile_y_for(id),
        tile_w: tile_size,
        tile_h: tile_size,
        path: spritesheet,
        attributes: attrs
      }
    end

    #
    # Allows the tile to override the layer's collider property
    def tile_collidable?(layer_collider, tile_collider)
      return tile_collider unless tile_collider.nil?

      layer_collider
    end

    #
    # Extracts the collision rect from the attributes
    def collision_rect_for(attrs, collider, x, y)
      return nil unless tile_collidable?(collider, attrs['collider'])

      hitbox_x = attrs.fetch('hitbox_x', 0)
      hitbox_y = attrs.fetch('hitbox_y', 0)
      hitbox_w = attrs.fetch('hitbox_w', tile_size)
      hitbox_h = attrs.fetch('hitbox_h', tile_size)

      {
        x: x + hitbox_x,
        y: y + hitbox_y,
        w: hitbox_w,
        h: hitbox_h
      }
    end

    #
    # Returns the x position of the tile in the spritesheet
    # @param id [Integer] the tile id
    def tile_x_for(id)
      (id % TILESET_COLUMNS) * tile_size
    end

    #
    # Returns the y position of the tile in the spritesheet
    # @param id [Integer] the tile id
    def tile_y_for(id)
      id.idiv(TILESET_COLUMNS) * tile_size
    end

    #
    # Returns the row and column of the tile in the map
    # SpriteFusion x and y are GRID coordinates, not pixel positions
    def grid_position_for(raw_tile)
      [
        raw_tile['x'],
        map_height - raw_tile['y'] - 1
      ]
    end

    #
    # Returns the coord position of the tile in the map
    def position_for(col, row)
      [
        col * tile_size,
        row * tile_size
      ]
    end
  end
end
