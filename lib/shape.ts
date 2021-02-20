export type Pixel = [number, number]
export type Bitmap = (string | null)[][]

export class Shape {
  _each_filled_pixel: Pixel[]
  _each_filled_pixel_with_val: [number, number, string][]
  _field: Bitmap
  _rows: number
  _cols: number

constructor(field: Bitmap) {
    this._field = field
    this._rows = field.length
    this._cols = field[0].length
  };
  
  read([row, col]: Pixel): string {
    return this._field[row][col];
  };
  
  rows() {
    return this._rows
  };
  
  cols() {
    return this._cols
  };
  
  size() {
    [this._rows, this._cols]
  }

  each_filled_pixel() {
    if (this._each_filled_pixel) return this._each_filled_pixel;

    this._each_filled_pixel = 
      this.each_filled_pixel_with_val()
      .map(([row, col, _val]) => [row, col])
  }

  each_filled_pixel_with_val() {
    if (this._each_filled_pixel_with_val) return this._each_filled_pixel_with_val;

    this._each_filled_pixel_with_val = this._field
      .flatMap((row, row_i) => 
        row.map((val, col_i) => [row_i, col_i, val] as [number, number, string])
      )
  }

  rotate_clockwise() {
    // first row to last col
    let rotated = new Array(this._cols).map(() => new Array(this._rows).fill(null))
    
    this._field.forEach((row, row_i) => (
      row.forEach((point, col_i) => rotated[col_i][this._rows - row_i - 1] = point)
    ));
  
    return new Shape(rotated)
  }

  flip() {
    // flip rows
    let flipped =  new Array(this._rows).map(() => new Array(this._cols).fill(null))
      
    this._field.forEach((row, row_i) => (
      row.forEach((point, col_i) => flipped[this._rows - row_i - 1][col_i] = point)
    ));
  
    return new Shape(flipped)
  }

  equal(other: Shape): boolean {
    if (this.each_filled_pixel().length != other.each_filled_pixel().length) {
      return false
    }

    return this.each_filled_pixel().every(([row, col]) =>
      other.each_filled_pixel()
        .some(([other_row, other_col]) => other_row === row && other_col === col)
    )
  }

  // Enumerate all unique orientation (rotation/flip)
  uniq_orientations(): Shape[] {
    let rotated_1 = this.rotate_clockwise();
    let rotated_2 = rotated_1.rotate_clockwise();
    let rotated_3 = rotated_2.rotate_clockwise();
    let flipped_0 = this.flip();
    let flipped_1 = flipped_0.rotate_clockwise();
    let flipped_2 = flipped_1.rotate_clockwise();
    let flipped_3 = flipped_2.rotate_clockwise();

    let orientations = [
      this,
      rotated_1,
      rotated_2,
      rotated_3,
      flipped_0,
      flipped_1,
      flipped_2,
      flipped_3
    ]

    return orientations
      .filter((shape, index, self) => 
        self.findIndex(other_shape => shape.equal(other_shape)) === index
      )
  }

  // Calculate positions of other_shape placed on top of this shape so
  // it covers it completely
  // Returns list of [{row, col}, ...]
  all_placements(other_shape: Shape) {
    let all_placements: Pixel[] = []

    for (let row = 0; row < this._rows - other_shape._rows + 1; row++) {
      for (let col = 0; col < this._cols - other_shape._cols + 1; col++) {
        if (this.contains_at(other_shape, row, col)) {
          all_placements.push([row, col])
        }    
      }        
    }

    return all_placements
  }

  contains_at(other_shape: Shape, row: number, col: number): boolean {
    return other_shape.each_filled_pixel().every(([other_row, other_col]) => {
      return this.read([other_row + row, other_col + col]) !== null
    })
  }

}