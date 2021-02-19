require './lib/dfs_solver'
require './lib/shape'

class ShapesSolver < DFSSolver
  # initialize with list of all possible placements
  # { [{ shape_id, shape, row, col }, ...] }

  # each step in solution is one of the possible placements
  # [ { shape_id, shape, row, col } ]

  attr_reader :target_picture, :shapes, :target

  def initialize(shapes, target)
    @target = target
    @shapes = shapes
  end

  def possible_placements
    return @possible_placements if @possible_placements

    @possible_placements = []

    @shapes.each_with_index do |shape, shape_id|
      shape.uniq_orientations.each do |shape_orientation|
        all_placements = target.all_placements(shape_orientation)

        all_placements.each do |row, col| 
          @possible_placements << { 
            shape_id: shape_id, 
            shape: shape_orientation, 
            row: row, 
            col: col 
          }
        end
      end
    end

    @possible_placements
  end

  def next_placement(solution, last)
    valid_next_placements(solution)
      .drop_while { |placement| !last.nil? && !placement.equal?(last) }
      .select { |placement| !placement.equal?(last) }
      .first
  end

  def valid_next_placements(solution)
    current_shape_id = solution.count

    possible_placements.lazy.select do |placement|
      placement[:shape_id] == current_shape_id &&
      valid_placement?(solution, placement)
    end
  end

  # Valid placement is one that does not cover already placed shapes
  # And is not a shape that is already placed
  def valid_placement?(solution, placement)
    # exclude already placed shapes
    return false if solution.any? { |s| s[:shape_id] == placement[:shape_id]}

    # any existing placements overlaps this placement?
    return false if solution.any? do |s|
      relative_row = placement[:row] - s[:row]
      relative_col = placement[:col] - s[:col]

      s[:shape].overlapped_by?(placement[:shape], relative_row, relative_col)
    end

    true
  end

  def completed?(solution)
    solution.count == shapes.count
  end

  def render_solution(solution)
    picture = Array.new(target.rows) { Array.new(target.cols) }
    solution.each do |placement|
      placement[:shape].each_filled_pixel.each do |row, col, val|
        picture[row + placement[:row]][col + placement[:col]] = val
      end
    end

    Shape.new(target.rows, target.cols, picture)
  end
end