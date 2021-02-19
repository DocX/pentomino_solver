require './lib/shapes_solver'
require './shapes/pentomino'

if (ARGV[0] == "--debug")
  DEBUG = true
  ARGV.slice!(0, 1)
end

if ARGV.empty?
  puts "ruby main.rb [--debug] problem_file.txt"
  exit 1
end

def solver_from_file(filename)
  content_lines = File.readlines(filename)
  shapes = content_lines[0].strip.split(",").flat_map { |shape_name| Pentomino.const_get(shape_name) }

  target = Shape.from_string(content_lines.drop(2).join)

  ShapesSolver.new(shapes, target)
end

solver = solver_from_file(ARGV.last)

puts "Shapes:"
puts solver.shapes.join("\n\n")

puts
puts "Target:"
puts solver.target.to_s

solution = solver.solve

puts
puts "Solution:"
puts solver.render_solution(solution).to_s
