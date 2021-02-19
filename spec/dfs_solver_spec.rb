require './lib/dfs_solver'

RSpec.describe DFSSolver do 
  class TestDFS < DFSSolver
    # find descending sequence of 5

    def next_placement(solution, last)
      return nil if solution.count == 5
      return 1 if last.nil?
      return nil if last == 9

      last + 1
    end

    def completed?(solution)
      solution == [5,4,3,2,1]
    end
  end

  it "solves the problem" do
    expect(TestDFS.new.solve).to eq [5,4,3,2,1]
  end
end