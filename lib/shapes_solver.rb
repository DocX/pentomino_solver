require './lib/dfs_solver.rb'
require './lib/shape.rb'

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

    precomputed_placement_count = precompute_placements_count_at_target(@possible_placements)

    @possible_placements = @possible_placements
      .sort_by { |placement| placement_score @possible_placements, precomputed_placement_count, placement }
  end

  def initial_remaining_space
    possible_placements
  end

  # Get score of placement based on how "important" it is
  # determined by how many other possible placements can pixels
  # on that placement by satisfied. Lower possible other placements
  # mean higher importance
  def placement_score(placements, precomputed_counts, placement)
    placement[:shape].each_filled_pixel.map do |row, col|
      target_row = row + placement[:row]
      target_col = col + placement[:col]

      precomputed_counts[[target_row, target_col]]
    end.min
  end

  def precompute_placements_count_at_target(placements)
    counts_at_pixel = {}
    target.each_filled_pixel.each do |row, col, _|
      counts_at_pixel[[row, col]] = placements_at_target(placements, row, col).count
    end
    counts_at_pixel
  end

  def placements_at_target(placements, target_row, target_col)
    placements.select do |placement|
      placement[:shape].each_filled_pixel.any? do |row, col|
        placement_target_row = row + placement[:row]
        placement_target_col = col + placement[:col]

        target_row == placement_target_row && target_col == placement_target_col
      end
    end
  end

  def next_placement(solution, remaining_space)
    # Check if remaining space contains all remaining shapes
    placed_shapes_ids = solution.map { |placement| placement[:shape_id] }
    remaining_shapes_ids = (0 ... shapes.count).to_a - placed_shapes_ids
    return [nil, nil] unless remaining_shapes_ids.all? { |remaining_shape_id|
      remaining_space.any? { |placement| placement[:shape_id] == remaining_shape_id }
    }

    # Check if there are pixels that cannot be covered by any of the remaining placements
    return [nil, nil] unless target.each_filled_pixel.all? do |row, col, _|
      (solution + remaining_space).any? do |placement|
        placement[:shape].each_filled_pixel.any? do |p_row, p_col|
          p_row + placement[:row] == row && p_col + placement[:col] == col
        end
      end
    end

    # Lock each solution step to given shape id to avoid searching thru same space twice
    # as two identical sub-solutions could be computed when swapped shapes order
    # It is impossible to have two identical sub-solutions when shape is locked to each step
    current_shape_id = remaining_space.first[:shape_id]
    placement = remaining_space.find { |placement| placement[:shape_id] == current_shape_id }
    return [nil, nil] if placement.nil?

    next_solution = solution + [placement]
    next_space = remaining_space
      .select { |placement| placement[:shape_id] != current_shape_id }
      .select { |placement| valid_placement?(next_solution, placement) }

    [next_solution, next_space]
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
