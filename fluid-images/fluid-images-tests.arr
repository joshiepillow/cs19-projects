use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

include my-gdrive("fluid-images-common.arr")
import liquify-memoization, liquify-dynamic-programming
from my-gdrive("fluid-images-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

check "liquify memo works for basic image":
  liquify-memoization(img-test, 0) is img-test
  liquify-memoization(img-test, 1) is image-data-to-image(2, 2, [list: 
      [list: color(4, 5, 6), color(7, 8, 9)],
      [list: color(10, 11, 12), color(16, 17, 18)]])
  liquify-memoization(img-test, 2) is image-data-to-image(1, 2, [list: 
      [list: color(4, 5, 6)],
      [list: color(10, 11, 12)]])
  liquify-memoization(energy-ties, 1).pixels is [list: 
    [list: color(1,0,0), color(1,0,0)], 
    [list: color(0,2,0), color(0,2,0)], 
    [list: color(0,0,3), color(0,0,3)]]
end
check "liquify memo works for image with energy ties":
  liquify-memoization(more-energy-ties, 1).pixels is [list:  
    [list: color(0,1,0), color(0,0,1)],
    [list: color(2,0,0), color(0,0,2)],
    [list: color(0,3,0), color(0,0,3)]]
  liquify-memoization(final-energy-ties, 1).pixels is [list:
    [list: color(100,0,0), color(100,0,0), color(100,0,0), color(100,0,0)],
    [list: color(4,0,0), color(3,1,0), color(1,3,0), color(0,4,0)],
    [list: color(3,0,1), color(1,2,1), color(0,3,1), color(2,0,2)],
    [list: color(1,1,2), color(1,0,3), color(0,1,3), color(0,0,4)]]
end
check "liquify memo works for larger image":
  liquify-memoization(big-img, 3).pixels is [list:
    [list:color(251,141,168), color(81,118,144), color(109,249,249), color(212,241,73), 
      color(204,115,183), color(9,195,114), color(191,151,183)], 
    [list:color(204,22,123), color(77,212,219), color(215,164,37), color(56,231,216), 
      color(86,150,51), color(71,9,194), color(161,148,42)], 
    [list:color(186,157,50), color(108,153,128), color(132,16,147), color(133,235,218), 
      color(18,248,143), color(214,135,107), color(198,217,141)], 
    [list:color(65,162,56), color(94,149,115), color(123,253,253), color(108,146,5), 
      color(197,3,61), color(45,144,209), color(47,124,77)], 
    [list:color(157,119,208), color(225,105,116), color(104,44,43), color(71,206,121), 
      color(101,13,122), color(199,30,114), color(177,77,170)], 
    [list:color(174,74,29), color(23,244,66), color(180,33,204), color(55,102,24), 
      color(227,19,229), color(145,247,140), color(149,49,162)], 
    [list:color(222,53,6), color(144,18,177), color(2,36,75), color(1,47,148), 
      color(195,38,157), color(98,208,125), color(16,51,115)], 
    [list:color(115,184,195), color(129,64,15), color(210,200,171), color(22,189,72), 
      color(55,77,248), color(36,25,144), color(125,144,120)], 
    [list:color(172,166,90), color(209,223,194), color(220,181,97), color(215,89,52), 
      color(57,93,41), color(65,81,59), color(173,34,153)], 
    [list:color(98,154,9), color(28,11,162), color(253,184,237), color(138,66,52), 
      color(86,126,101), color(26,120,22), color(218,218,115)]]
  liquify-memoization(wide-img, 1).pixels is [list:
    [list: 
      color(100.1, 100.2, 100.3), 
      color(200.1, 200.2, 200.3), 
      color(4.1, 5.2, 6.3), 
      color(100.1, 109.2, 209.3), 
      color(100.1, 102.2, 103.3), 
      color(20.1, 20.2, 20.3), 
      color(30.1, 30.2, 30.3), 
      color(20.1, 20.2, 20.3), 
      color(10.1, 10.2, 10.3)]]
  liquify-memoization(blank-img, 2).pixels is [list:
    [list: color(0, 0, 0)],
    [list: color(0, 0, 0)],
    [list: color(0, 0, 0)]]
  liquify-memoization(tall-img, 1).pixels is [list:
    [list: color(18,96,19)], [list: color(106,39,140)], 
    [list: color(30,48,38)], [list: color(29,48,179)], 
    [list: color(132,90,21)], [list: color(72,246,124)], 
    [list: color(116,80,230)], [list: color(108,141,39)], 
    [list: color(147,178,87)], [list: color(43,10,194)]]
end

check "liquify dp works for basic image":
  liquify-dynamic-programming(img-test, 0) is img-test
  liquify-dynamic-programming(img-test, 1) is image-data-to-image(2, 2, [list: 
      [list: color(4, 5, 6), color(7, 8, 9)],
      [list: color(10, 11, 12), color(16, 17, 18)]])
  liquify-dynamic-programming(img-test, 2) is image-data-to-image(1, 2, [list: 
      [list: color(4, 5, 6)],
      [list: color(10, 11, 12)]])
end
check "liquify dp works for image with energy ties":
  liquify-dynamic-programming(energy-ties, 1).pixels is [list: 
    [list: color(1,0,0), color(1,0,0)], 
    [list: color(0,2,0), color(0,2,0)], 
    [list: color(0,0,3), color(0,0,3)]]
  liquify-dynamic-programming(more-energy-ties, 1).pixels is [list:  
    [list: color(0,1,0), color(0,0,1)],
    [list: color(2,0,0), color(0,0,2)],
    [list: color(0,3,0), color(0,0,3)]]
  liquify-dynamic-programming(final-energy-ties, 1).pixels is [list:
    [list: color(100,0,0), color(100,0,0), color(100,0,0), color(100,0,0)],
    [list: color(4,0,0), color(3,1,0), color(1,3,0), color(0,4,0)],
    [list: color(3,0,1), color(1,2,1), color(0,3,1), color(2,0,2)],
    [list: color(1,1,2), color(1,0,3), color(0,1,3), color(0,0,4)]]
end
check "liquify dp works for larger image":
  liquify-dynamic-programming(big-img, 3).pixels is [list:
    [list:color(251,141,168), color(81,118,144), color(109,249,249), color(212,241,73), 
      color(204,115,183), color(9,195,114), color(191,151,183)], 
    [list:color(204,22,123), color(77,212,219), color(215,164,37), color(56,231,216), 
      color(86,150,51), color(71,9,194), color(161,148,42)], 
    [list:color(186,157,50), color(108,153,128), color(132,16,147), color(133,235,218), 
      color(18,248,143), color(214,135,107), color(198,217,141)], 
    [list:color(65,162,56), color(94,149,115), color(123,253,253), color(108,146,5), 
      color(197,3,61), color(45,144,209), color(47,124,77)], 
    [list:color(157,119,208), color(225,105,116), color(104,44,43), color(71,206,121), 
      color(101,13,122), color(199,30,114), color(177,77,170)], 
    [list:color(174,74,29), color(23,244,66), color(180,33,204), color(55,102,24), 
      color(227,19,229), color(145,247,140), color(149,49,162)], 
    [list:color(222,53,6), color(144,18,177), color(2,36,75), color(1,47,148), 
      color(195,38,157), color(98,208,125), color(16,51,115)], 
    [list:color(115,184,195), color(129,64,15), color(210,200,171), color(22,189,72), 
      color(55,77,248), color(36,25,144), color(125,144,120)], 
    [list:color(172,166,90), color(209,223,194), color(220,181,97), color(215,89,52), 
      color(57,93,41), color(65,81,59), color(173,34,153)], 
    [list:color(98,154,9), color(28,11,162), color(253,184,237), color(138,66,52), 
      color(86,126,101), color(26,120,22), color(218,218,115)]]
  liquify-dynamic-programming(wide-img, 1).pixels is [list:
    [list: 
      color(100.1, 100.2, 100.3), 
      color(200.1, 200.2, 200.3), 
      color(4.1, 5.2, 6.3), 
      color(100.1, 109.2, 209.3), 
      color(100.1, 102.2, 103.3), 
      color(20.1, 20.2, 20.3), 
      color(30.1, 30.2, 30.3), 
      color(20.1, 20.2, 20.3), 
      color(10.1, 10.2, 10.3)]]
  liquify-dynamic-programming(blank-img, 2).pixels is [list:
    [list: color(0, 0, 0)],
    [list: color(0, 0, 0)],
    [list: color(0, 0, 0)]]
  liquify-dynamic-programming(tall-img, 1).pixels is [list:
    [list: color(18,96,19)], [list: color(106,39,140)], 
    [list: color(30,48,38)], [list: color(29,48,179)], 
    [list: color(132,90,21)], [list: color(72,246,124)], 
    [list: color(116,80,230)], [list: color(108,141,39)], 
    [list: color(147,178,87)], [list: color(43,10,194)]]
end