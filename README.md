# Shapes Fitting Puzzle Solver

This program finds solution for placing given shapes to fully cover another given shape.

It is inspired by physical puzzle Pentomino.

## Problem statemenet

You are given set of usable shapes, i.e.:

```
██
 █
 ██
 
█
██
 ██
 
█ █
███
```

and a target shape, i.e.:

```
   █
 ███
  ██
  ██
  ██
████
█ ███
  █████
  ██████
  ███████
  ███████
  ██  ███
████   ████████
```

The solution is placement of the usable shapes in space so they create the target shape, while each shape can be:

* used once
* can be rotated
* can be flipped

## Solver

Solver uses depth-first search algorithm with custom heuristics

## How to use

```
bin/pantomino_solver.rb --shapes examples/shapes.yaml --target examples/targets/cat.yaml
```

## Example

<img width="758" alt="Screenshot 2022-11-20 at 01 57 09" src="https://user-images.githubusercontent.com/132277/202877711-e235b1c3-503c-4aa9-996d-287b0655ecb9.png">
