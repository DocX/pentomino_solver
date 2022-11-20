require 'lib/dfs_solver'

RSpec.describe DFSSolver do
  class TestDFS < DFSSolver
    # find descending sequence of 5

    def next_placement(solution, space)
      return [nil, nil] if solution.count > 5
      return [nil, nil] if space.empty?

      next_solution = solution + [space.first]
      [next_solution, initial_remaining_space]
    end

    def initial_remaining_space
      [1,2,3,4,5]
    end

    def completed?(solution)
      solution == [5,4,3,2,1]
    end
  end

  it "solves the problem" do
    expect(TestDFS.new.solve).to eq [5,4,3,2,1]
  end
end
