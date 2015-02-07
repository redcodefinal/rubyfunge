require 'RMagick'
require './rubyfunge.rb'
require 'fileutils'

include Magick

class RubyfungeViewer
  attr_reader :name
  attr_reader :snapshots

  def initialize(name, code, input = '')
    @name = name
    FileUtils.mkdir_p(name)
    @machine = Rubyfunge.new(code, input)
    @snapshots = []
  end

  def run
    frame = 0
    snapshot = @machine.to_snapshot
    snapshot.frame = frame
    @snapshots << snapshot
    frame += 1
    until @machine.main.ended?
      @machine.run_one_instruction
      snapshot = @machine.to_snapshot
      snapshot.frame = frame
      @snapshots << snapshot
      frame += 1
    end
  end

  #draws the code in black
  def draw_code img, snapshot
    code = @machine.code.map(&:dup)
    code[snapshot.code_position.y][snapshot.code_position.x] = " "
    code = code.join('\n')
    text = Draw.new
    text.annotate(img, 0, 0, 0, 7, code) do
      self.gravity = NorthWestGravity
      self.kerning = 0
      self.pointsize = 10
      self.font_family = "Liberation Mono"
      self.fill = "black"
      self.stroke = 'none'
    end
  end

  #draws the current code position in red
  def draw_code_position img, snapshot
    code = @machine.code[snapshot.code_position.y][snapshot.code_position.x]
    code = ((code == " ") ? snapshot.direction : code)
    padding = ("\n" * snapshot.code_position.y) +
        (" " * snapshot.code_position.x)

    text = Draw.new
    text.annotate(img, 0, 0, 0, 7, (padding + code)) do
      self.gravity = NorthWestGravity
      self.kerning = 0
      self.pointsize = 10
      self.font_family = "Liberation Mono"
      self.fill = "red"
      self.stroke = 'none'
    end
  end



  #draws the hud in black
  def draw_hud img, snapshot
    hud = ("\n" * 27)
    hud += "input: #{snapshot.input}\n"
    hud += "output: #{snapshot.output}\n"
    hud += "stage_a: " + ("%6d" % snapshot.stage[0]) + "\n"
    hud += "stage_b: " + ("%6d" % snapshot.stage[1]) + "\n"
    hud += "d: #{snapshot.direction}\n"
    #memory_wheel
    #4 previous mem locations
    5.downto(1) do |t|
      value = nil
      if snapshot.memory_position - t < 0
        value = 0
      else
        value = snapshot.memory[snapshot.memory_position - t]
      end
      hud += value.to_s.center(6) + "~"
    end
    hud[-1] = "|"
    hud += (snapshot.memory[snapshot.memory_position]).to_s.center(6) + "|"
    4.times do |t|
      if (snapshot.memory_position + t + 1) >= snapshot.memory.length
        value = 0
      else
        value = snapshot.memory[(snapshot.memory_position + t + 1)]
      end
      hud += value.to_s.center(6) + "~"
    end
    hud[-1] = ""

    text = Draw.new
    text.annotate(img, 0, 0, 0, 7, hud) do
      self.gravity = NorthWestGravity
      self.kerning = 0
      self.pointsize = 10
      self.font_family = "Liberation Mono"
      self.fill = "red"
      self.stroke = 'none'
    end
  end

  #draws new/changed values in red
  def draw_changed img, snapshot

  end

  def render_frame frame
    image = Image.new(400,400)
    draw_code image, snapshots[frame]
    draw_code_position image, snapshots[frame]
    draw_hud image, snapshots[frame]
    image.write("#{name}/#{name}-#{frame}.png")
  end

  def make_gif
    snapshots.length.times do |frame|
      render_frame frame
    end
    gif = ImageList.new(*Dir["#{name}/#{name}-*.png"])
    gif.delay = 100
    gif.write("#{name}/#{name}.gif")
  end
end

class RubyfungeSnapshot < Struct.new(:frame, :memory, :memory_position, :code_position, :input, :output, :stage, :direction)
end

class Rubyfunge
  def to_snapshot
    snapshot = RubyfungeSnapshot.new
    snapshot.memory = main.memory.dup
    snapshot.memory_position = main.memory_position
    snapshot.code_position = main.code_position.dup
    snapshot.stage = main.stage.dup
    snapshot.input = input.dup
    snapshot.output = output.dup
    snapshot.direction = main.direction.dup
    snapshot
  end
end