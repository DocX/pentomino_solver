require './lib/shapes_solver.rb'
require './shapes/pentomino.rb'

if RUBY_ENGINE == "opal"
  argv = %x{ process.argv.slice(2) }
else
  argv = ARGV
end

debug = false

if argv[0] == "--debug"
  debug = true
  argv = argv[1..-1]
end

if argv.empty?
  puts "main [--debug] problem_file.txt"

  if RUBY_ENGINE == "opal"
    %x{process.exit(1)}
  else
    exit 1
  end
end

def solver_from_file(filename)
  content = ""
  if RUBY_ENGINE == "opal"
    fs = %x{ require("fs") }
    content = %x{ fs.readFileSync(filename, "utf8") }
  else
    content = File.read(filename)
  end

  content_lines = content.each_line.to_a
  shapes = content_lines[0].strip.split(",").flat_map { |shape_name| Pentomino.const_get(shape_name) }

  target = Shape.from_string(content_lines.drop(2).join)

  ShapesSolver.new(shapes, target)
end

def solve(debug, filename)
  solver = solver_from_file filename
  solver.debug = debug

  puts "Shapes:"
  puts solver.shapes.join("\n\n")
  puts ""

  puts "Target:"
  puts solver.target.to_s
  puts ""

  solution = solver.solve
  puts "Solution:"
  puts solver.render_solution(solution).to_s
  puts ""
end

argv.each do |filename|
  puts "Filename: #{filename}"
  puts ""
  solve debug, filename
end
