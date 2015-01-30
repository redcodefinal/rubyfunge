#! /usr/bin/env ruby
DEBUG = false
class Rubyfunge
  DIRECTIONS = [?>, ?<, ?^, ?v]
  OPERANDS = [?+, ?-, ?*, ?/, ?%]
  INSTRUCTIONS = [?@, ?!, ?", ?`, ?_, ?_, ?:, ?=, ?$, ?., ?,, ?&, ?~, ?#, ??, ?;] + DIRECTIONS + OPERANDS
  
  attr_reader :code, :code_position, :input, :memory, :memory_position, :stage,  :direction, :output
  
  def initialize(code, input = "")
    @code = code.lines.map(&:chomp) #keep a copy for later when we modify our own code!
    @code_position = Struct.new(:x, :y).new(0, 0)

    @input = input

    @stage = [0, 0]

    @memory = [0]
    @memory_position = 0

    @direction = ?>
    @output = ""
  end

  def stage_v(num)
    @stage << num
    @stage.delete_at 0
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
  
  def run_one_instruction
    if DIRECTIONS.include? get_code
      @direction = get_code
    elsif OPERANDS.include? get_code
      store @stage.first.send(get_code.to_sym, @stage.last)
    elsif get_code == ?!
      store ((@stage.last == 0) ? 1 : 0)
    elsif get_code == ?`
      store ((@stage.last > @stage.first) ? 1 : 0)
    elsif get_code == ?_
      @direction = ((get_value == 0) ? ?> : ?<)
    elsif get_code == ?|
      @direction = ((get_value == 0) ? ?v : ?^)
    elsif get_code == ?:
      stage_v(get_value)
    elsif get_code == ?=
      @stage.reverse!
    elsif get_code == ?$
      #future use
    elsif get_code == ?.
      @output << get_value
      move_mem_position_right
    elsif get_code == ?,
      @output << get_value.chr
      move_mem_position_right
    elsif get_code == ?&
      store @input.slice!(0).to_i unless @input.length == 0
      move_mem_position_right
    elsif get_code == ?~
      store @input.slice!(0).ord unless @input.length == 0
      move_mem_position_right
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
    elsif get_code == ?[ || get_code == ?]
      number = ""
      loop do
        #move first
        move(1)
        break if get_code == ?] || get_code == ?[
        number += get_code
      end
      store number.to_i
    elsif get_code == ?;
      store ((@input.length == 0) ? 1 : 0)
    elsif get_code == ??
      store ((@stack.length == 0) ? 1 : 0)
    elsif (?0..?9).include? get_code
      store get_code.to_i
      move_mem_position_right
    end

    move((get_code == ?#) ? 2 : 1)
    
    @output
  end
  
  def run
    until ended?
      run_one_instruction
    end
    @output
  end

  def run_from_beginning
    @input = @original_input
    @stack = []
    @position = Struct.new(:x, :y).new(0, 0)
    @direction = ?>
    @output = ""
    @current_code = @code
    run
  end

  def ended?
    get_code == ?@
  end
end

#DELETE THESE

#puts Minifunge.new(%{0"!dlroW ,olleH">:#,_@}, "").run

#Has issues
#puts minifunge(%{~:1+!#@_,}, "TestTest TEST TEST 123456789!!!!")