require 'yaml'
require 'optparse'
require 'rainbow'
require 'lib/shapes_solver'
require 'lib/shape'

module PentominoSolver
  def self.execute
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: main.rb --shapes shapes.yml --target target.txt"

      opts.on("-d", "--debug", "Toggle debug output") do |d|
        options[:debug] = d
      end

      opts.on("-s", "--shapes SHAPES", "Required SHAPES definition file") do |s|
        options[:shapes_file] = s
      end

      opts.on("-t", "--target TARGET", "Required TARGET definition file") do |t|
        options[:target_file] = t
      end
    end
    parser.parse!

    unless options[:shapes_file] && options[:target_file]
      puts parser.help
      exit 1
    end

    available_shapes = load_shapes(options[:shapes_file])
    shapes, target = load_target(options[:target_file], available_shapes)

    solver = ShapesSolver.new(shapes, target)
    solver.debug = options[:debug]

    puts "Shapes:"
    puts solver.shapes.map { |s| s.render(shape_console_char(s)) }.join("\n\n")
    puts ""

    puts "Target:"
    puts solver.target.to_s
    puts ""

    solution = solver.solve
    puts "Solution:"
    puts render_solution(solver.target, solution).to_s
    puts ""
  end

  def self.load_target(target_path, available_shapes)
    target_yaml = File.read(target_path)
    target = YAML.load(target_yaml)

    shapes = available_shapes.select { |shape| target["shapes_to_use"].include? shape.key }

    [shapes, Shape.from_string(target["target"], key: "?")]
  end

  def self.load_shapes(shapes_path)
    shapes_yaml = File.read(shapes_path)
    shapes_definitions = YAML.load(shapes_yaml)

    shapes_definitions["shapes"].map do |shape|
      Shape.from_string(shape["shape"].gsub(".", " "), key: shape["key"])
    end
  end

  def self.render_solution(target, solution)
    picture = Array.new(target.rows) { Array.new(target.cols) }
    solution.each do |placement|
      placement.shape.each_filled_pixel_with_val.each do |row, col, val|
        picture[row + placement.row][col + placement.col] = shape_console_char(placement.shape)
      end
    end

    picture.map do |row|
      row.map { |p| p.nil? ? " " : p }.join("")
    end.join("\n")
  end

  def self.shape_console_char(shape)
    color = shape.key.hash % 8
    Rainbow(shape.key).bg(color)
  end
end