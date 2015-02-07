require './rubyfunge_viewer.rb'
fibonacci =
    %q{8)1.]" ",1.]>+]" ",(.(([:$-w@} + "\n" +
        %q{            ^   ?)$?(:]))  <}
rv = RubyfungeViewer.new("fibonacci", fibonacci)
rv.run
rv.make_gif