class DFSSolver
  def solve
    solution = []

    iterations = 0

    while !completed?(solution)
      iterations += 1
      puts "Iterations: #{iterations}" if DEBUG && iterations % 100 == 0

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
end