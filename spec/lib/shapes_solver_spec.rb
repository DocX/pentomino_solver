require 'lib/shapes_solver'

RSpec.describe ShapesSolver do
  def solution_to_string(solution)
    picture = Array.new(target.rows) { " " * target.cols }
    solution.each do |placement|
      placement.shape.each_filled_pixel_with_val.each do |row, col, val|
        picture[row + placement.row][col + placement.col] = placement.shape.key
      end
    end
    picture.join("\n")
  end

  let(:shapes) do
    [
      Shape.from_string(%{
        aaa
        a
        a
      }),
      Shape.from_string(%{
        b
        b
        b
      }),
      Shape.from_string(%{
        cc
        cc
      })
    ]
  end

  let(:target) do
    Shape.from_string(%{
      xxx
      xxx
      xxx
      xxx
    })
  end

  let(:solver) { ShapesSolver.new(shapes, target) }

  describe "#solve" do
    it "solves the shapes placement" do
      solution = solver.solve

      expected = [
        "bbb",
        "aaa",
        "acc",
        "acc",
      ].join("\n")

      expect(solution_to_string(solution)).to eq expected
    end
  end

  describe "#next_placement" do
    it "is first placement when solution empty" do
      solution, remaining_space = solver.next_placement([], solver.initial_remaining_space)
      expect(solution.last).to eq solver.possible_placements.first
      expect(remaining_space.map { |s| solver.possible_placements.find_index s }).to eq [1, 8, 11, 14, 18, 20]

      solution, remaining_space = solver.next_placement(solution, remaining_space)
      expect(solution.last).to eq solver.possible_placements[1]
      expect(remaining_space.map { |s| solver.possible_placements.find_index s }).to eq [14]
    end
  end

  describe "#valid_placement?" do
    it "is always valid when solution is empty" do
      placement = {} # bogus placement should not affect result

      valid = solver.valid_placement?([], placement)
      expect(valid).to eq true
    end

    it "is false when solution contains same placement" do
      solution = [solver.possible_placements.first]
      placement = solver.possible_placements.first

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq false
    end

    xit "is false when solution contains same shape_id" do
      solution = [solver.possible_placements[0]]
      placement = solver.possible_placements[1]

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq false
    end

    xit "is false when it overlaps" do
      solution = [solver.possible_placements[0]]
      # See below what is 8th possible placement
      placement = solver.possible_placements[8]

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq false
    end

    xit "is true when it does not overlap" do
      solution = [solver.possible_placements[0]]
      # See below in list of possible placements
      placement = solver.possible_placements[12]

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq true
    end
  end

  describe "#possible_placements" do
    it "contains exactly all possible placements" do
      possible_placements_readable = StringIO.new
      solver.possible_placements.each do |placement|
        possible_placements_readable.puts "#{placement.shape_id}, #{placement.row}, #{placement.col}:"
        possible_placements_readable.puts placement.shape
        possible_placements_readable.puts
      end

      path = File.join(__dir__, "__snapshots__", "possible_placements.txt")
      File.write(path, possible_placements_readable.string) if ENV["RSPEC_UPDATE_SNAPSHOTS"] == "true" || !File.exist?(path)
      expect(possible_placements_readable.string).to eq File.read(path)
    end
  end
end
