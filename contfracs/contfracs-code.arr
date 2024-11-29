use context shared-gdrive("contfracs-context.arr", "1mr5nHB7DDdOffE_hiovBiEuuBsl_59Gh")
include shared-gdrive("contfracs-definitions.arr", "1fFz3TaWdZgIfNxSGVYx0UQz_GXOBIVsc")

provide:
  take, repeating-stream, threshold, fraction-stream, terminating-stream,
  repeating-stream-opt, threshold-opt, fraction-stream-opt, cf-phi, cf-phi-opt,
  cf-e, cf-e-opt, cf-pi-opt,
end

include my-gdrive("contfracs-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

## Part 1: Streams

fun take<T>(s :: Stream<T>, n :: Number) -> List<T>:
  doc: "take first n elements from a stream as a list"
  if (n == 0):
    empty
  else:
    link(lz-first(s), take(lz-rest(s), n - 1))
  end
end

fun repeating-stream-helper(cur-numbers :: List<Number>, 
    numbers :: List<Number>) -> Stream<Number>:
  doc: "generate a stream of cur-numbers followed by repeating numbers"
  cases (List) cur-numbers:
    | empty => repeating-stream-helper(numbers, numbers)
    | link(first, rest) => lz-link(first, {(): repeating-stream-helper(rest, numbers)})
  end
where:
  take(repeating-stream-helper([list: ], [list: 1]), 5) is [list: 1, 1, 1, 1, 1]
  take(repeating-stream-helper([list: 1, 2, 3], [list: 1]), 5) is [list: 1, 2, 3, 1, 1]
  take(repeating-stream-helper([list: ], [list: 1, 2, 3]), 5) is [list: 1, 2, 3, 1, 2]
  take(repeating-stream-helper([list: 1, 2], [list: 1, 2, 3]), 5) is [list: 1, 2, 1, 2, 3]
end

fun repeating-stream(numbers :: List<Number>) -> Stream<Number>:
  doc: "generate a stream of repeating numbers"
  repeating-stream-helper(numbers, numbers)
end

fun fraction-stream-helper(past-numbers :: List<Number>, 
    coefficients :: Stream<Number>) -> Stream<Number>:
  doc: "generate a stream of fractions given that past-numbers contains previous coefs"
  fraction = past-numbers.foldl(lam(number, acc): 
      number + (1 / acc)
    end, lz-first(coefficients))
  lz-link(fraction, lam(): 
      fraction-stream-helper(link(lz-first(coefficients), past-numbers), lz-rest(coefficients))
    end)
where:
  take(fraction-stream-helper([list: ], repeating-stream([list: 1])), 3) 
    is [list: 1, 1 + (1 / 1), 1 + (1 / (1 + (1 / 1)))]
  take(fraction-stream-helper([list: ], repeating-stream([list: 1, 2, 3])), 3) 
    is [list: 1, 1 + (1 / 2), 1 + (1 / (2 + (1 / 3)))]
  take(fraction-stream-helper([list: ], repeating-stream([list: 2, 1, 2])), 3) 
    is [list: 2, 2 + (1 / 1), 2 + (1 / (1 + (1 / 2)))]
  take(fraction-stream-helper([list: ], lz-link(-1, {(): repeating-stream([list: 1])})), 3)
    is [list: -1, -1 + (1 / 1), -1 + (1 / (1 + (1 / 1)))]
  take(fraction-stream-helper([list: 10], repeating-stream([list: 1])), 3) 
    is [list: 10 + (1 / 1), 10 + (1 / (1 + (1 / 1))), 10 + (1 / (1 + (1 / (1 + (1 / 1)))))]
  take(fraction-stream-helper([list: 10, 11, 12], repeating-stream([list: 1])), 1) 
    is [list: 12 + (1 / (11 + (1 / (10 + (1 / 1)))))]
end

fun fraction-stream(coefficients :: Stream<Number>) -> Stream<Number>:
  doc: "generate a stream of fractions from coefs"
  fraction-stream-helper(empty, coefficients)
end

fun threshold(approximations :: Stream<Number>, thresh :: Number)-> Number:
  doc: "find first number in stream where difference with next number is less than thresh"
  rest = lz-rest(approximations)
  difference = lz-first(approximations) - lz-first(rest)
  if ((difference < thresh) and (difference > (0 - thresh))):
    lz-first(approximations)
  else:
    threshold(rest, thresh)
  end
end

cf-phi :: Stream<Number> = repeating-stream([list: 1])

fun e-helper(n :: Number) -> Stream<Number>:
  doc: "gives the (n+1)th coefficient of e for n >= 2"
  rem = num-modulo(n, 3)
  if (rem == 0):
    lz-link(2 * (n / 3), {(): e-helper(n + 1)})
  else:
    lz-link(1, {(): e-helper(n + 1)})
  end
end
# tests are identical to cf-e tests in main test file

cf-e :: Stream<Number> = lz-link(2, {(): e-helper(2)})


## Part 2: Options and Terminating Streams

fun stream-end() -> Stream<Option<Number>>:
  doc: "represents the end of a stream"
  lz-link(none, stream-end)
where:
  take(stream-end(), 5) is [list: none, none, none, none, none]
end

fun terminating-stream(numbers :: List<Number>) -> Stream<Option<Number>>:
  doc: "constructs finite stream from finite list of numbers"
  cases (List) numbers:
    | empty => stream-end()
    | link(first, rest) => lz-link(some(first), {(): terminating-stream(rest)})
  end
end

fun lift(numbers :: Stream<Number>) -> Stream<Option<Number>>:
  doc: "lift a stream of numbers to a stream of option numbers"
  lz-link(some(lz-first(numbers)), {(): lift(lz-rest(numbers))})
where:
  take(lift(cf-phi), 5) is [list: some(1), some(1), some(1), some(1), some(1)]
  take(lift(cf-e), 5) is [list: some(2), some(1), some(2), some(1), some(1)]
end

fun repeating-stream-opt(numbers :: List<Number>) -> Stream<Option<Number>>:
  doc: "construct a repeating stream of options from a list of numbers"
  lift(repeating-stream(numbers))
end

fun fraction-stream-opt-helper(past-numbers :: List<Number>, 
    coefficients :: Stream<Option<Number>>) -> Stream<Option<Number>>:
  doc: "generate a stream of fraction options given that past-numbers contains previous coefs"
  cases (Option) lz-first(coefficients):
    | none => stream-end()
    | some(num) =>
      fraction = past-numbers.foldl(lam(number, acc): 
          number + (1 / acc)
        end, num)
      lz-link(some(fraction), lam(): 
          fraction-stream-opt-helper(link(num, past-numbers), lz-rest(coefficients))
        end)
  end
where:
  take(fraction-stream-opt-helper([list: ], repeating-stream-opt([list: 1])), 3) 
    is [list: some(1), some(1 + (1 / 1)), some(1 + (1 / (1 + (1 / 1))))]
  take(fraction-stream-opt-helper([list: ], repeating-stream-opt([list: 1, 2, 3])), 3) 
    is [list: some(1), some(1 + (1 / 2)), some(1 + (1 / (2 + (1 / 3))))]
  take(fraction-stream-opt-helper([list: ], repeating-stream-opt([list: 2, 1, 2])), 3) 
    is [list: some(2), some(2 + (1 / 1)), some(2 + (1 / (1 + (1 / 2))))]
  take(fraction-stream-opt-helper([list: 10, 11, 12], repeating-stream-opt([list: 1])), 1) 
    is [list: some(12 + (1 / (11 + (1 / (10 + (1 / 1))))))]
  take(fraction-stream-opt-helper([list: 1, 2], stream-end()), 3)
    is [list: none, none, none]
  take(fraction-stream-opt-helper([list: 1, 2], terminating-stream([list: 3])), 3)
    is [list: some(2 + (1 / (1 + (1 / 3)))), none, none]
end

fun fraction-stream-opt(coefficients :: Stream<Option<Number>>)  
  -> Stream<Option<Number>>:
  doc: "generate a stream of fraction options from coefs"
  fraction-stream-opt-helper(empty, coefficients)
end

fun threshold-opt(approximations :: Stream<Option<Number>>,
    thresh :: Number) -> Number:
  doc: "find first number in option stream where difference with next number is less than thresh"
  cases (Option) lz-first(approximations):
    | none => raise("Threshold too small to approximate")
    | some(first) => 
      rest = lz-rest(approximations)
      cases (Option) lz-first(rest):
        | none => raise("Threshold too small to approximate")
        | some(second) =>
          difference = first - second
          if ((difference < thresh) and (difference > (0 - thresh))):
            first
          else:
            threshold-opt(rest, thresh)
          end
      end
  end
end

cf-phi-opt :: Stream<Option<Number>> = lift(cf-phi)
cf-e-opt :: Stream<Option<Number>> = lift(cf-e)
cf-pi-opt :: Stream<Option<Number>> = terminating-stream([list: 3, 7, 15, 1, 292])
