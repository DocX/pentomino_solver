require './lib/shape'

RSpec.describe Shape do 
  describe ".from_string" do
    let(:unpadded) do
      Shape.from_string(
        "a  \n" +
        "aaa\n" +
        "  a\n"
      )
    end

    it "loads correctly from unpadded string" do 
      expect(unpadded.read(0,0)).to eq "a"
      expect(unpadded.read(2,2)).to eq "a" 
      expect(unpadded.read(0,2)).to be_nil
      expect(unpadded.read(1,2)).to eq "a"
    end

    it "loads correctly from padded string" do
      padded = Shape.from_string(%{
        a
        aaa
          a
      })

      expect(padded).to eql unpadded
    end
  end
end

a = Shape.from_string(
  "aaaa\n" + 
  "a  a\n" +
  "a  a\n" +
  "aaaa\n"
)

b = Shape.from_string(
  "bbbc\n" +
  "b  c\n" + 
  "a  c\n" +
  "aaaa\n"
)

c = Shape.from_string(
  "bb\n" +
  "bb\n"
)

d = Shape.from_string(
  "aaaa\n" +
  "a  a\n" +
  "a   \n" +
  "aaaa\n"
)

e = Shape.from_string(
  "azxy\n" +
  "b   \n" + 
  "c   \n" + 
  "d u \n"
)

e_rotated = Shape.from_string(
  "dcba\n" +
  "   z\n" + 
  "u  x\n" + 
  "   y\n"
)

raise "eql? error" unless a.eql? a
raise "eql? error" unless !a.eql? b
raise "a.size != [4,4]" unless a.size == [4,4]
raise "a expected to cover b" unless a.covers? b
raise "b expected to cover a" unless b.covers? a
raise "a expected to not cover c" unless !a.covers? c
raise "c expected to not cover a" unless !c.covers? a
raise "d expected to not cover a" unless !d.covers? a
raise "a expected to not cover d" unless !a.covers? d
puts "ok: shape#covers?"


# rotate_clockwise
raise "error:\n#{e.rotate_clockwise}\n!=\n#{e_rotated}" unless e.rotate_clockwise.covers? e_rotated
puts "ok: shape#rotate_clockwise"


# flip
no_symmetry = Shape.from_string(
  " aa\n" +
  "aa \n" +
  " a \n"
)

no_symmetry_flipped = Shape.from_string(
  " a \n" +
  "aa \n" +
  " aa\n"
)

raise "not expected flipped:\n#{no_symmetry.flip}" unless no_symmetry.flip.eql? no_symmetry_flipped
puts "ok: shape#flip"


# uniq_orientations
raise "should be 8 unique orientations" unless no_symmetry.uniq_orientations.count == 8

rot_and_flip_symmetry = Shape.from_string(
  "aaaaa\n"
)

raise "should be 2 unique orientations" unless rot_and_flip_symmetry.uniq_orientations.count == 2

flip_symmetry = Shape.from_string(
  "aaa\n" +
  "a  \n" +
  "a  \n"
)

raise "should be 4 unique orientations" unless flip_symmetry.uniq_orientations.count == 4

puts "ok: shape#uniq_orientations"


# each_pixel
e_each_pixel = e.each_pixel.to_a
e_each_pixel_expected = [
  [0, 0, "a"], [0, 1, "z"], [0, 2, "x"], [0, 3, "y"],
  [1, 0, "b"], [1, 1, nil], [1, 2, nil], [1, 3, nil],
  [2, 0, "c"], [2, 1, nil], [2, 2, nil], [2, 3, nil],
  [3, 0, "d"], [3, 1, nil], [3, 2, "u"], [3, 3, nil],
]
raise "each_pixel should have each pixel" unless e_each_pixel == e_each_pixel_expected

puts "ok: shape#each_pixel"


# each_filled_pixel
e_each_filled_pixel = e.each_filled_pixel
e_each_filled_pixel_expected = [
  [0, 0, "a"], [0, 1, "z"], [0, 2, "x"], [0, 3, "y"],
  [1, 0, "b"],
  [2, 0, "c"],
  [3, 0, "d"], [3, 2, "u"],
]
raise "e_each_filled_pixel should have each pixel" unless e_each_filled_pixel == e_each_filled_pixel_expected

puts "ok: shape#each_filled_pixel"


# contains_at?
target = Shape.from_string(
  "aaa \n" +
  "aaa \n" +
  "aaaa\n" + 
  " aaa\n"
)

raise "contains_at? wrong" unless target.contains_at?(no_symmetry, 0, 0)
raise "contains_at? wrong" unless !target.contains_at?(no_symmetry, 0, 1)
raise "contains_at? wrong" unless target.contains_at?(no_symmetry_flipped, 0, 1)
raise "contains_at? wrong" unless target.contains_at?(no_symmetry, 1, 0)
raise "contains_at? wrong" unless target.contains_at?(no_symmetry_flipped, 1, 1)
raise "contains_at? wrong" unless !target.contains_at?(no_symmetry, 1, 1)

puts "ok: shape#contains_at?"


# all_placements
all_placements = target.all_placements(no_symmetry)
expected = [[0, 0], [1, 0]]
raise "all_placements" unless all_placements == expected

all_placements = target.all_placements(no_symmetry_flipped)
expected = [[0, 0], [0, 1], [1, 0], [1, 1]]
raise "all_placements" unless all_placements == expected

puts "ok: shape#all_placements"


# overlapped_by?
raise "overlapped_by?" unless flip_symmetry.overlapped_by? flip_symmetry, 0, 0
raise "overlapped_by?" unless !flip_symmetry.overlapped_by? flip_symmetry, -1, -1
raise "overlapped_by?" unless !flip_symmetry.overlapped_by? flip_symmetry, 1, 1
raise "overlapped_by?" unless flip_symmetry.overlapped_by? flip_symmetry, 0, 1
raise "overlapped_by?" unless flip_symmetry.overlapped_by? flip_symmetry, 1, 0

puts "ok: shape#overlapped_by?"