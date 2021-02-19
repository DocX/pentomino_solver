require './lib/shapes_solver'
require './shapes/pentomino'

DEBUG = true

# solver = ShapesSolver.new(
#   Pentomino::ALL_12,
#   Shape.from_string(%{
#     O   O
#     OO OO
#     OOOOO
#     O O O
#     OOOOO
#      OOO
#       O
#      OOO
#     OOOOO
#     OOOOO
#     OOOOOO   O
#     OOOOOOOOOO
#      OOOOOOO
#   })
# )

solver = ShapesSolver.new(
  [Pentomino::Y, Pentomino::L, Pentomino::U, Pentomino::V, Pentomino::I],
  Shape.from_string(%{
    KKKKK
    KKKKK
    KKKKK
    KKKKK
    KKKKK
  })
)

puts "Shapes:"
puts solver.shapes.join("\n\n")

puts
puts "Target:"
puts solver.target.to_s

solution = solver.solve

puts
puts "Solution:"
puts solver.render_solution(solution).to_s
