require 'rspec'
require_relative '../rubyfunge.rb'

RSpec.describe Rubyfunge do
  it "should end the program (@)" do
    r = Rubyfunge.new("@")
    r.run
    expect(r.ended?).to eq true

    r = Rubyfunge.new("  @")
    r.run
    expect(r.ended?).to eq true

    r = Rubyfunge.new("       @")
    r.run
    expect(r.ended?).to eq true
  end

  it "should change directions (<>v^)" do
    code = <<END
v@<
> ^
END
    r = Rubyfunge.new(code)
    expect(r.main.direction).to eq ?>
    r.run_one_instruction
    expect(r.main.direction).to eq ?v
    r.run_one_instruction
    expect(r.main.direction).to eq ?>
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.direction).to eq ?^
    r.run_one_instruction
    expect(r.main.direction).to eq ?<
    r.run_one_instruction
    expect(r.ended?).to eq true
  end

  it "should store numbers into current memory (0..9)" do
    r = Rubyfunge.new("123456789@")
    r.run_one_instruction
    expect(r.main.get_value).to eq 1
    r.run_one_instruction
    expect(r.main.get_value).to eq 2
    r.run_one_instruction
    expect(r.main.get_value).to eq 3
    r.run_one_instruction
    expect(r.main.get_value).to eq 4
    r.run_one_instruction
    expect(r.main.get_value).to eq 5
    r.run_one_instruction
    expect(r.main.get_value).to eq 6
    r.run_one_instruction
    expect(r.main.get_value).to eq 7
    r.run_one_instruction
    expect(r.main.get_value).to eq 8
    r.run_one_instruction
    expect(r.main.get_value).to eq 9
    r.run_one_instruction
    expect(r.ended?).to eq true
  end

  it "should jump over instructions with (=)" do
    r = Rubyfunge.new "1=2 @"
    r.run_one_instruction
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.get_value).to eq 1
  end

  it "should stage numbers with (:)" do
    r = Rubyfunge.new "1:2:@"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.stage_b).to eq 1
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.stage_a).to eq 1
    expect(r.main.stage_b).to eq 2
  end

  it "should add(+) numbers in stage" do
    r = Rubyfunge.new "1:2:+3:4:+@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 3
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 7
  end

  it "should subtract(-) numbers in stage" do
    r = Rubyfunge.new "4:3:-2:1:-9:4:-3:9:-@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 5
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq -6
  end

  it "should multiply(*) numbers in stage" do
    r = Rubyfunge.new "4:3:*2:1:*9:0:*3:9:*@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 12
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 2
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 27
  end

  it "should divide(/) numbers in stage" do
    r = Rubyfunge.new "4:2:/2:1:/9:4:/9:3:/@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 2
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 2
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 2
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 3
  end

  it "should modulo(%) numbers in stage" do
    r = Rubyfunge.new "4:2:%2:1:%9:4:%3:8:%@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 3
  end

  it "should move memory position ()" do
    r = Rubyfunge.new "())3(2(1)())@"
    r.run_one_instruction
    expect(r.main.memory.length).to eq 2
    expect(r.main.get_value).to eq 0
    expect(r.main.memory_position).to eq 0
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 0
    expect(r.main.memory_position).to eq 2
    5.times {r.run_one_instruction}
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 1
    expect(r.main.memory_position).to eq 0
    r.run_one_instruction
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 2
    expect(r.main.memory_position).to eq 1
    r.run_one_instruction
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 1
    expect(r.main.memory_position).to eq 0
    r.run_one_instruction
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 2
    expect(r.main.memory_position).to eq 1
    r.run_one_instruction
    expect(r.main.memory.length).to eq 3
    expect(r.main.get_value).to eq 3
    expect(r.main.memory_position).to eq 2
  end

  it "should move memory position get_value times (l r)" do
    r = Rubyfunge.new "1r2r3r3l2l1l@"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 1
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 3
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 6
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 3
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 1
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.memory_position).to eq 0
  end

  it "should store stage_b in current memory (?)" do
    r = Rubyfunge.new "7:)?8:(?@"
    4.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 7
    4.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 8
  end

  it "should store integer with (\')" do
    r = Rubyfunge.new %q{'123''4567'@}
    r.run_one_instruction
    expect(r.main.get_value).to eq 123
    r.run_one_instruction
    expect(r.main.get_value).to eq 4567
  end

  it "should store integer with (\")" do
    r = Rubyfunge.new %q{"Hello, world!"@}
    r.run_one_instruction
    expect(r.main.get_value).to eq ?H.ord
    expect(r.main.memory[1]).to eq ?e.ord
    expect(r.main.memory[2]).to eq ?l.ord
    expect(r.main.memory[3]).to eq ?l.ord
    expect(r.main.memory[4]).to eq ?o.ord
    expect(r.main.memory[5]).to eq ?,.ord
    expect(r.main.memory[6]).to eq ' '.ord
    expect(r.main.memory[7]).to eq ?w.ord
    expect(r.main.memory[8]).to eq ?o.ord
    expect(r.main.memory[9]).to eq ?r.ord
    expect(r.main.memory[10]).to eq ?l.ord
    expect(r.main.memory[11]).to eq ?d.ord
    expect(r.main.memory[12]).to eq ?!.ord
  end

  it "should store stage_b into memory (?)" do
    r = Rubyfunge.new "4:)?@"
    r.run_one_instruction
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.get_value).to eq 0
    r.run_one_instruction
    expect(r.main.get_value).to eq 4
  end

  it "should stage and move memory position with []" do
    r = Rubyfunge.new "4]5]6]7]@"
    2.times { r.run_one_instruction }
    expect(r.main.stage_b).to eq 4
    2.times { r.run_one_instruction }
    expect(r.main.stage_b).to eq 5
    2.times { r.run_one_instruction }
    expect(r.main.stage_b).to eq 6
    2.times { r.run_one_instruction }
    expect(r.main.stage_b).to eq 7
  end

  it "swap stage_a and stage_b values with ($)" do
    r = Rubyfunge.new "1:2:$@"
    4.times {r.run_one_instruction}
    expect(r.main.stage_a).to eq 1
    expect(r.main.stage_b).to eq 2
    r.run_one_instruction
    expect(r.main.stage_a).to eq 2
    expect(r.main.stage_b).to eq 1
  end

  it "Should output integer in memory with (.)" do
    r = Rubyfunge.new "4.5.6.7.@"
    2.times {r.run_one_instruction}
    expect(r.output).to eq "4"
    2.times {r.run_one_instruction}
    expect(r.output).to eq "45"
    2.times {r.run_one_instruction}
    expect(r.output).to eq "456"
    2.times {r.run_one_instruction}
    expect(r.output).to eq "4567"
  end

  it "Should output character in memory with (,)" do
    r = Rubyfunge.new %q{"Hello, World! ",),),),),),),),),),),),),)@}
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "H"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "He"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hel"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hell"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello,"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, "
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, W"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, Wo"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, Wor"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, Worl"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, World"
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "Hello, World!"
  end

  it "should output character in memory and move with {}" do
    r = Rubyfunge.new %q{"Hello, World! "\}\}\}\}\}\}\}\}\}\}\}\}\}@}
    r.run_one_instruction
    r.run_one_instruction
    expect(r.output).to eq "H"
    r.run_one_instruction
    expect(r.output).to eq "He"
    r.run_one_instruction
    expect(r.output).to eq "Hel"
    r.run_one_instruction
    expect(r.output).to eq "Hell"
    r.run_one_instruction
    expect(r.output).to eq "Hello"
    r.run_one_instruction
    expect(r.output).to eq "Hello,"
    r.run_one_instruction
    expect(r.output).to eq "Hello, "
    r.run_one_instruction
    expect(r.output).to eq "Hello, W"
    r.run_one_instruction
    expect(r.output).to eq "Hello, Wo"
    r.run_one_instruction
    expect(r.output).to eq "Hello, Wor"
    r.run_one_instruction
    expect(r.output).to eq "Hello, Worl"
    r.run_one_instruction
    expect(r.output).to eq "Hello, World"
    r.run_one_instruction
    expect(r.output).to eq "Hello, World!"
  end

  it "should store input character as integer (&)" do
    r = Rubyfunge.new "&&&@", "123"
    r.run_one_instruction
    expect(r.input).to eq "23"
    expect(r.main.get_value).to eq 1
    r.run_one_instruction
    expect(r.input).to eq "3"
    expect(r.main.get_value).to eq 2
    r.run_one_instruction
    expect(r.input).to eq ""
    expect(r.main.get_value).to eq 3
  end

  it "should store input character as character (~)" do
    r = Rubyfunge.new "~~~@", "123"
    r.run_one_instruction
    expect(r.input).to eq "23"
    expect(r.main.get_value).to eq ?1.ord
    r.run_one_instruction
    expect(r.input).to eq "3"
    expect(r.main.get_value).to eq ?2.ord
    r.run_one_instruction
    expect(r.input).to eq ""
    expect(r.main.get_value).to eq ?3.ord
  end

  it "should store 0 or 1 if there is still input to process (;)" do
    r = Rubyfunge.new ";@"
    r.run_one_instruction
    expect(r.main.get_value).to eq 0

    r = Rubyfunge.new ";@", "123"
    r.run_one_instruction
    expect(r.main.get_value).to eq 1

    r = Rubyfunge.new "~~;~;@", "123"
    r.run_one_instruction
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.get_value).to eq 1
    r.run_one_instruction
    r.run_one_instruction
    expect(r.main.get_value).to eq 0
  end

  it "should store 0 or 1 if stage_a > stage_b (`)" do
    r = Rubyfunge.new "4:3:`$`@"
    5.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
    2.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
  end

  it "should store 0 if stage_b is >= 0 or 1 if stage_b is < 0" do
    r = Rubyfunge.new "0:!1:!'-10':!8:!@"
    3.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
    3.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
    3.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 1
    3.times {r.run_one_instruction}
    expect(r.main.get_value).to eq 0
  end

  it "should store move up if store is > 0, down if store is <= 0 (|)" do
    r = Rubyfunge.new "v  @.<\n     5\n>    |\n     2\n   @.<"
    r.run
    expect(r.output).to eq "2"
    r = Rubyfunge.new "v  @.<\n     5\n> 1  |\n     2\n   @.<"
    r.run
    expect(r.output).to eq "5"
    r = Rubyfunge.new "v   @.<\n      5\n>1:4:-|\n      2\n    @.<"
    r.run
    expect(r.output).to eq "2"
    r = Rubyfunge.new "v  @.<\n     5\n> 9  |\n     2\n   @.<"
    r.run
    expect(r.output).to eq "5"
  end

  it "should store move left if store is > 0, right if store is <= 0 (_)" do
    r = Rubyfunge.new "   v\n@.2_3.@"
    r.run
    expect(r.output).to eq "3"

    r = Rubyfunge.new "1  v\n@.2_3.@"
    r.run
    expect(r.output).to eq "2"

    r = Rubyfunge.new "5  v\n@.2_3.@"
    r.run
    expect(r.output).to eq "2"

    r = Rubyfunge.new "1:9:-v\n  @.2_3.@"
    r.run
    expect(r.output).to eq "3"
  end

  it "should follow (w, s, e) pipe (w)" do
    top_test =
        ">  v   " + "\n" +
        "@.1w3.@" + "\n" +
        "   2   " + "\n" +
        "   .   " + "\n" +
        "   @   " + "\n"

    r = Rubyfunge.new top_test
    5.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?^

    w_test_1 =
        " w2 @" + "\n" +
        " >1 @" + "\n"
    r = Rubyfunge.new w_test_1
    3.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?>
    expect(r.main.get_value).to eq 2

    w_test_2 =
        "1w1 @" + "\n" +
        " >2 @" + "\n"
    r = Rubyfunge.new w_test_2
    4.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?>
    expect(r.main.get_value).to eq 2

    s_test_1 =
        "v@.1w2.@" + "\n" +
        ">   ^" + "\n"
    r = Rubyfunge.new s_test_1
    8.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?<
    expect(r.main.get_value).to eq 1

    s_test_2 =
        "v@.1w2.@" + "\n" +
        ">1  ^" + "\n"
    r = Rubyfunge.new s_test_2
    8.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?>
    expect(r.main.get_value).to eq 2

    e_test_1 =
        "   v" + "\n" +
        "@1w<" + "\n" +
        "@2< " + "\n"
    r = Rubyfunge.new e_test_1
    8.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?<
    expect(r.main.get_value).to eq 2

    e_test_2 =
        "1  v" + "\n" +
        "@1w<" + "\n" +
        "@2< " + "\n"
    r = Rubyfunge.new e_test_2
    7.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?<
    expect(r.main.get_value).to eq 1
  end

  it "should follow (w, n ,e) pipe (x)" do
    s_test_1 =
        "vx" + "\n" +
        "v " + "\n" +
        "v@" + "\n" +
        "v=" + "\n" +
        ">^" + "\n"
    r = Rubyfunge.new s_test_1
    9.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?v

    w_test_1 =
        "v>2.@" + "\n" +
        ">x1.@" + "\n"
    r = Rubyfunge.new w_test_1
    r.run
    expect(r.output).to eq "2"

    w_test_2 =
        "v >2.@" + "\n" +
        ">1x1.@" + "\n"
    r = Rubyfunge.new w_test_2
    r.run
    expect(r.output).to eq "1"

    e_test_1 =
        ">   v" + "\n" +
        "@.1< " + "\n" +
        "@.2x<" + "\n"
    r = Rubyfunge.new e_test_1
    r.run
    expect(r.output).to eq "2"

    e_test_2 =
        "> 1 v" + "\n" +
        "@.1< " + "\n" +
        "@.2x<" + "\n"
    r = Rubyfunge.new e_test_2
    r.run
    expect(r.output).to eq "1"

    n_test_1 =
        ">  v" + "\n" +
        "@.1x2.@" + "\n"
    r = Rubyfunge.new n_test_1
    r.run
    expect(r.output).to eq "2"

    n_test_2 =
        ">1 v" + "\n" +
        "@.1x2.@" + "\n"
    r = Rubyfunge.new n_test_2
    r.run
    expect(r.output).to eq "1"
  end

  it "should follow (n, e, s) pipe (y)" do
    n_test_1 =
        "v   " + "\n" +
        "y1.@" + "\n" +
        ">2.@" + "\n"
    r = Rubyfunge.new n_test_1
    r.run
    expect(r.output).to eq ?1

    n_test_2 =
        "v   " + "\n" +
        "1   " + "\n" +
        "y1.@" + "\n" +
        ">2.@" + "\n"
    r = Rubyfunge.new n_test_2
    r.run
    expect(r.output).to eq ?2

    e_test_1 =
        ">    v" + "\n" +
        " >1.@ " + "\n" +
        " y   <" + "\n" +
        " >2.@ " + "\n"
    r = Rubyfunge.new e_test_1
    r.run
    expect(r.output).to eq ?2

    e_test_2 =
        ">1   v" + "\n" +
        " >1.@ " + "\n" +
        " y   <" + "\n" +
        " >2.^ " + "\n"
    r = Rubyfunge.new e_test_2
    r.run
    expect(r.output).to eq ?1

    w_test_1 = ">=@y"
    r = Rubyfunge.new w_test_1
    3.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?<

    s_test_1 =
        "v@@" + "\n" +
        " .." + "\n" +
        " 12" + "\n" +
        " y^" + "\n" +
        ">^" + "\n"
    r = Rubyfunge.new s_test_1
    r.run
    expect(r.output).to eq ?1

    s_test_1 =
        "v@@" + "\n" +
        "1.." + "\n" +
        " 12" + "\n" +
        " y^" + "\n" +
        ">^" + "\n"
    r = Rubyfunge.new s_test_1
    r.run
    expect(r.output).to eq ?2
  end

  it "should follow (w, n ,s) pipe (z)" do
    n_test_1 =
        "   v" + "\n" +
        "@.1z" + "\n" +
        "@.2<" + "\n"
    r = Rubyfunge.new n_test_1
    r.run
    expect(r.output).to eq ?2

    n_test_2 =
        "1  v" + "\n" +
        "@.1z" + "\n" +
        "@.2<" + "\n"
    r = Rubyfunge.new n_test_2
    r.run
    expect(r.output).to eq ?1

    w_test_1 =
        "v@.1<" + "\n" +
        ">   z" + "\n" +
        " @.2<" + "\n"
    r = Rubyfunge.new w_test_1
    r.run
    expect(r.output).to eq ?1

    w_test_2 =
        "v@.1<" + "\n" +
        "> 1 z" + "\n" +
        " @.2<" + "\n"
    r = Rubyfunge.new w_test_2
    r.run
    expect(r.output).to eq ?2

    s_test_1 =
        "v@.1<" + "\n" +
        " @.2z" + "\n" +
        ">   ^" + "\n"
    r = Rubyfunge.new s_test_1
    r.run
    expect(r.output).to eq ?2

    s_test_2 =
        "v@.1<" + "\n" +
        " @.2z" + "\n" +
        "> 1 ^" + "\n"
    r = Rubyfunge.new s_test_2
    r.run
    expect(r.output).to eq ?1

    e_test_1 =
        ">   v" + "\n" +
        "z @=<" + "\n"
    r = Rubyfunge.new e_test_1
    10.times {r.run_one_instruction}
    expect(r.main.direction).to eq ?>
  end

  it "should produce Hello, world" do
    r = Rubyfunge.new %q!"Hello, world">}= _@!
    r.run
    expect(r.output).to eq "Hello, world"
  end

  it "should produce output from input" do
    r = Rubyfunge.new %q{>~= ,= ;= _@}, "Hello, world!"
    r.run
    expect(r.output).to eq "Hello, world!"

    r = Rubyfunge.new %q{>~= ,= ;= _@}, "Testing Testing 123"
    r.run
    expect(r.output).to eq "Testing Testing 123"
  end

  it "should produce a factorial" do
    factorial =
        "5]1]>*([:$-w)).@" + "\n" +
        "    ^  :)):<"
    r = Rubyfunge.new factorial
    r.run
    expect(r.output).to eq "120"

    factorial =
        "9]1]>*([:$-w)).@" + "\n" +
            "    ^  :)):<"
    r = Rubyfunge.new factorial
    r.run
    expect(r.output).to eq "362880"
  end

  it "should produce a fibonacci sequence" do
    fibonacci =
        %q{8)1.]" ",1.]>+]" ",(.(([:$-w@} + "\n" +
        %q{            ^   ?)$?(:]))  <} + "\n"
    r = Rubyfunge.new fibonacci
    r.run
    expect(r.output).to eq "1 1 2 3 5 8 13 21 34 55"
  end
end