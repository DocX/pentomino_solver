class DFSSolver
  def solve
    solution = []

    iterations = 0

    while !completed?(solution)
      iterations += 1
      if defined?(DEBUG) && iterations % 1000 == 0
        puts
        puts "Iteration: #{iterations}"
        puts render_solution(solution).to_s
      end

      placement = next_placement(solution, nil)

      if placement.nil?
        solution = backtrack(solution)
      else
        solution << placement
      end
    end

    return solution
  end

  def backtrack(solution)
    alternative = nil
    while alternative.nil?
      raise "No solution" if solution.empty?

      last_placement = solution.pop
      alternative = next_placement(solution, last_placement)
    end

    solution << alternative
    solution
  end

  def completed?(solution)
    raise NotImplementedError
  end

  def next_placement(solution, previous)
    raise NotImplementedError
  end

  def render_solution(solution)
    raise NotImplementedError
  end
end
