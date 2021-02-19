class DFSSolver
  def solve
    solution = []
    remaining_space = [initial_remaining_space]

    iterations = 0

    while !completed?(solution)
      iterations += 1
      if defined?(DEBUG) && iterations % 10000 == 0
        puts
        puts "Iteration: #{iterations}"
        puts render_solution(solution).to_s
      end

      next_solution, next_remaining_space = next_placement(solution, remaining_space.last)

      if next_solution.nil?
        # backtrack - go step above and remove last placement from the space
        last_placement = solution.pop
        remaining_space.pop
        remaining_space[remaining_space.count - 1] = remaining_space.last.reject { |placement| placement.equal? last_placement }
      else
        solution = next_solution
        remaining_space << next_remaining_space
      end
    end

    if defined?(DEBUG)
      puts
      puts "Solved in iteration: #{iterations}"
      puts render_solution(solution).to_s
    end

    return solution
  end

  def initial_remaining_space
    raise NotImplementedError
  end

  def completed?(solution)
    raise NotImplementedError
  end

  def next_placement(solution, remaining_space)
    raise NotImplementedError
  end

  def render_solution(solution)
    raise NotImplementedError
  end
end
