import 'package:flutter/foundation.dart';

@immutable
class Country {
  final String name; // e.g., "United States"
  final String isoCode; // e.g., "US"
  final String dialCode; // e.g., "+1"
  final String flag; // emoji flag

  const Country(this.name, this.isoCode, this.dialCode, this.flag);
}

const List<Country> kCountries = [
  Country('United States', 'US', '+1', '🇺🇸'),
  Country('Canada', 'CA', '+1', '🇨🇦'),
  Country('United Kingdom', 'GB', '+44', '🇬🇧'),
  Country('Ethiopia', 'ET', '+251', '🇪🇹'),
  Country('Eritrea', 'ER', '+291', '🇪🇷'),
  Country('United Arab Emirates', 'AE', '+971', '🇦🇪'),
  Country('Germany', 'DE', '+49', '🇩🇪'),
  Country('France', 'FR', '+33', '🇫🇷'),
  Country('Italy', 'IT', '+39', '🇮🇹'),
  Country('Kenya', 'KE', '+254', '🇰🇪'),
];
