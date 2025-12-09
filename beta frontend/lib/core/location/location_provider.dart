import 'package:flutter/material.dart';

/// Provider for managing selected location/city across the app
class LocationProvider extends ChangeNotifier {
  String? _selectedCity;

  LocationProvider({String? initialCity}) : _selectedCity = initialCity;

  /// Currently selected city
  String? get selectedCity => _selectedCity;

  /// Set selected city
  void setCity(String? city) {
    if (_selectedCity != city) {
      _selectedCity = city;
      notifyListeners();
    }
  }

  /// Clear selected city
  void clearCity() {
    if (_selectedCity != null) {
      _selectedCity = null;
      notifyListeners();
    }
  }

  /// Common Indian cities list
  static const List<String> cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Surat',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Patna',
    'Vadodara',
    'Ghaziabad',
  ];
}

