require './rubyfunge_viewer.rb'
rv = RubyfungeViewer.new("cat", %q{>~= ,= ;= _@}, "Testing testing 123")
rv.run
rv.make_gif