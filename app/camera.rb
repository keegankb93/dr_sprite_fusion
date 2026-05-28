class Camera
  attr_accessor :x, :y, :w, :h, :scale, :show_empty_space

  def initialize(x: 640, y: 300, w: 1280, h: 720, scale: 6.0, show_empty_space: :yes)
    @x = x
    @y = y
    @w = w
    @h = h
    @scale = scale
    @show_empty_space = show_empty_space
  end

  def source_w
    w / scale
  end

  def source_h
    h / scale
  end

  def viewport_sprite
    {
      x: 0,
      y: 0,
      w: w,
      h: h,
      path: :scene,
      source_x: x,
      source_y: y,
      source_w: source_w,
      source_h: source_h
    }
  end

  def handle_camera_inputs(args)
    if args.inputs.keyboard.plus && Kernel.tick_count.zmod?(3)
      self.scale += 0.1
    elsif args.inputs.keyboard.hyphen && Kernel.tick_count.zmod?(3)
      self.scale -= 0.1
    elsif args.inputs.keyboard.key_down.tab
      self.show_empty_space = if show_empty_space == :yes
                                :no
                              else
                                :yes
                              end
    end

    self.scale = scale.clamp(min_scale_for(args.state.world), 8.0)
  end

  def follow(target, world)
    @x = target.x - source_w.half
    @y = target.y - source_h.half

    clamp_to_world(world)
  end

  def min_scale_for(world)
    [
      w.fdiv(world.width),
      h.fdiv(world.height)
    ].max
  end

  def clamp_to_world(world)
    @x = @x.clamp(0, [world.width - source_w, 0].max)
    @y = @y.clamp(0, [world.height - source_h, 0].max)
  end
end
