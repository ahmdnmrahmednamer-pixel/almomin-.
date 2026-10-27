import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/text/arabic_normalizer.dart';

void main() {
  group('Arabic Normalizer Golden Vectors', () {
    test('verifies all 7 golden vectors from JSON fixture', () {
      final file = File('test/fixtures/normalizer_vectors.json');
      final jsonString = file.readAsStringSync();
      final List<dynamic> cases = json.decode(jsonString);

      for (final caseData in cases) {
        final input = caseData['input'] as String;
        final expected = caseData['expected_loose'] as String;
        final desc = caseData['description'] as String;

        final actual = ArabicNormalizer.normalize(input, loose: true);
        expect(actual, equals(expected), reason: 'Failed case: $desc');
      }
    });

    test('search equivalence tests', () {
      expect(
        ArabicNormalizer.normalize('الرحمن'),
        equals(ArabicNormalizer.normalize('الرَّحْمَٰنِ')),
      );
      expect(
        ArabicNormalizer.normalize('الله'),
        equals(ArabicNormalizer.normalize('ٱللَّهُ')),
      );
      expect(
        ArabicNormalizer.normalize('موسى'),
        equals(ArabicNormalizer.normalize('مُوسَىٰ')),
      );
    });
  });
}
