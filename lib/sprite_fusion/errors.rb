module SpriteFusion
  module Errors
    class LayerNotFoundError < StandardError
      def initialize(name)
        super("Layer not found: #{name}")
      end
    end

    class CellOutOfBoundsError < StandardError
      def initialize(col, row)
        super("Cell out of bounds: #{col}, #{row}")
      end
    end
  end
end
