require './lib/shapes_solver'

RSpec.describe ShapesSolver do
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
      solution_text = solver.render_solution(solution).to_s
      expected = [
        "aaa",
        "acc",
        "acc",
        "bbb",
      ].join("\n")

      expect(solution_text).to eq expected
    end
  end

  describe "#next_placement" do
    it "is first placement when solution empty" do
      solution, remaining_space = solver.next_placement([], solver.initial_remaining_space)
      expect(solution.last).to eq solver.possible_placements.first
      expect(remaining_space.map { |s| solver.possible_placements.find_index s }).to eq [12, 13, 15, 19, 23]

      solution, remaining_space = solver.next_placement(solution, remaining_space)
      expect(solution.last).to eq solver.possible_placements[12]
      expect(remaining_space.map { |s| solver.possible_placements.find_index s }).to eq []
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

    it "is false when solution contains same shape_id" do
      solution = [solver.possible_placements[0]]
      placement = solver.possible_placements[1]

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq false
    end

    it "is false when it overlaps" do
      solution = [solver.possible_placements[0]]
      # See below what is 8th possible placement
      placement = solver.possible_placements[8]

      valid = solver.valid_placement?(solution, placement)
      expect(valid).to eq false
    end

    it "is true when it does not overlap" do
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
        possible_placements_readable.puts "#{placement[:shape_id]}, #{placement[:row]}, #{placement[:col]}:"
        possible_placements_readable.puts placement[:shape]
        possible_placements_readable.puts
      end

      expected_possible_placements = %{0, 0, 0:
aaa
a..
a..

0, 1, 0:
aaa
a..
a..

0, 0, 0:
aaa
..a
..a

0, 1, 0:
aaa
..a
..a

0, 0, 0:
..a
..a
aaa

0, 1, 0:
..a
..a
aaa

0, 0, 0:
a..
a..
aaa

0, 1, 0:
a..
a..
aaa

1, 0, 0:
b
b
b

1, 0, 1:
b
b
b

1, 0, 2:
b
b
b

1, 1, 0:
b
b
b

1, 1, 1:
b
b
b

1, 1, 2:
b
b
b

1, 0, 0:
bbb

1, 3, 0:
bbb

2, 0, 0:
cc
cc

2, 0, 1:
cc
cc

2, 2, 0:
cc
cc

2, 2, 1:
cc
cc

1, 1, 0:
bbb

1, 2, 0:
bbb

2, 1, 0:
cc
cc

2, 1, 1:
cc
cc

}

      expect(possible_placements_readable.string).to eq expected_possible_placements
    end
  end
end
