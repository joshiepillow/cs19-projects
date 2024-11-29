use context shared-gdrive("contfracs-context.arr", "1mr5nHB7DDdOffE_hiovBiEuuBsl_59Gh")
include shared-gdrive("contfracs-definitions.arr", "1fFz3TaWdZgIfNxSGVYx0UQz_GXOBIVsc")

include my-gdrive("contfracs-common.arr")
import take, repeating-stream, threshold, fraction-stream, terminating-stream, repeating-stream-opt, threshold-opt, fraction-stream-opt, cf-phi, cf-phi-opt, cf-e, cf-e-opt, cf-pi-opt
from my-gdrive("contfracs-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

check "take works and so does repeating stream":
  take(repeating-stream([list: 1]), 0) is [list: ]
  take(repeating-stream([list: 1]), 1) is [list: 1]
  take(repeating-stream([list: 1]), 5) is [list: 1, 1, 1, 1, 1]
  take(repeating-stream([list: 10, 5]), 5) is [list: 10, 5, 10, 5, 10]
  take(repeating-stream([list: 1, 2, 2, 4]), 10) is [list: 1, 2, 2, 4, 1, 2, 2, 4, 1, 2]
  take(lz-link(-1, {(): repeating-stream([list: 0])}), 5) is [list: -1, 0, 0, 0, 0]
end

check "fraction stream works":
  take(fraction-stream(repeating-stream([list: 1])), 3) 
    is [list: 1, 1 + (1 / 1), 1 + (1 / (1 + (1 / 1)))]
  take(fraction-stream(repeating-stream([list: 1, 2, 3])), 3) 
    is [list: 1, 1 + (1 / 2), 1 + (1 / (2 + (1 / 3)))]
  take(fraction-stream(repeating-stream([list: 2, 1, 2])), 3) 
    is [list: 2, 2 + (1 / 1), 2 + (1 / (1 + (1 / 2)))]
  take(fraction-stream(lz-link(-1, {(): repeating-stream([list: 1])})), 3)
    is [list: -1, -1 + (1 / 1), -1 + (1 / (1 + (1 / 1)))]
end

check "threshold works":
  threshold(fraction-stream(cf-phi), 0.2)
    is 1.5
  threshold(fraction-stream(cf-phi), 10) 
    is 1
end
check "negative difference works":
  threshold(fraction-stream(cf-phi), 0.6)
    is 2
  threshold(fraction-stream(cf-e), 0.001)
    is 2.71875
end
check "strict inequality works":
  threshold(fraction-stream(cf-phi), 0.025)
    is 1.625
  threshold(fraction-stream(cf-phi), 0.5)
    is 1.5
end

check "phi and e are correct":
  take(cf-phi, 10) is [list: 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  take(cf-e, 10) is [list: 2, 1, 2, 1, 1, 4, 1, 1, 6, 1]
end

# part 2
check "terminating-stream is correct":
  take(terminating-stream(empty), 5) is [list: none, none, none, none, none]
  take(terminating-stream([list: 3, 1, 2]), 5) is [list: some(3), some(1), some(2), none, none]
  take(terminating-stream([list: -10, 2, 2, 3]), 5) 
    is [list: some(-10), some(2), some(2), some(3), none]
  take(terminating-stream([list: -10, 2, 2, 3, 6, 7]), 5) 
    is [list: some(-10), some(2), some(2), some(3), some(6)]
end

check "repeating-stream-opt is correct":
  take(repeating-stream-opt([list: 1]), 0) is [list: ]
  take(repeating-stream-opt([list: 1]), 1) is [list: some(1)]
  take(repeating-stream-opt([list: 1]), 5) 
    is [list: some(1), some(1), some(1), some(1), some(1)]
  take(repeating-stream-opt([list: 10, 5]), 5) 
    is [list: some(10), some(5), some(10), some(5), some(10)]
  take(repeating-stream-opt([list: 1, 2, 2, 4]), 10) 
    is [list: some(1), some(2), some(2), some(4), some(1), 
    some(2), some(2), some(4), some(1), some(2)]
end

check "fraction-stream-opt works on infinite streams":
  take(fraction-stream-opt(repeating-stream-opt([list: 1])), 3) 
    is [list: some(1), some(1 + (1 / 1)), some(1 + (1 / (1 + (1 / 1))))]
  take(fraction-stream-opt(repeating-stream-opt([list: 1, 2, 3])), 3) 
    is [list: some(1), some(1 + (1 / 2)), some(1 + (1 / (2 + (1 / 3))))]
  take(fraction-stream-opt(repeating-stream-opt([list: 2, 1, 2])), 3) 
    is [list: some(2), some(2 + (1 / 1)), some(2 + (1 / (1 + (1 / 2))))]
  take(fraction-stream-opt(lz-link(some(-1), {(): repeating-stream-opt([list: 1])})), 3)
    is [list: some(-1), some(-1 + (1 / 1)), some(-1 + (1 / (1 + (1 / 1))))]
end
check "fraction-stream-opt works on terminating stream":
  take(fraction-stream-opt(terminating-stream(empty)), 3) 
    is [list: none, none, none]
  take(fraction-stream-opt(terminating-stream([list: 1])), 3) 
    is [list: some(1), none, none]
  take(fraction-stream-opt(terminating-stream([list: 2, 1, 2])), 4) 
    is [list: some(2), some(2 + (1 / 1)), some(2 + (1 / (1 + (1 / 2)))), none]
end

check "threshold-opt gives correct answer when it exists":
  threshold-opt(fraction-stream-opt(cf-phi-opt), 0.2)
    is 1.5
  threshold-opt(fraction-stream-opt(cf-phi-opt), 10) 
    is 1
  threshold-opt(fraction-stream-opt(cf-phi-opt), 0.6)
    is 2
  threshold-opt(fraction-stream-opt(cf-e-opt), 0.001)
    is 2.71875
  threshold-opt(fraction-stream-opt(cf-phi-opt), 0.025)
    is 1.625
  threshold-opt(fraction-stream-opt(cf-phi-opt), 0.5)
    is 1.5
  threshold-opt(terminating-stream([list: 1, 2, 3, 2, 3, 2.5, 2, 1.5, 1.75]), 1)
    is 3
end
check "threshold-opt throws correct error when answer cannot be found":
  threshold-opt(terminating-stream([list: 1, 2, 3, 2, 3, 2.5, 2, 1.5, 1.75]), 0.25)
    raises "Threshold too small to approximate"
  threshold-opt(terminating-stream([list: 1]), 10)
    raises "Threshold too small to approximate"
  threshold-opt(terminating-stream(empty), 10)
    raises "Threshold too small to approximate"
end

check "cf-phi-opt and cf-e-opt are correct":
  take(cf-phi-opt, 10) is [list: some(1), some(1), some(1), 
    some(1), some(1), some(1), some(1), some(1), some(1), some(1)]
  take(cf-e-opt, 10) is [list: some(2), some(1), some(2), 
    some(1), some(1), some(4), some(1), some(1), some(6), some(1)]
end

check "fractional approx of cf-pi-opt has correct first five terms":
  take(fraction-stream-opt(cf-pi-opt), 5) 
    is [list: some(3), some(22 / 7), some(333 / 106), some(355 / 113), some(103993 / 33102)]
end