use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: liquify-memoization, liquify-dynamic-programming end

include my-gdrive("fluid-images-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.
fun in-bounds(input :: Array<Array<Color>>, row :: Number, column :: Number) -> Boolean:
  doc: "check if row, column pair is inside bounds of image"
  (row >= 0) and (row < input.length()) and (column >= 0) and (column < input.get-now(0).length())
where:
  in-bounds(arr-test, 0, 0) is true
  in-bounds(arr-test, 2, 0) is false
  in-bounds(arr-test, 0, 2) is true
  in-bounds(arr-test, -1, 0) is false
  in-bounds(arr-test, -1, -1) is false
  in-bounds(arr-test, 0, -1) is false
  in-bounds(arr-test, 1, 2) is true
  in-bounds(arr-test, 0, 3) is false
end

fun safe-get(input :: Array<Array<Color>>, row :: Number, column :: Number) -> Number:
  doc: "get the brightness at a given pixel, or 0 if the location is out of bounds"
  if in-bounds(input, row, column):
    a-color = input.get-now(row).get-now(column)
    a-color.red + a-color.green + a-color.blue
  else:
    0
  end
where:
  safe-get(arr-test, 0, 0) is 6
  safe-get(arr-test, -1, 1) is 0
  safe-get(arr-test, 1, 2) is 51
  safe-get(arr-test, 1, 10) is 0
  safe-get(arr-test, 10, 1) is 0
  safe-get(arr-test, 10, 10) is 0
end

fun energize(input :: Array<Array<Color>>) -> Array<Array<Number>>:
  doc: "compute the energy of each pixel in an image"
  array-from-list(range(0, input.length()).map({(row):
        array-from-list(range(0, input.get-now(0).length()).map({(column):
              a = safe-get(input, row - 1, column - 1)
              b = safe-get(input, row - 1, column)
              c = safe-get(input, row - 1, column + 1)
              d = safe-get(input, row, column - 1)
              e = safe-get(input, row, column)
              f = safe-get(input, row, column + 1)
              g = safe-get(input, row + 1, column - 1)
              h = safe-get(input, row + 1, column)
              i = safe-get(input, row + 1, column + 1)
              x-energy = a + (2 * d) + g + (-1 * c) + (-2 * f) + (-1 * i)
              y-energy = a + (2 * b) + c + (-1 * g) + (-2 * h) + (-1 * i)
              num-sqrt((x-energy * x-energy) + (y-energy * y-energy))
            }))
      }))
where:
  energize(arr-test) is%(within-rel-now(0.01)) [array: 
    [array: 129.79, 176.46, 160.99], 
    [array: 102.61, 80.72, 117.34]]
  energize(energy-arr) is%(within-rel-now(0.01)) [array:
    [array: 7.07, 6, 7.07],
    [array: 10, 8, 10],
    [array: 10.29, 6, 10.29]]
  energize(more-energy-arr) is%(within-rel-now(0.01)) [array: 
    [array: 145.67, 204, 145.67], 
    [array: 204.08, 8, 204.08],
    [array: 148.49, 204, 148.49]]
end

fun memoize<T>(f :: (Number, Number -> T), max-1 :: Number, max-2 :: Number) 
  -> (Number, Number -> T):
  doc: "memoize a recursive function using an array"
  memory :: Array<Array<Option<T>>> = build-array({(_): 
      build-array({(_): none}, max-2)}, max-1)

  lam(p, q):
    answer = memory.get-now(p).get-now(q)
    cases (Option) answer block:
      | none =>
        result = f(p, q)
        memory.get-now(p).set-now(q, some(result))
        result
      | some(v) => v
    end
  end
where:
  rec fib = memoize(lam(n, _): 
      if (n == 0) or (n == 1): 1
      else: fib(n - 1, 0) + fib(n - 2, 0)
      end
    end, 10, 1)
  fib(1, 0) is 1
  fib(5, 0) is 8
  fib(9, 0) is 55
  
  rec paths-to = memoize(lam(n, m):
      if (n == 0) or (m == 0): 1
      else: paths-to(n - 1, m) + paths-to(n, m - 1)
      end
    end, 10, 10)
  paths-to(1, 1) is 2
  paths-to(9, 1) is 10
  paths-to(9, 9) is 48620
end

data Path:
  | path(path :: List<{Number; Number}>, cost :: Number)
end

fun get-min(paths :: List<Path>) -> Path:
  doc: "get the path with least cost among a list of paths"
  cases (List) paths:
    | empty => path(empty, 0)
    | link(f, r) => 
      r.foldl({(a-path, min-path):
          if (a-path.cost < min-path.cost):
            a-path
          else:
            min-path
          end
        }, f)
  end
where:
  get-min(empty) is path(empty, 0)
  get-min([list: path(empty, 1)]) is path(empty, 1)
  get-min([list: path(empty, 1), path([list: {0; 0}], 2)]) is path(empty, 1)
  get-min([list: path(empty, 1), path([list: {0; 0}], 0)]) is path([list: {0; 0}], 0)
  get-min([list: path(empty, 1), path([list: {0; 0}], 1)]) is path(empty, 1)
  get-min([list: path([list: {0; 0}], 3), path([list: {0; 1}], 1), path([list: {0; 2}], 2)]) 
    is path([list: {0; 1}], 1)
end

fun remove-seam(input :: Image, a-path :: Path) -> Image:
  doc: "remove a seam from an image"
  # include indices
  with-indices = map_n({(row-index, row):
      map_n({(column-index, a-color):
          {a-color; row-index; column-index}
        }, 0, row)}, 0, input.pixels)

  # remove seam
  removed = with-indices.map({(row): 
      row.filter({({_; row-index; column-index}): 
          not(a-path.path.member({row-index; column-index}))})})

  # forget indices
  new-pixels = removed.map({(row):
      row.map({({a-color; _; _}): a-color})})

  image-data-to-image(input.width - 1, input.height, new-pixels) 
where:
  remove-seam(img-test, path([list: {0; 0}, {1; 0}], 0)) is image-data-to-image(2, 2, [list:
      [list: color(4,5,6),  color(7,8,9)],
      [list: color(13,14,15),  color(16,17,18)]])
  remove-seam(img-test, path([list: {0; 0}, {1; 1}], 0)) is image-data-to-image(2, 2, [list:
      [list: color(4,5,6),  color(7,8,9)],
      [list: color(10,11,12),  color(16,17,18)]])
  remove-seam(img-test, path([list: {0; 2}, {1; 1}], 0)) is image-data-to-image(2, 2, [list:
      [list: color(1,2,3),  color(4,5,6)],
      [list: color(10,11,12),  color(16,17,18)]])
end

fun liquify-once-memoization(input :: Image) -> Image:
  doc: "remove the seam with lowest cost calculated with memoization"
  as-array = array-from-list(input.pixels.map(array-from-list))
  energies = energize(as-array)
  rec best-path-to-row-col :: (Number, Number -> Path) = memoize(
    lam(row :: Number, column :: Number):
      if (row == 0):
        path([list: {row; column}], energies.get-now(row).get-now(column))
      else:
        upper-left = if in-bounds(as-array, row - 1, column - 1):
          [list: best-path-to-row-col(row - 1, column - 1)]
        else:
          empty
        end

        upper = [list: best-path-to-row-col(row - 1, column)]

        upper-right = if in-bounds(as-array, row - 1, column + 1):
          [list: best-path-to-row-col(row - 1, column + 1)]
        else:
          empty
        end

        best = get-min(upper-left.append(upper).append(upper-right))

        path(link({row; column}, best.path), best.cost + energies.get-now(row).get-now(column))
      end
    end, input.height, input.width)

  paths-to-bottom = range(0, input.width).map({(column): 
      best-path-to-row-col(input.height - 1, column)
    })
  remove-seam(input, get-min(paths-to-bottom))
where:
  liquify-once-memoization(img-test) is image-data-to-image(2, 2, [list:
      [list: color(4,5,6),  color(7,8,9)],
      [list: color(10,11,12),  color(16,17,18)]])
  liquify-once-memoization(energy-ties) is image-data-to-image(2, 3, [list: 
      [list: color(1,0,0), color(1,0,0)], 
      [list: color(0,2,0), color(0,2,0)], 
      [list: color(0,0,3), color(0,0,3)]])
  liquify-once-memoization(more-energy-ties) is image-data-to-image(2, 3, [list:  
      [list: color(0,1,0), color(0,0,1)],
      [list: color(2,0,0), color(0,0,2)],
      [list: color(0,3,0), color(0,0,3)]])
end

fun liquify-memoization(input :: Image, n :: Number) -> Image:
  doc: "remove n seams with lowest cost calculated with memoization"
  range(0, n).foldl({(_, liquified-image): liquify-once-memoization(liquified-image)}, input)
end

fun liquify-once-dynamic(input :: Image) -> Image:
  doc: "remove the seam with lowest cost calculated with dynamic programming"
  as-array = array-from-list(input.pixels.map(array-from-list))
  energies = energize(as-array)
  memory :: Array<Array<Path>> = build-array({(_): 
      build-array({(_): path(empty, 0)}, input.width)}, input.height)
  
  _ = range(0, input.height).map({(row): range(0, input.width).map({(column):
          upper-left = if in-bounds(as-array, row - 1, column - 1):
            [list: memory.get-now(row - 1).get-now(column - 1)]
          else:
            empty
          end

          upper = if in-bounds(as-array, row - 1, column):
            [list: memory.get-now(row - 1).get-now(column)]
          else:
            empty
          end

          upper-right = if in-bounds(as-array, row - 1, column + 1):
            [list: memory.get-now(row - 1).get-now(column + 1)]
          else:
            empty
          end
          
          best = get-min(upper-left.append(upper).append(upper-right))
          
          _ = memory.get-now(row).set-now(column, path(link({row; column}, best.path), 
              best.cost + energies.get-now(row).get-now(column)))
          nothing
        })})
  
  paths-to-bottom = range(0, input.width).map({(column): 
      memory.get-now(input.height - 1).get-now(column)
    })
  remove-seam(input, get-min(paths-to-bottom))
where:
  liquify-once-dynamic(img-test) is image-data-to-image(2, 2, [list:
      [list: color(4,5,6),  color(7,8,9)],
      [list: color(10,11,12),  color(16,17,18)]])
  liquify-once-dynamic(energy-ties) is image-data-to-image(2, 3, [list: 
      [list: color(1,0,0), color(1,0,0)], 
      [list: color(0,2,0), color(0,2,0)], 
      [list: color(0,0,3), color(0,0,3)]])
  liquify-once-dynamic(more-energy-ties) is image-data-to-image(2, 3, [list:  
      [list: color(0,1,0), color(0,0,1)],
      [list: color(2,0,0), color(0,0,2)],
      [list: color(0,3,0), color(0,0,3)]])
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image:
  doc: "remove n seams with lowest cost calculated with dynamic programming"
  range(0, n).foldl({(_, liquified-image): liquify-once-dynamic(liquified-image)}, input)
end