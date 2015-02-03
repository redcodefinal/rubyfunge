#! /usr/bin/env ruby
DEBUG = false
class Rubyfunge
  DIRECTIONS = [?>, ?v, ?<, ?^]
  OPERATIONS = [?+, ?-, ?*, ?/, ?%]
  MEM_INSTRUCTIONS = [174.chr, 175.chr, ??, ?", ?', ?(, ?)]
  STORE_INSTRUCTIONS = [?:, ?[, ?], ?$]
  OUTPUT_INSTRUCTIONS = [?,, ?., ?{, ?}]
  INPUT_INSTRUCTIONS = [?~, ?&, ?;]
  LOGICAL_CONTROL = [?`, ?!, ?|, ?_, 203.chr, 202.chr, 204.chr, 185.chr, 192.chr, 191.chr, 217.chr, 218.chr]
  THREAD_CONTROL = [?@, ?=, 197.chr, 193.chr, 194.chr, 195.chr, 180.chr]
  INSTRUCTIONS = DIRECTIONS + OPERATIONS + MEM_INSTRUCTIONS + STORE_INSTRUCTIONS + OUTPUT_INSTRUCTIONS + INPUT_INSTRUCTIONS + FLOW_CONTROL + THREAD_CONTROL

  attr_accessor  :input, :output
  attr_reader :code, :threads, :original_input
  
  def initialize(code, input = "")
    @code = code

    @input = input
    @original_input = input

    @output = ""

    @threads = []
    @threads << RubyfungeThread.new(self)
  end

  def run_one_instruction
    @threads.each(&:run_one_instruction)
    @threads.delete_if { |t| t.ended? }
  end

  def run
    until @threads.all?(&:ended?)
      run_one_instruction
    end
    @output
  end

  def reset
    @input = @original_input
    @stack = []
    @direction = ?>
    @output = ""
  end

  def fork(thread, direction)
    @threads << thread.fork(direction)
  end
end

class RubyfungeThread

  attr_reader :machine
  attr_reader :code, :code_position, :memory, :memory_position, :stage
  attr_accessor :direction

  def initialize(machine)
    @machine = machine
    @code = @machine.code.lines.map(&:chomp)
    @code_position = Struct.new(:x, :y).new(0, 0)
    @stage = [0, 0]

    @memory = [0]
    @memory_position = 0

    @direction = ?>
  end

  def fork(direction)
    forked = dup
    forked.send "turn_#{direction.to_s}"
    forked.move 1
    forked
  end

  def run_one_instruction
    #DIRECTIONS
    if DIRECTIONS.include? get_code
      @direction = get_code

    #OPERATIONS
    elsif OPERATIONS.include? get_code
      store @stage_a.send(get_code.to_sym, @stage_b)

    #MEM_INSTRUCTIONS
    elsif get_code == 174.chr
      if stage_b > 0
        stage_b.times do
          move_mem_position_left
        end
      end
    elsif get_code == 175.chr
      if stage_b > 0
        stage_b.times do
          move_mem_position_right
        end
      end
    elsif get_code == ??
      store stage_b
    elsif get_code == ?"
      restore = @memory_position
      loop do
        #move first
        move(1)
        break if get_code == ?"
        store get_code.ord
        move_mem_position_right
      end
      @memory_position = restore
    elsif get_code == ?'
      number = ''
      loop do
        #move first
        move(1)
        break if get_code == ?'
        number << get_code
      end
      store number.to_i
    elsif get_code == ?(
      move_mem_position_left
    elsif get_code == ?)
      move_mem_position_right

    #STORE_INSTRUCTIONS
    elsif get_code == ?:
      stage_v(get_value)
    elsif get_code == ?[
      stage_v(get_value)
      move_mem_position_left
    elsif get_code == ?]
      stage_v(get_value)
      move_mem_position_right
    elsif get_code == ?$
      @stage.reverse!

    #OUTPUT_INSTRUCTIONS
    elsif get_code == ?.
      @output << get_value

    elsif get_code == ?,
      @output << get_value.chr

    elsif get_code == ?}
      @output << get_value.chr
      move_mem_position_right

    elsif get_code == ?{
      @output << get_value.chr
      move_mem_position_left

    #INPUT_INSTRUCTIONS
    elsif get_code == ?&
      store @input.slice!(0).to_i unless @input.length == 0
    elsif get_code == ?~
      store @input.slice!(0).ord unless @input.length == 0
    elsif get_code == ?;
      store ((@input.length == 0) ? 1 : 0)

    #LOGICAL_CONTROL
    elsif get_code == ?!
      store ((stage_b <= 0) ? 1 : 0)
    elsif get_code == ?`
      store ((stage_a > stage_b) ? 1 : 0)
    elsif get_code == ?|
      @direction = ((get_value == 0) ? ?v : ?^)
    elsif get_code == ?_
      @direction = ((get_value == 0) ? ?> : ?<)
    elsif get_code == 203.chr
      if @direction == ?v
        turn_around
      elsif @direction == ?> && get_value > 0
        turn_right
      elsif @direction == ?< && get_value <= 0
        turn_left
      elsif @direction == ?^
        ((get_value <= 0) ? turn_left : turn_right)
      end
    elsif get_code == 202.chr
      if @direction == ?v
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?> && get_value <= 0
        turn_left
      elsif @direction == ?< && get_value > 0
        turn_right
      elsif @direction == ?^
        turn_around
      end
    elsif get_code == 204.chr
      if @direction == ?v && get_value <= 0
        turn_left
      elsif @direction == ?>
        turn_around
      elsif @direction == ?<
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?^ && get_value > 0
        turn_right
      end
    elsif get_code == 185.chr
      if @direction == ?v && get_value > 0
        turn_right
      elsif @direction == ?>
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?<
        turn_around
      elsif @direction == ?^ && get_value <= 0
        turn_left
      end
    elsif get_code == 192.chr
      if @direction == ?v
        turn_left
      elsif @direction == ?>
        turn_around
      elsif @direction == ?<
        turn_right
      elsif @direction == ?^
        turn_around
      end
    elsif get_code == 191.chr
      if @direction == ?v
        turn_around
      elsif @direction == ?>
        turn_right
      elsif @direction == ?<
        turn_around
      elsif @direction == ?^
        turn_left
      end
    elsif get_code == 217.chr
      if @direction == ?v
        turn_right
      elsif @direction == ?>
        turn_left
      elsif @direction == ?<
        turn_around
      elsif @direction == ?^
        turn_around
      end
    elsif get_code == 218.chr
      if @direction == ?v
        turn_around
      elsif @direction == ?>
        turn_around
      elsif @direction == ?<
        turn_left
      elsif @direction == ?^
        turn_right
      end

    #TREAD_CONTROL
    elsif get_code == 197.chr
      machine.fork(self, :right)
      machine.fork(self, :left)
    elsif get_code == 193.chr
      if @direction == ?^
        turn_around
      elsif @direction == ?>
        machine.fork(self, :left)
      elsif @direction == ?<
        machine.fork(self, :right)
      elsif @direction == ?v
        machine.fork(self, :left)
        turn_right
      end
    elsif get_code == 194.chr
      if @direction == ?^
        machine.fork(self, :left)
        turn_right
      elsif @direction == ?>
        machine.fork(self, :right)
      elsif @direction == ?<
        machine.fork(self, :left)
      elsif @direction == ?v
        turn_around
      end
    elsif get_code == 195.chr
      if @direction == ?^
        machine.fork(self, :right)
      elsif @direction == ?>
        turn_around
      elsif @direction == ?<
        machine.fork(self, :left)
        turn_right
      elsif @direction == ?v
        machine.fork(self, :left)
      end
    elsif get_code == 180.chr
      if @direction == ?^
        machine.fork(self, :left)
      elsif @direction == ?>
        machine.fork(self, :left)
        turn_right
      elsif @direction == ?<
        turn_around
      elsif @direction == ?v
        machine.fork(self, :right)
      end

    #NUMERALS
    elsif (?0..?9).include? get_code
      store get_code.to_i
    end

    move((get_code == ?=) ? 2 : 1) unless get_code == ?@

    @output
  end

  def stage_v(num)
    @stage << num
    @stage.delete_at 0
  end

  def stage_a
    stage[0]
  end

  def stage_b
    stage[0]
  end

  def store(num)
    @memory[@memory_position] = num
  end

  def get_value
    @memory[@memory_position]
  end

  def get_code
    @code[@code_position.y][@code_position.x]
  end

  def move(spaces)
    if @direction == ?>
      @code_position.x += spaces
    elsif @direction == ?<
      @code_position.x -= spaces
    elsif @direction == ?^
      @code_position.y -= spaces
    elsif @direction == ?v
      @code_position.y += spaces
    end
  end

  def turn_left
    Rubyfunge::DIRECTIONS[(((Rubyfunge::DIRECTIONS.index(@direction) + 1) >= 4) ? 0 : Rubyfunge::DIRECTIONS.index(@direction))]
  end

  def turn_right
    Rubyfunge::DIRECTIONS[(Rubyfunge::DIRECTIONS.index(@direction) - 1)]
  end

  def turn_around
    turn_right
    turn_right
  end

  def move_mem_position_right
    @memory_position += 1
    @memory << 0 if @memory_position > @memory.length
  end

  def move_mem_position_left
    @memory_position -= 1
    if @memory_position < 0
      @memory_position = 0
      @memory.unshift 0
    end
  end

  def ended?
    get_code == ?@
  end
end