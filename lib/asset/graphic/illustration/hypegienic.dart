import 'package:flutter/widgets.dart';

class HypegienicIllustration extends StatelessWidget {
  final Size size;
  final Color color;
  HypegienicIllustration({
    this.size = const Size(136.0, 100.5),
    this.color = const Color.fromRGBO(0, 0, 0, 1)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HypegienicIllustrationPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _HypegienicIllustrationPainter extends CustomPainter {
  final Color color;
  _HypegienicIllustrationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 272.0), (size.height / 201.0));
    [
      Path()
        ..moveTo(19.287640, 77.686517)
        ..lineTo(19.287640, 55.192135)
        ..cubicTo(19.287640, 51.097004, 20.744007, 47.593071, 23.656742, 44.680337)
        ..cubicTo(26.569476, 41.767603, 30.073408, 40.311236, 34.168539, 40.311236)
        ..cubicTo(38.263670, 40.311236, 41.767603, 41.767603, 44.680337, 44.680337)
        ..cubicTo(47.593071, 47.593071, 49.049438, 51.097004, 49.049438, 55.192135)
        ..lineTo(49.049438, 55.192135)
        ..lineTo(49.049438, 77.600000)
        ..lineTo(52.423595, 77.600000)
        ..lineTo(52.423595, 55.192135)
        ..cubicTo(52.423595, 50.174157, 50.635581, 45.877154, 47.059551, 42.301124)
        ..cubicTo(43.483521, 38.782772, 39.186517, 37.023595, 34.168539, 37.023595)
        ..cubicTo(31.169288, 37.023595, 28.357491, 37.715730, 25.733146, 39.100000)
        ..cubicTo(23.108801, 40.484270, 20.960300, 42.358801, 19.287640, 44.723596)
        ..lineTo(19.287640, 44.723596)
        ..lineTo(19.287640, 16.173034)
        ..lineTo(16.000000, 16.173034)
        ..lineTo(16.000000, 77.686517)
        ..lineTo(19.287640, 77.686517)
        ..close(),
      Path()
        ..moveTo(208.710112, 169.6)
        ..lineTo(208.710112, 129.023596)
        ..lineTo(205.422472, 129.023596)
        ..lineTo(205.422472, 169.6)
        ..lineTo(208.710112, 169.6)
        ..close(),
      Path()
        ..moveTo(59.101873, 37.023595)
        ..lineTo(62.389513, 37.023595)
        ..lineTo(62.389513, 57.312225)
        ..lineTo(62.395693, 57.311798)
        ..lineTo(62.401626, 57.648673)
        ..cubicTo(62.555049, 61.943153, 64.165993, 65.652023, 67.234457, 68.775281)
        ..cubicTo(70.522097, 72.005243, 74.458614, 73.620225, 79.044008, 73.620225)
        ..cubicTo(83.629401, 73.620225, 87.551498, 71.990824, 90.810300, 68.732022)
        ..cubicTo(93.986159, 65.556163, 95.614504, 61.750343, 95.695335, 57.314561)
        ..lineTo(95.698502, 57.312225)
        ..lineTo(95.698502, 37.023595)
        ..lineTo(98.986142, 37.023595)
        ..lineTo(98.986142, 73.706742)
        ..lineTo(98.974881, 74.402094)
        ..cubicTo(98.817220, 79.237028, 97.004120, 83.388764, 93.535580, 86.857303)
        ..cubicTo(90.067041, 90.325843, 85.915305, 92.138943, 81.080371, 92.296604)
        ..lineTo(80.385019, 92.307865)
        ..lineTo(80.038951, 92.307865)
        ..lineTo(79.467940, 92.297483)
        ..cubicTo(78.683521, 92.269798, 77.806816, 92.186742, 76.837828, 92.048315)
        ..cubicTo(75.626592, 91.875281, 73.997191, 91.514794, 71.949625, 90.966854)
        ..cubicTo(69.902060, 90.418914, 67.897753, 89.423970, 65.936704, 87.982022)
        ..cubicTo(64.171760, 86.684270, 62.710491, 85.082843, 61.552895, 83.177742)
        ..lineTo(61.178277, 82.531461)
        ..lineTo(60.313109, 81.060674)
        ..lineTo(63.254682, 79.416854)
        ..lineTo(64.033333, 80.887640)
        ..lineTo(64.372642, 81.462166)
        ..cubicTo(65.199058, 82.780647, 66.268352, 83.944569, 67.580524, 84.953933)
        ..cubicTo(69.080150, 86.107491, 70.464420, 86.929401, 71.733333, 87.419663)
        ..cubicTo(73.002247, 87.909925, 74.400936, 88.284831, 75.929401, 88.544382)
        ..lineTo(77.168755, 88.746831)
        ..cubicTo(77.904148, 88.861034, 78.457856, 88.933708, 78.829878, 88.964854)
        ..lineTo(79.000749, 88.976966)
        ..cubicTo(79.519850, 89.005805, 79.952434, 89.020225, 80.298502, 89.020225)
        ..cubicTo(84.566667, 89.020225, 88.200374, 87.520599, 91.199625, 84.521348)
        ..cubicTo(94.041021, 81.679953, 95.536492, 78.295011, 95.686040, 74.366523)
        ..lineTo(95.698502, 73.706742)
        ..lineTo(95.698502, 67.996629)
        ..lineTo(95.225964, 68.662929)
        ..cubicTo(93.452568, 71.064172, 91.230868, 73.004994, 88.560861, 74.485393)
        ..cubicTo(85.648127, 76.100375, 82.490262, 76.907865, 79.087266, 76.907865)
        ..cubicTo(73.550187, 76.907865, 68.835019, 74.961236, 64.941760, 71.067977)
        ..cubicTo(61.296630, 67.422848, 59.357908, 63.069875, 59.125594, 58.009059)
        ..lineTo(59.101873, 57.312225)
        ..lineTo(59.101873, 37.023595)
        ..close(),
      Path()
        ..moveTo(129.131086, 92.394382)
        ..lineTo(129.131086, 89.106742)
        ..lineTo(127.487266, 89.106742)
        ..cubicTo(125.814607, 89.106742, 124.372659, 88.501124, 123.161423,87.289888)
        ..cubicTo(121.950187, 86.078652, 121.344569, 84.607865, 121.344569,82.877528)
        ..lineTo(121.344569, 82.877528)
        ..lineTo(121.344569, 63.843820)
        ..cubicTo(121.344569, 62.113483, 120.911985, 60.512921, 120.046816,59.042135)
        ..cubicTo(119.181648, 57.571348, 117.999251, 56.403371, 116.499625,55.538202)
        ..lineTo(116.499625, 55.538202)
        ..lineTo(115.028839, 54.673034)
        ..lineTo(117.018727, 53.375281)
        ..cubicTo(119.902622, 51.529588, 121.344569, 48.876404, 121.344569,45.415730)
        ..lineTo(121.344569, 45.415730)
        ..lineTo(121.344569, 26.728090)
        ..cubicTo(121.344569, 25.055431, 121.950187, 23.613483, 123.161423,22.402247)
        ..cubicTo(124.372659, 21.191011, 125.814607, 20.585393, 127.487266,20.585393)
        ..lineTo(127.487266, 20.585393)
        ..lineTo(129.131086, 20.585393)
        ..lineTo(129.131086, 17.211236)
        ..lineTo(127.487266, 17.211236)
        ..cubicTo(124.891760, 17.211236, 122.656742, 18.148502, 120.782210,20.023034)
        ..cubicTo(118.907678, 21.897565, 117.970412, 24.132584, 117.970412,26.728090)
        ..lineTo(117.970412, 26.728090)
        ..lineTo(117.970412, 45.415730)
        ..cubicTo(117.970412, 47.665169, 117.047566, 49.395506, 115.201873,50.606742)
        ..lineTo(115.201873, 50.606742)
        ..lineTo(108.626592, 54.932584)
        ..lineTo(114.855805, 58.393258)
        ..cubicTo(116.932210, 59.604494, 117.970412, 61.421348, 117.970412,63.843820)
        ..lineTo(117.970412, 63.843820)
        ..lineTo(117.970412, 82.877528)
        ..cubicTo(117.970412, 85.530712, 118.907678, 87.780150, 120.782210,89.625843)
        ..cubicTo(122.656742, 91.471536, 124.891760, 92.394382, 127.487266,92.394382)
        ..lineTo(127.487266, 92.394382)
        ..lineTo(129.131086, 92.394382)
        ..close(),
      Path()
        ..moveTo(141.243446, 37.023595)
        ..lineTo(141.243446, 46.626966)
        ..lineTo(141.556001, 46.180230)
        ..cubicTo(143.355142, 43.677471, 145.630171, 41.663462, 148.381086,40.138202)
        ..cubicTo(151.293820, 38.523221, 154.480524, 37.715730, 157.941199,37.715730)
        ..cubicTo(163.420599, 37.715730, 168.106929, 39.662360, 172.000187,43.555618)
        ..cubicTo(175.893446, 47.448876, 177.840075, 52.149625, 177.840075,57.657865)
        ..cubicTo(177.840075, 63.166105, 175.893446, 67.866854, 172.000187,71.760112)
        ..cubicTo(168.106929, 75.653371, 163.420599, 77.600000, 157.941199,77.600000)
        ..cubicTo(154.480524, 77.600000, 151.293820, 76.792509, 148.381086,75.177528)
        ..cubicTo(145.630171, 73.652268, 143.355142, 71.638259, 141.556001,69.135501)
        ..lineTo(141.243446, 68.688764)
        ..lineTo(141.243446, 93.000000)
        ..lineTo(137.955805, 93.000000)
        ..lineTo(137.955805, 37.023595)
        ..lineTo(141.243446, 37.023595)
        ..close()
        ..moveTo(157.897940, 41.003371)
        ..cubicTo(153.312547, 41.003371, 149.390449, 42.632771, 146.131648,45.891573)
        ..cubicTo(142.872846, 49.150374, 141.243446, 53.072472, 141.243446,57.657865)
        ..cubicTo(141.243446, 62.243258, 142.858427, 66.179775, 146.088390,69.467416)
        ..cubicTo(149.376030, 72.697378, 153.312547, 74.312360, 157.897940,74.312360)
        ..cubicTo(162.483333, 74.312360, 166.405431, 72.682959, 169.664232,69.424157)
        ..cubicTo(172.923034, 66.165356, 174.552434, 62.243258, 174.552434,57.657865)
        ..cubicTo(174.552434, 53.072472, 172.923034, 49.150374, 169.664232,45.891573)
        ..cubicTo(166.405431, 42.632771, 162.483333, 41.003371, 157.897940,41.003371)
        ..close(),
      Path()
        ..moveTo(102.121348, 169.6)
        ..lineTo(102.121348, 129.023596)
        ..lineTo(98.8337079, 129.023596)
        ..lineTo(98.8337079, 169.6)
        ..lineTo(102.121348, 169.6)
        ..close(),
      Path()
        ..moveTo(206.563670, 37.802247)
        ..cubicTo(212.043071, 37.802247, 216.729401, 39.748876, 220.622659,43.642135)
        ..cubicTo(224.404682, 47.424157, 226.349722, 51.954580, 226.457780,57.233403)
        ..lineTo(226.462547, 57.701124)
        ..lineTo(226.462547, 59.344944)
        ..lineTo(189.952434, 59.344944)
        ..lineTo(190.004952, 59.784009)
        ..cubicTo(190.539758, 63.858908, 192.324687, 67.288583, 195.359738,70.073034)
        ..cubicTo(198.503184, 72.956929, 202.237828, 74.398876, 206.563670,74.398876)
        ..cubicTo(211.494307, 74.398876, 215.581293, 72.575501, 218.824627,68.928751)
        ..lineTo(220.233333, 67.304494)
        ..lineTo(222.742322, 69.467416)
        ..lineTo(221.287701, 71.146861)
        ..cubicTo(219.505873, 73.155409, 217.366402, 74.729676, 214.869288,75.869663)
        ..cubicTo(212.216105, 77.080899, 209.447566, 77.686517, 206.563670,77.686517)
        ..cubicTo(201.314981, 77.686517, 196.787266, 75.912921, 192.980524,72.365730)
        ..cubicTo(189.289139, 68.926030, 187.197692, 64.740595, 186.706185,59.809426)
        ..lineTo(186.664794, 59.344944)
        ..lineTo(186.578277, 59.344944)
        ..lineTo(186.578277, 56.749438)
        ..lineTo(186.664794, 56.057303)
        ..lineTo(186.706185, 55.592861)
        ..cubicTo(187.197692, 50.662539, 189.289139, 46.491511, 192.980524,43.079775)
        ..cubicTo(196.787266, 39.561423, 201.314981, 37.802247, 206.563670,37.802247)
        ..close()
        ..moveTo(206.520412, 41.089888)
        ..cubicTo(202.223408, 41.089888, 198.503184, 42.531835, 195.359738,45.415730)
        ..cubicTo(192.324687, 48.200181, 190.539758, 51.602971, 190.004952,55.624102)
        ..lineTo(189.952434, 56.057303)
        ..lineTo(223.088390, 56.057303)
        ..cubicTo(222.684644, 51.846817, 220.896629, 48.299625, 217.724345,45.415730)
        ..cubicTo(214.552060, 42.531835, 210.817416, 41.089888, 206.520412,41.089888)
        ..close(),
      Path()
        ..moveTo(236.844569, 92.394382)
        ..cubicTo(239.497753, 92.394382, 241.747191, 91.471536, 243.592884,89.625843)
        ..cubicTo(245.438577, 87.780150, 246.361423, 85.530712, 246.361423,82.877528)
        ..lineTo(246.361423, 82.877528)
        ..lineTo(246.361423, 63.843820)
        ..cubicTo(246.361423, 61.421348, 247.399625, 59.604494, 249.476030,58.393258)
        ..lineTo(249.476030, 58.393258)
        ..lineTo(255.705243, 54.932584)
        ..lineTo(249.129963, 50.606742)
        ..cubicTo(247.284270, 49.395506, 246.361423, 47.665169, 246.361423,45.415730)
        ..lineTo(246.361423, 45.415730)
        ..lineTo(246.361423, 26.728090)
        ..cubicTo(246.361423, 24.132584, 245.438577, 21.897565, 243.592884,20.023034)
        ..cubicTo(241.747191, 18.148502, 239.497753, 17.211236, 236.844569,17.211236)
        ..lineTo(236.844569, 17.211236)
        ..lineTo(235.200749, 17.211236)
        ..lineTo(235.200749, 20.585393)
        ..lineTo(236.844569, 20.585393)
        ..cubicTo(238.574906, 20.585393, 240.045693, 21.191011, 241.256929,22.402247)
        ..cubicTo(242.468165, 23.613483, 243.073783, 25.055431, 243.073783,26.728090)
        ..lineTo(243.073783, 26.728090)
        ..lineTo(243.073783, 45.415730)
        ..cubicTo(243.073783, 48.876404, 244.486891, 51.529588, 247.313109,53.375281)
        ..lineTo(247.313109, 53.375281)
        ..lineTo(249.389513, 54.673034)
        ..lineTo(247.918727, 55.538202)
        ..cubicTo(246.419101, 56.403371, 245.236704, 57.571348, 244.371536,59.042135)
        ..cubicTo(243.506367, 60.512921, 243.073783, 62.113483, 243.073783,63.843820)
        ..lineTo(243.073783, 63.843820)
        ..lineTo(243.073783, 82.877528)
        ..cubicTo(243.073783, 84.607865, 242.468165, 86.078652, 241.256929,87.289888)
        ..cubicTo(240.045693, 88.501124, 238.574906, 89.106742, 236.844569,89.106742)
        ..lineTo(236.844569, 89.106742)
        ..lineTo(235.200749, 89.106742)
        ..lineTo(235.200749, 92.394382)
        ..lineTo(236.844569, 92.394382)
        ..close(),
      Path()
        ..moveTo(88.884270, 129.715730)
        ..lineTo(88.884270, 166.398876)
        ..lineTo(88.879265, 166.863477)
        ..cubicTo(88.772489, 171.797189, 86.957303, 176.025843, 83.433708,179.549438)
        ..cubicTo(79.910112, 183.073034, 75.681459, 184.888219, 70.747747,184.994995)
        ..lineTo(70.283146, 185.000000)
        ..lineTo(69.937079, 185.000000)
        ..lineTo(69.584252, 184.995945)
        ..cubicTo(68.745219, 184.977019, 67.795787, 184.891854, 66.735955,184.740449)
        ..cubicTo(65.524719, 184.567416, 63.895318, 184.206929, 61.847753,183.658989)
        ..cubicTo(59.800187, 183.111049, 57.795880, 182.116105, 55.834831,180.674157)
        ..cubicTo(54.004519, 179.328340, 52.500792, 177.655937, 51.323650,175.656949)
        ..lineTo(51.076405, 175.223596)
        ..lineTo(50.211236, 173.752809)
        ..lineTo(53.152809, 172.108989)
        ..lineTo(53.931461, 173.579775)
        ..lineTo(54.136746, 173.935569)
        ..cubicTo(54.980413, 175.344412, 56.094382, 176.581245, 57.478652,177.646067)
        ..cubicTo(58.978277, 178.799625, 60.362547, 179.621536, 61.631461,180.111798)
        ..cubicTo(62.900374, 180.602060, 64.299064, 180.976966, 65.827528,181.236517)
        ..lineTo(66.942634, 181.419548)
        ..cubicTo(67.866122, 181.564768, 68.518202, 181.647953, 68.898876,181.669101)
        ..lineTo(69.480270, 181.696787)
        ..cubicTo(69.750202, 181.707169, 69.988989, 181.712360, 70.196629,181.712360)
        ..cubicTo(74.464794, 181.712360, 78.098502, 180.212734, 81.097753,177.213483)
        ..cubicTo(83.997029, 174.314207, 85.494988, 170.849015, 85.591630,166.817906)
        ..lineTo(85.596629, 166.398876)
        ..lineTo(85.596629, 160.688764)
        ..lineTo(85.284074, 161.135501)
        ..cubicTo(83.484933, 163.638259, 81.209904, 165.652268, 78.458989,167.177528)
        ..cubicTo(75.546255, 168.792509, 72.388390, 169.600000, 68.985393,169.600000)
        ..cubicTo(63.448315, 169.600000, 58.733146, 167.653371, 54.839888,163.760112)
        ..cubicTo(50.946629, 159.866854, 49.000000, 155.166105, 49.000000,149.657865)
        ..cubicTo(49.000000, 144.149625, 50.946629, 139.448876, 54.839888,135.555618)
        ..cubicTo(58.733146, 131.662360, 63.448315, 129.715730, 68.985393,129.715730)
        ..cubicTo(72.388390, 129.715730, 75.546255, 130.523221, 78.458989,132.138202)
        ..cubicTo(81.218421, 133.668185, 83.499015, 135.715830, 85.300770,138.281139)
        ..lineTo(85.596629, 138.713483)
        ..lineTo(85.596629, 129.715730)
        ..lineTo(88.884270, 129.715730)
        ..close()
        ..moveTo(68.942135, 133.003371)
        ..cubicTo(64.356742, 133.003371, 60.434644, 134.632772, 57.175843,137.891573)
        ..cubicTo(53.917041, 141.150375, 52.287640, 145.072472, 52.287640,149.657865)
        ..cubicTo(52.287640, 154.243258, 53.902622, 158.179775, 57.132584,161.467416)
        ..cubicTo(60.420225, 164.697378, 64.356742, 166.312360, 68.942135,166.312360)
        ..cubicTo(73.527528, 166.312360, 77.449625, 164.682959, 80.708427,161.424157)
        ..cubicTo(83.967229, 158.165356, 85.596629, 154.243258, 85.596629,149.657865)
        ..cubicTo(85.596629, 145.072472, 83.967229, 141.150375, 80.708427,137.891573)
        ..cubicTo(77.449625, 134.632772, 73.527528, 133.003371, 68.942135,133.003371)
        ..close(),
      Path()
        ..moveTo(100.434270, 113.710112)
        ..cubicTo(101.212921, 113.710112, 101.890637, 113.450562, 102.467416,112.931461)
        ..cubicTo(103.044195, 112.354682, 103.332584, 111.662547, 103.332584,110.855056)
        ..cubicTo(103.332584, 110.047566, 103.044195, 109.369850, 102.467416,108.821910)
        ..cubicTo(101.890637, 108.273970, 101.212921, 108.000000, 100.434270,108.000000)
        ..cubicTo(99.655618, 108.000000, 98.992322, 108.273970, 98.444382, 108.821910)
        ..cubicTo(97.896442, 109.369850, 97.622472, 110.047566, 97.622472,110.855056)
        ..cubicTo(97.622472, 111.662547, 97.896442, 112.340262, 98.444382,112.888202)
        ..cubicTo(98.992322, 113.436142, 99.655618, 113.710112, 100.434270,113.710112)
        ..close(),
      Path()
        ..moveTo(131.969663, 129.802247)
        ..cubicTo(137.449064, 129.802247, 142.135393, 131.748876, 146.028652,135.642135)
        ..cubicTo(149.810674, 139.424157, 151.755714, 143.954580, 151.863772,149.233403)
        ..lineTo(151.868539, 149.701124)
        ..lineTo(151.868539, 151.344944)
        ..lineTo(115.358427, 151.344944)
        ..lineTo(115.410944, 151.784009)
        ..cubicTo(115.945751, 155.858908, 117.730679, 159.288583, 120.765730,162.073034)
        ..cubicTo(123.909176, 164.956929, 127.643820, 166.398876, 131.969663,166.398876)
        ..cubicTo(136.900300, 166.398876, 140.987285, 164.575501, 144.230620,160.928751)
        ..lineTo(145.639326, 159.304494)
        ..lineTo(148.148315, 161.467416)
        ..lineTo(146.693694, 163.146861)
        ..cubicTo(144.911866, 165.155409, 142.772395, 166.729676, 140.275281,167.869663)
        ..cubicTo(137.622097, 169.080899, 134.853558, 169.686517, 131.969663,169.686517)
        ..cubicTo(126.720974, 169.686517, 122.193258, 167.912921, 118.386517,164.365730)
        ..cubicTo(114.695131, 160.926030, 112.603685, 156.740595, 112.112178,151.809426)
        ..lineTo(112.070787, 151.344944)
        ..lineTo(111.984270, 151.344944)
        ..lineTo(111.984270, 148.749438)
        ..lineTo(112.070787, 148.057303)
        ..lineTo(112.112178, 147.592861)
        ..cubicTo(112.603685, 142.662539, 114.695131, 138.491511, 118.386517,135.079775)
        ..cubicTo(122.193258, 131.561423, 126.720974, 129.802247, 131.969663,129.802247)
        ..close()
        ..moveTo(131.926404, 133.089888)
        ..cubicTo(127.629401, 133.089888, 123.909176, 134.531835, 120.765730,137.415730)
        ..cubicTo(117.730679, 140.200181, 115.945751, 143.602971, 115.410944,147.624102)
        ..lineTo(115.358427, 148.057303)
        ..lineTo(148.494382, 148.057303)
        ..cubicTo(148.090637, 143.846816, 146.302622, 140.299625, 143.130337,137.415730)
        ..cubicTo(139.958052, 134.531835, 136.223408, 133.089888, 131.926404,133.089888)
        ..close(),
      Path()
        ..moveTo(163.894382, 169.686517)
        ..lineTo(163.894382, 146.413483)
        ..cubicTo(163.894382, 142.549064, 165.278652, 139.232584, 168.047191,136.464045)
        ..cubicTo(170.815730, 133.695506, 174.146629, 132.311236, 178.039888,132.311236)
        ..cubicTo(181.933146, 132.311236, 185.249625, 133.695506, 187.989326,136.464045)
        ..cubicTo(190.729026, 139.232584, 192.098876, 142.549064, 192.098876,146.413483)
        ..lineTo(192.098876, 146.413483)
        ..lineTo(192.098876, 169.686517)
        ..lineTo(195.386517, 169.686517)
        ..lineTo(195.386517, 146.413483)
        ..cubicTo(195.386517, 141.626217, 193.685019, 137.531086, 190.282022,134.128090)
        ..cubicTo(186.879026, 130.725094, 182.783895, 129.023596, 177.996629,129.023596)
        ..cubicTo(175.170412, 129.023596, 172.517228, 129.672472, 170.037079,130.970225)
        ..cubicTo(167.556929, 132.267978, 165.509363, 134.012734, 163.894382,136.204494)
        ..lineTo(163.894382, 136.204494)
        ..lineTo(163.894382, 129.023596)
        ..lineTo(160.606742, 129.023596)
        ..lineTo(160.606742, 169.686517)
        ..lineTo(163.894382, 169.686517)
        ..close(),
      Path()
        ..moveTo(207.023034, 113.710112)
        ..cubicTo(207.801685, 113.710112, 208.479401, 113.450562, 209.056180,112.931461)
        ..cubicTo(209.632959, 112.354682, 209.921348, 111.662547, 209.921348,110.855056)
        ..cubicTo(209.921348, 110.047566, 209.632959, 109.369850, 209.056180,108.821910)
        ..cubicTo(208.479401, 108.273970, 207.801685, 108.000000, 207.023034,108.000000)
        ..cubicTo(206.244382, 108.000000, 205.581086, 108.273970, 205.033146,108.821910)
        ..cubicTo(204.485206, 109.369850, 204.211236, 110.047566, 204.211236,110.855056)
        ..cubicTo(204.211236, 111.662547, 204.485206, 112.340262, 205.033146,112.888202)
        ..cubicTo(205.581086, 113.436142, 206.244382, 113.710112, 207.023034,113.710112)
        ..close(),
      Path()
        ..moveTo(238.558427, 169.686517)
        ..cubicTo(241.673034, 169.686517, 244.643446, 168.965543, 247.469663,167.523596)
        ..cubicTo(250.295880, 166.081648, 252.660674, 164.120599, 254.564045,161.640449)
        ..lineTo(254.564045, 161.640449)
        ..lineTo(255.515730, 160.256180)
        ..lineTo(252.833708, 158.352809)
        ..lineTo(251.882022, 159.650562)
        ..cubicTo(250.267041, 161.784644, 248.305993, 163.442884, 245.998876,164.625281)
        ..cubicTo(243.691760, 165.807678, 241.211610, 166.398876, 238.558427,166.398876)
        ..cubicTo(233.944195, 166.398876, 230.007678, 164.769476, 226.748876,161.510674)
        ..cubicTo(223.490075, 158.251873, 221.860674, 154.329775, 221.860674,149.744382)
        ..cubicTo(221.860674, 145.158989, 223.490075, 141.236891, 226.748876,137.978090)
        ..cubicTo(230.007678, 134.719288, 233.944195, 133.089888, 238.558427,133.089888)
        ..cubicTo(241.153933, 133.089888, 243.648502, 133.695506, 246.042135,134.906742)
        ..cubicTo(248.435768, 136.117978, 250.411236, 137.790637, 251.968539,139.924719)
        ..lineTo(251.968539, 139.924719)
        ..lineTo(252.920225, 141.222472)
        ..lineTo(255.602247, 139.319101)
        ..lineTo(254.650562, 137.934831)
        ..cubicTo(252.747191, 135.397004, 250.367978, 133.407116, 247.512921,131.965169)
        ..cubicTo(244.657865, 130.523221, 241.673034, 129.802247, 238.558427,129.802247)
        ..cubicTo(233.021348, 129.802247, 228.306180, 131.748876, 224.412921,135.642135)
        ..cubicTo(220.519663, 139.535393, 218.573034, 144.236142, 218.573034,149.744382)
        ..cubicTo(218.573034, 155.252622, 220.519663, 159.953371, 224.412921,163.846629)
        ..cubicTo(228.306180, 167.739888, 233.021348, 169.686517, 238.558427,169.686517)
        ..close()
    ].forEach((path) {
      final fill = Paint()
        ..color = color;
      canvas.drawPath(path, fill);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color;
      canvas.drawPath(path, stroke);
    });
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
