# Immutable shape
class Shape
  def self.from_string(string, key: nil)
    lines = string.each_line
      .select { |line| !line.strip.empty? }
      .to_a

    left_padding = lines
      .map { |line| line.length - line.lstrip.length }
      .min

    lines = lines
      .map { |line| line.rstrip }
      .select { |line| line != "" }
      .map { |line| line[left_padding .. -1]}
      .select { |line| line != "" }

    raise "must be one or more non empty lines" unless lines.count > 0

    cols = lines.map { |line| line.length }.max
    raise "must not be empty" unless cols > 0

    pixels = lines.each_with_index.map do |line, row|
      Array.new(cols) do |col|
        case line[col]
        when nil, " "
          nil
        else
          key ||= line[col]
          "█"
        end
      end
    end

    Shape.new(lines.size, lines[0].chomp.size, pixels, key: key)
  end

  attr_reader :key

  def initialize(rows, cols, field, key:)
    raise "must be non zero area" unless rows > 0 && cols > 0
    @field = field
    @key = key
  end

  def read(row, col)
    @field[row][col]
  end

  def rows
    @field.size
  end

  def cols
    @field[0].size
  end

  def size
    [rows, cols]
  end

  def each_pixel
    return @each_pixel if @each_pixel

    @each_pixel = rows.times.flat_map do |row|
      cols.times.map do |col|
        [row, col, @field[row][col]]
      end
    end
  end

  def each_filled_pixel
    @each_filled_pixel ||= each_pixel
      .select { |row, col, val| !val.nil? }
      .map { |row, col, _| [row, col] }
  end

  def each_filled_pixel_with_val
    @each_filled_pixel_with_val ||= each_pixel.select { |row, col, val| !val.nil? }
  end

  def rotate_clockwise
    # first row to last col
    rotated = Array.new(cols) { Array.new(rows) }

    @field.each_with_index do |row, row_i|
      row.each_with_index do |point, col_i|
        rotated[col_i][rows - row_i - 1] = point
      end
    end

    Shape.new(cols, rows, rotated, key: @key)
  end

  def flip
    # flip rows
    flipped = Array.new(rows) { Array.new(cols) }

    @field.each_with_index do |row, row_i|
      row.each_with_index do |point, col_i|
        flipped[rows - row_i - 1][col_i] = point
      end
    end

    Shape.new(rows, cols, flipped, key: @key)
  end

  def cover?(other)
    return false unless other.size == size

    @field.each_with_index.all? do |row, row_i|
      row.each_with_index.all? do |point, col_i|
        other_point = other.read(row_i, col_i)

        point.nil? ? other_point.nil? : !other_point.nil?
      end
    end
  end

  def eql?(other)
    return false unless other.size == size

    @field.each_with_index.all? do |row, row_i|
      row.each_with_index.all? do |point, col_i|
        other_point = other.read(row_i, col_i)

        point.nil? == other_point.nil?
      end
    end
  end

  def hash
    @field.map { |row| row.hash }.hash
  end

  def to_s
    render("█")
  end

  def render(character)
    @field.map do |row|
      row.map { |point| point.nil? ? " " : character }.join("")
    end.join("\n")
  end

  # Enumerate all unique orientation (rotation/flip)
  def uniq_orientations
    return @uniq_orientations unless@uniq_orientations.nil?

    rotated_1 = self.rotate_clockwise
    rotated_2 = rotated_1.rotate_clockwise
    rotated_3 = rotated_2.rotate_clockwise
    flipped_0 = self.flip
    flipped_1 = flipped_0.rotate_clockwise
    flipped_2 = flipped_1.rotate_clockwise
    flipped_3 = flipped_2.rotate_clockwise

    @uniq_orientations = [
      self,
      rotated_1,
      rotated_2,
      rotated_3,
      flipped_0,
      flipped_1,
      flipped_2,
      flipped_3
    ].uniq
  end

  # Calculate positions of other_shape placed on top of this shape so
  # it covers it completely
  # Returns list of [{row, col}, ...]
  def all_placements(other_shape)
    result = (rows - other_shape.rows + 1).times.flat_map do |row|
      (cols - other_shape.cols + 1).times.map do |col|
        if contains_at?(other_shape, row, col)
          [row, col]
        else
          nil
        end
      end
    end

    result.compact
  end

  # Determines if this shape fully contains given shape at given position
  # If given shape has pixes outside this shape, it does not contain it
  def contains_at?(shape, row, col)
    shape.each_filled_pixel.all? do |other_row, other_col|
      !read(other_row + row, other_col + col).nil?
    end
  end
end
