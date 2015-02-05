#! /usr/bin/env ruby
DEBUG = false
class Rubyfunge
  DIRECTIONS = [?>, ?v, ?<, ?^] #Tested
  OPERATIONS = [?+, ?-, ?*, ?/, ?%] #Tested
  MEM_INSTRUCTIONS = [?l, ?r, ??, ?", ?', ?(, ?)] #Tested
  STORE_INSTRUCTIONS = [?:, ?[, ?], ?$] #Tested
  OUTPUT_INSTRUCTIONS = [?,, ?., ?{, ?}] #Tested
  INPUT_INSTRUCTIONS = [?~, ?&, ?;] #Tested
  LOGICAL_CONTROL = [?`, ?!, ?|, ?_, 203.chr, 202.chr, 204.chr, 185.chr]
  THREAD_CONTROL = [?@, ?=, 197.chr, 193.chr, 194.chr, 195.chr, 180.chr]
  INSTRUCTIONS = DIRECTIONS + OPERATIONS + MEM_INSTRUCTIONS + STORE_INSTRUCTIONS + OUTPUT_INSTRUCTIONS + INPUT_INSTRUCTIONS + LOGICAL_CONTROL + THREAD_CONTROL

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

  def main
    @threads.first
  end

  def run_one_instruction
    @threads.delete_if { |t| t.ended? }
    @threads.each(&:run_one_instruction)
  end

  def run
    until ended?
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

  def ended?
    @threads.length.zero?
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
    forked.send "turn_#{direction.to_s}".to_sym
    forked.move 1
    forked
  end

  def run_one_instruction
    int = get_code

    #DIRECTIONS
    if Rubyfunge::DIRECTIONS.include? int
      @direction = int
    elsif Rubyfunge::OPERATIONS.include? int  #OPERATIONS
      store stage_a.send(int.to_sym, stage_b).to_i
    elsif int == ?l #MEM_INSTRUCTIONS
      if get_value > 0
        get_value.times do
          move_mem_position_left
        end
      end
    elsif int == ?r
      if get_value > 0
        get_value.times do
          move_mem_position_right
        end
      end
    elsif int == ??
      store stage_b
    elsif int == ?"
      restore = @memory_position
      loop do
        #move first
        move(1)
        break if get_code == ?"
        store get_code.ord
        move_mem_position_right
      end
      @memory_position = restore
    elsif int == ?'
      number = ''
      loop do
        #move first
        move(1)
        break if get_code == ?'
        number << get_code
      end
      store number.to_i
    elsif int == ?(
      move_mem_position_left
    elsif int == ?)
      move_mem_position_right
    elsif int == ?: #STORE_INSTRUCTIONS
      stage_v(get_value)
    elsif int == ?[
      stage_v(get_value)
      move_mem_position_left
    elsif int == ?]
      stage_v(get_value)
      move_mem_position_right
    elsif int == ?$
      @stage.reverse!
    elsif int == ?.    #OUTPUT_INSTRUCTIONS
      machine.output << get_value.to_s
    elsif int == ?,
      machine.output << get_value.chr
    elsif int == ?}
      machine.output << get_value.chr
      move_mem_position_right
    elsif int == ?{
      @output << get_value.chr
      move_mem_position_left
    elsif int == ?&    #INPUT_INSTRUCTIONS
      store machine.input.slice!(0).to_i unless machine.input.length == 0
    elsif int == ?~
      store machine.input.slice!(0).ord unless machine.input.length == 0
    elsif int == ?;
      store ((machine.input.length == 0) ? 0 : 1)
    elsif int == ?! #LOGICAL_CONTROL
      store ((stage_b <= 0) ? 1 : 0)
    elsif int == ?`
      store ((stage_a > stage_b) ? 1 : 0)
    elsif int == ?|
      @direction = ((get_value == 0) ? ?v : ?^)
    elsif int == ?_
      @direction = ((get_value == 0) ? ?> : ?<)
    elsif int == ?w
      if @direction == ?v
        turn_around
      elsif @direction == ?> && get_value > 0
        turn_right
      elsif @direction == ?< && get_value <= 0
        turn_left
      elsif @direction == ?^
        ((get_value <= 0) ? turn_left : turn_right)
      end
    elsif int == ?y
      if @direction == ?v
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?> && get_value <= 0
        turn_left
      elsif @direction == ?< && get_value > 0
        turn_right
      elsif @direction == ?^
        turn_around
      end
    elsif int == ?x
      if @direction == ?v && get_value <= 0
        turn_left
      elsif @direction == ?>
        turn_around
      elsif @direction == ?<
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?^ && get_value > 0
        turn_right
      end
    elsif int == ?z
      if @direction == ?v && get_value > 0
        turn_right
      elsif @direction == ?>
        ((get_value <= 0) ? turn_left : turn_right)
      elsif @direction == ?<
        turn_around
      elsif @direction == ?^ && get_value <= 0
        turn_left
      end
    elsif int == ?t    #TREAD_CONTROL
      machine.fork(self, :right)
      machine.fork(self, :left)
    elsif int == ?i
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
    elsif int == ?T
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
    elsif int == ?E
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
    elsif int == ?q
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
    elsif (?0..?9).include? int#NUMERALS
      store int.to_i
    end

    move((int == ?=) ? 2 : 1) unless ended?

    @output
  end

  def stage_v(num)
    @stage << num
    @stage.delete_at 0
  end

  def stage_a
    stage.first
  end

  def stage_b
    stage.last
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
    @memory << 0 if @memory_position >= @memory.length
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