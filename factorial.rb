require './rubyfunge_viewer.rb'

factorial =
    "9]1]>*([:$-w)).@" + "\n" +
        "    ^  :)):<"
rv = RubyfungeViewer.new("factorial", factorial)
rv.run
rv.make_gif