class DFSSolver
  attr_accessor :debug

  def solve
    solution = []
    remaining_space = [initial_remaining_space]

    iterations = 0
    last_iterations_time = Time.now
    started = Time.now

    while !completed?(solution)
      iterations += 1
      if debug && iterations % 10000 == 0
        puts ""
        puts "Iteration: #{iterations} (#{(10000 / (Time.now - last_iterations_time)).to_i} / s)"
        puts render_solution(solution).to_s
        last_iterations_time = Time.now
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

    if debug
      puts ""
      puts "Solved in iteration: #{iterations} (#{(iterations / (Time.now - started)).to_i} / s)"
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
