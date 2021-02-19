require './lib/shape.rb'

module Pentomino
  F = Shape.from_string(%{
     FF
    FF
     F
  })

  I = Shape.from_string(%{
    I
    I
    I
    I
    I
  })

  L = Shape.from_string(%{
    L
    L
    L
    LL
  })

  N = Shape.from_string(%{
     N
    NN
    N
    N
  })

  P = Shape.from_string(%{
     P
    PP
    PP
  })

  T = Shape.from_string(%{
    TTT
     T
     T
  })

  U = Shape.from_string(%{
    U U
    UUU
  })

  V = Shape.from_string(%{
    V
    V
    VVV
  })

  W = Shape.from_string(%{
    W
    WW
     WW
  })

  X = Shape.from_string(%{
     X
    XXX
     X
  })

  Y = Shape.from_string(%{
     Y
    YY
     Y
     Y
  })

  Z = Shape.from_string(%{
    ZZ
     Z
     ZZ
  })

  ALL_12 = [F, I, L, N, P, T, U, V, W, X, Y, Z]
end
