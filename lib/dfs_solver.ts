export class DFSSolver {
  debug: boolean = false;
  solution: object[] | null = null;
  remaining_space: object[][] | null = null

  solve() {
    if (this.solution !== null && this.remaining_space !== null) {
      const last_placement = this.solution.pop()
      this.remaining_space.pop()
      this.remaining_space[this.remaining_space.length - 1] = 
        this.remaining_space[this.remaining_space.length - 1]
          .filter(placement => placement !== last_placement )
    }

    let solution = this.solution || []
    let remaining_space = this.remaining_space || [this.initial_remaining_space()]

    let iterations = 0
    let last_iterations_time = new Date().valueOf()
    const started = new Date().valueOf()

    while (!this.completed(solution)) {
      iterations = iterations + 1
      if (this.debug && iterations % 10000 == 0) {
        console.log(`Iteration: ${iterations} (${(10000 / (new Date().valueOf() - last_iterations_time))} / s)`)
        console.log(this.render_solution(solution))
        console.log("")
        last_iterations_time = new Date().valueOf()
      }

      let next_solution, next_remaining_space = this.next_placement(solution, remaining_space[remaining_space.length - 1])

      if (next_solution === null) {
        // backtrack - go step above and remove last placement from the space
        const last_placement = solution.pop()
        remaining_space.pop()
        remaining_space[remaining_space.length - 1] = remaining_space[remaining_space.length - 1]
          .filter(placement => placement !== last_placement)
      } else {
        solution = next_solution
        remaining_space.push(next_remaining_space)
      }
    }

    if (this.debug) {
      console.log(`Solved in iteration: ${iterations} (${(iterations / (new Date().valueOf() - started))} / s)`)
      console.log(this.render_solution(solution))
      console.log("")
    }

    this.solution = solution
    this.remaining_space = remaining_space

    return solution
  }

  initial_remaining_space(): object[] {
    throw "NotImplementedError"
  }

  completed(solution): boolean {
    throw "NotImplementedError"
  }

  next_placement(solution, remaining_space): [object[], object[]] {
    throw "NotImplementedError"
  }

  render_solution(solution) {
    throw "NotImplementedError"
  }
}
