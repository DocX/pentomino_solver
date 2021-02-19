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

  let(:a) do
    Shape.from_string(
      "aaaa\n" +
      "a  a\n" +
      "a  a\n" +
      "aaaa\n"
    )
  end

  let(:b) do
    Shape.from_string(
      "bbbc\n" +
      "b  c\n" +
      "a  c\n" +
      "aaaa\n"
    )
  end

  let(:c) do
    Shape.from_string(
      "bb\n" +
      "bb\n"
    )
  end

  let(:d) do
    Shape.from_string(
      "aaaa\n" +
      "a  a\n" +
      "a   \n" +
      "aaaa\n"
    )
  end

  let(:e) do
    Shape.from_string(
      "azxy\n" +
      "b   \n" +
      "c   \n" +
      "d u \n"
    )
  end

  let(:e_rotated) do
    Shape.from_string(
      "dcba\n" +
      "   z\n" +
      "u  x\n" +
      "   y\n"
    )
  end

  describe "#eql?" do
    it "is true for same shapes" do
      expect(a.eql? a).to eq true
    end

    it "is false for different shapes" do
      expect(a.eql? b).to eq false
    end
  end

  describe "#size" do
    it { expect(a.size).to eq [4,4] }
  end

  describe "#cover?" do
    it { expect(a).to cover b }
    it { expect(b).to cover a }
    it { expect(a).to_not cover c }
    it { expect(c).to_not cover a }
    it { expect(d).to_not cover a }
    it { expect(a).to_not cover d }
  end

  describe "#rotate_clockwise" do
    it { expect(e.rotate_clockwise).to eql e_rotated }
  end

  let(:no_symmetry) do
    Shape.from_string(
      " aa\n" +
      "aa \n" +
      " a \n"
    )
  end

  let(:no_symmetry_flipped) do
    Shape.from_string(
      " a \n" +
      "aa \n" +
      " aa\n"
    )
  end

  let(:rot_and_flip_symmetry) do
    Shape.from_string(
      "aaaaa\n"
    )
  end

  let(:flip_symmetry) do
    Shape.from_string(
      "aaa\n" +
      "a  \n" +
      "a  \n"
    )
  end

  describe "#flip" do
    it { expect(no_symmetry.flip).to eql no_symmetry_flipped }
  end

  describe "#uniq_orientations" do
    it { expect(no_symmetry.uniq_orientations.count).to eq 8 }
    it { expect(rot_and_flip_symmetry.uniq_orientations.count).to eq 2 }
    it { expect(flip_symmetry.uniq_orientations.count).to eq 4 }
  end

  describe "#each_pixel" do
    it "is list of [row, col, val] for each pixel" do
      e_each_pixel_expected = [
        [0, 0, "a"], [0, 1, "z"], [0, 2, "x"], [0, 3, "y"],
        [1, 0, "b"], [1, 1, nil], [1, 2, nil], [1, 3, nil],
        [2, 0, "c"], [2, 1, nil], [2, 2, nil], [2, 3, nil],
        [3, 0, "d"], [3, 1, nil], [3, 2, "u"], [3, 3, nil],
      ]
      expect(e.each_pixel).to eq e_each_pixel_expected
    end
  end

  describe "#each_filled_pixel" do
    it "is each pixel filtered to only non nil values" do
      e_each_filled_pixel_expected = [
        [0, 0, "a"], [0, 1, "z"], [0, 2, "x"], [0, 3, "y"],
        [1, 0, "b"],
        [2, 0, "c"],
        [3, 0, "d"], [3, 2, "u"],
      ]
      expect(e.each_filled_pixel).to eq e_each_filled_pixel_expected
    end
  end

  describe "#contains_at?" do
    let(:target) do
      Shape.from_string(
        "aaa \n" +
        "aaa \n" +
        "aaaa\n" +
        " aaa\n"
      )
    end

    it "is true when it contains the shape" do
      expect(target.contains_at?(no_symmetry, 0, 0)).to eq true
      expect(target.contains_at?(no_symmetry_flipped, 0, 1)).to eq true
      expect(target.contains_at?(no_symmetry, 1, 0)).to eq true
      expect(target.contains_at?(no_symmetry_flipped, 1, 1)).to eq true
    end

    it "is false when it does not contain the shape" do
      expect(target.contains_at?(no_symmetry, 0, 1)).to eq false
      expect(target.contains_at?(no_symmetry, 1, 1)).to eq false
    end
  end

  describe "#all_placements" do
    let(:target) do
      Shape.from_string(
        "aaa \n" +
        "aaa \n" +
        "aaaa\n" +
        " aaa\n"
      )
    end

    it { expect(target.all_placements(no_symmetry)).to eq [[0, 0], [1, 0]] }
    it { expect(target.all_placements(no_symmetry_flipped)).to eq [[0, 0], [0, 1], [1, 0], [1, 1]] }
  end

  describe "overlapped_by?" do
    it { expect(flip_symmetry.overlapped_by? flip_symmetry, 0, 0).to eq true }
    it { expect(flip_symmetry.overlapped_by? flip_symmetry, -1, -1).to eq false }
    it { expect(flip_symmetry.overlapped_by? flip_symmetry, 1, 1).to eq false }
    it { expect(flip_symmetry.overlapped_by? flip_symmetry, 0, 1).to eq true }
    it { expect(flip_symmetry.overlapped_by? flip_symmetry, 1, 0).to eq true }
  end
end
