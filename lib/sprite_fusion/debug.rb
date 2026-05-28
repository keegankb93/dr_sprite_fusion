module SpriteFusion
  class Debug
    attr_reader :map, :config

    def initialize(map, config = {})
      @map = map
      @config = config
    end

    def render
      grid if config.fetch(:grid, true)
      hover if config.fetch(:cell_info, false)
    end

    def grid(r: 255, g: 255, b: 255, a: 80)
      lines = []

      (0..map.columns).each do |col|
        x = col * map.tile_size

        lines << {
          x: x,
          y: 0,
          x2: x,
          y2: map.height,
          r: r,
          g: g,
          b: b,
          a: a
        }
      end

      (0..map.rows).each do |row|
        y = row * map.tile_size

        lines << {
          x: 0,
          y: y,
          x2: map.width,
          y2: y,
          r: r,
          g: g,
          b: b,
          a: a
        }
      end

      target.lines << lines
    end

    def screen_to_world(screen_x, screen_y)
      camera = config.camera

      return { x: screen_x, y: screen_y } unless camera

      {
        x: camera.x + screen_x / camera.scale,
        y: camera.y + screen_y / camera.scale
      }
    end

    def hover
      mouse = $args.inputs.mouse
      world_pos = screen_to_world(mouse.x, mouse.y)
      cell = map.cell_at(world_pos.x, world_pos.y)

      labels = [
        "Screen: #{mouse.x.to_i}, #{mouse.y.to_i}",
        "World: #{world_pos.x.to_i}, #{world_pos.y.to_i}",
        cell ? "Cell: #{cell.col}, #{cell.row}" : 'Cell: out of bounds'
      ]

      $args.outputs.primitives << {
        x: 0,
        y: 80.from_top,
        w: 360,
        h: 80,
        r: 0,
        g: 0,
        b: 0,
        a: 128
      }.solid!

      $args.outputs.labels << labels.map_with_index do |text, i|
        {
          x: 10,
          y: 10.from_top - (i * 22),
          text: text,
          size_enum: -2,
          r: 255,
          g: 255,
          b: 255,
          a: 255
        }
      end
    end

    private

    def target
      if config.target
        $args.outputs[config.target]
      else
        $args.outputs
      end
    end
  end
end
