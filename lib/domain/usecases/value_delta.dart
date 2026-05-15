// Helpers for comparing price paid to current marketplace value.
//
// Author: Paul Snow
// Since: 0.0.0

/// Difference and percentage change between two prices. Returns nulls
/// when either side is missing or `pricePaid` is zero (so a `delta` of
/// e.g. "+£5 (∞%)" isn't shown to the user).
typedef ValueDelta = ({double? delta, double? deltaPercent});

ValueDelta computeValueDelta({
  required double? pricePaid,
  required double? currentValue,
}) {
  if (pricePaid == null || currentValue == null) {
    return (delta: null, deltaPercent: null);
  }
  if (pricePaid == 0) {
    return (delta: null, deltaPercent: null);
  }
  final delta = currentValue - pricePaid;
  return (delta: delta, deltaPercent: delta / pricePaid * 100);
}
