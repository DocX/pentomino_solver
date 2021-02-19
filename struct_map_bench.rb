require "benchmark"

class MyStruct
  attr_accessor :shape_id, :row, :col

  def initialize(shape_id:, row:, col:)
    @shape_id = shape_id
    @row = row
    @col = col
  end
end

Benchmark.bm(10) do |bench|
  list = []
  bench.report "Hash create" do
    5000.times { list = Array.new(1000) { { shape_id: 12, row: 2, col: 4 } } }
  end

  bench.report "Hash read" do
    50000.times { list.each { |l| l[:row] + l[:col] } }
  end

  bench.report "Struct create" do
    5000.times { list = Array.new(1000) { MyStruct.new(shape_id: 12, row: 2, col: 4) } }
  end

  bench.report "Struct read" do
    50000.times { list.each { |l| l.row + l.col } }
  end
end
