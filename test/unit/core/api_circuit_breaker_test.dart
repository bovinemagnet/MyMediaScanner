import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/api_circuit_breaker.dart';

void main() {
  group('ApiCircuitBreaker', () {
    test('starts open (allows requests)', () {
      final breaker = ApiCircuitBreaker();
      expect(breaker.isOpen, isTrue);
    });

    test('blocks requests after trip()', () {
      final breaker = ApiCircuitBreaker();
      breaker.trip();
      expect(breaker.isOpen, isFalse);
    });

    test('allows requests again after reset()', () {
      final breaker = ApiCircuitBreaker();
      breaker.trip();
      expect(breaker.isOpen, isFalse);
      breaker.reset();
      expect(breaker.isOpen, isTrue);
    });

    test('allows requests after cooldown elapses', () {
      final breaker = ApiCircuitBreaker(
        cooldownDuration: Duration.zero,
      );
      breaker.trip();
      // With zero cooldown, should immediately allow
      expect(breaker.isOpen, isTrue);
    });

    test('blocks requests within cooldown window', () {
      final breaker = ApiCircuitBreaker(
        cooldownDuration: const Duration(hours: 1),
      );
      breaker.trip();
      expect(breaker.isOpen, isFalse);
    });
  });
}
