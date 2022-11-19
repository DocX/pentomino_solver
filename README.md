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
