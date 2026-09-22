import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flag asset loads via svg string loader', () async {
    final svgString = await rootBundle.loadString(
      'assets/flags/us.svg',
    );
    expect(svgString, isNotEmpty);

    final picture = await vg.loadPicture(
      SvgStringLoader(svgString),
      null,
    );
    expect(picture.size.width, greaterThan(0));
    expect(picture.size.height, greaterThan(0));
    picture.picture.dispose();
  });
}
