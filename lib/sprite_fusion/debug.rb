module SpriteFusion
  module Debug
    def self.cell_labels(map, r: 255, g: 255, b: 255, a: 120)
      labels = []

      map.columns.times do |col|
        map.rows.times do |row|
          cell = map.cell(col, row)

          labels << {
            x: cell.x + 2,
            y: cell.y + map.tile_size - 4,
            text: "#{col},#{row}",
            size_enum: -4,
            r: r,
            g: g,
            b: b,
            a: a
          }
        end
      end

      labels
    end
  end
end
