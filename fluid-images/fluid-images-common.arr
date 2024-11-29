use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both
# fluid-images-code.arr and fluid-images-tests.arr
img-test = image-data-to-image(3, 2, [list:
    [list: color(1,2,3), color(4,5,6),  color(7,8,9)],
    [list: color(10,11,12), color(13,14,15),  color(16,17,18)]])

arr-test = array-from-list(img-test.pixels.map(array-from-list))

big-img = image-data-to-image(10, 10, [list:
    [list:
      color(251,141,168),
      color(81,118,144),
      color(109,249,249),
      color(212,241,73),
      color(28,70,90),
      color(204,115,183),
      color(9,195,114),
      color(199,210,96),
      color(80,87,193),
      color(191,151,183)],
    [list:
      color(204,22,123),
      color(77,212,219),
      color(215,164,37),
      color(144,47,2),
      color(56,231,216),
      color(86,150,51),
      color(230,210,145),
      color(71,9,194),
      color(14,252,97),
      color(161,148,42)],
    [list:
      color(186,157,50),
      color(108,153,128),
      color(234,76,30),
      color(132,16,147),
      color(133,235,218),
      color(18,248,143),
      color(214,135,107),
      color(60,252,116),
      color(49,104,157),
      color(198,217,141)],
    [list:
      color(65,162,56),
      color(94,149,115),
      color(67,118,54),
      color(123,253,253),
      color(108,146,5),
      color(197,3,61),
      color(45,144,209),
      color(234,254,63),
      color(43,39,157),
      color(47,124,77)],
    [list:
      color(157,119,208),
      color(225,105,116),
      color(24,120,248),
      color(104,44,43),
      color(71,206,121),
      color(101,13,122),
      color(199,30,114),
      color(68,193,169),
      color(114,155,220),
      color(177,77,170)],
    [list:
      color(174,74,29),
      color(23,244,66),
      color(180,33,204),
      color(165,17,220),
      color(55,102,24),
      color(227,19,229),
      color(26,76,222),
      color(145,247,140),
      color(13,18,0),
      color(149,49,162)],
    [list:
      color(222,53,6),
      color(144,18,177),
      color(2,36,75),
      color(246,38,46),
      color(1,47,148),
      color(195,38,157),
      color(146,159,48),
      color(246,44,29),
      color(98,208,125),
      color(16,51,115)],
    [list:
      color(115,184,195),
      color(129,64,15),
      color(210,200,171),
      color(22,189,72),
      color(171,217,203),
      color(40,139,197),
      color(55,77,248),
      color(36,25,144),
      color(52,212,189),
      color(125,144,120)],
    [list:
      color(172,166,90),
      color(209,223,194),
      color(220,181,97),
      color(215,89,52),
      color(51,254,73),
      color(123,149,98),
      color(57,93,41),
      color(216,79,136),
      color(65,81,59),
      color(173,34,153)],
    [list:
      color(98,154,9),
      color(28,11,162),
      color(253,184,237),
      color(138,66,52),
      color(86,126,101),
      color(40,101,184),
      color(163,238,122),
      color(20,52,142),
      color(26,120,22),
      color(218,218,115)]])
energy-ties = image-data-to-image(3, 3, [list: 
    [list: color(1,0,0), color(2,0,0), color(1,0,0)],
    [list: color(0,2,0), color(0,1,0), color(0,2,0)],
    [list: color(0,0,3), color(0,0,4), color(0,0,3)]])
energy-arr = array-from-list(energy-ties.pixels.map(array-from-list))
more-energy-ties = image-data-to-image(3, 3, [list:  
    [list: color(1,0,0), color(0,1,0), color(0,0,1)],
    [list: color(2,0,0), color(0,100,0), color(0,0,2)],
    [list: color(3,0,0), color(0,3,0), color(0,0,3)]])
more-energy-arr = array-from-list(more-energy-ties.pixels.map(array-from-list))
final-energy-ties = image-data-to-image(5, 4, [list:
    [list: color(100,0,0), color(100,0,0), color(0,0,0), color(100,0,0), color(100,0,0)],
    [list: color(4,0,0), color(3,1,0), color(2,2,0), color(1,3,0), color(0,4,0)],
    [list: color(3,0,1), color(2,1,1), color(1,2,1), color(0,3,1), color(2,0,2)],
    [list: color(1,1,2), color(0,2,2), color(1,0,3), color(0,1,3), color(0,0,4)]])

wide-img = image-data-to-image(10, 1, [list:
    [list: 
      color(100.1, 100.2, 100.3), 
      color(200.1, 200.2, 200.3), 
      color(4.1, 5.2, 6.3), 
      color(100.1, 109.2, 209.3), 
      color(100.1, 102.2, 103.3), 
      color(20.1, 20.2, 20.3), 
      color(30.1, 30.2, 30.3), 
      color(40.1, 40.2, 40.3), 
      color(20.1, 20.2, 20.3), 
      color(10.1, 10.2, 10.3)]])
blank-img = image-data-to-image(3, 3, [list:
    [list: color(0, 0, 0), color(0, 0, 0), color(0, 0, 0)],
    [list: color(0, 0, 0), color(0, 0, 0), color(0, 0, 0)],
    [list: color(0, 0, 0), color(0, 0, 0), color(0, 0, 0)]])
tall-img = image-data-to-image(2, 10, [list:
    [list:
      color(176,143,64),
      color(18,96,19)],
    [list:
      color(177,41,120),
      color(106,39,140)],
    [list:
      color(30,48,38),
      color(232,192,131)],
    [list:
      color(29,48,179),
      color(95,138,56)],
    [list:
      color(249,134,174),
      color(132,90,21)],
    [list:
      color(72,246,124),
      color(223,232,242)],
    [list:
      color(116,80,230),
      color(146,17,72)],
    [list:
      color(108,141,39),
      color(135,123,224)],
    [list:
      color(147,178,87),
      color(235,109,138)],
    [list:
      color(43,10,194),
      color(147,207,4)]])
