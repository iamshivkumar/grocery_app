class LocationAddress {
  String value;
  double latitude;
  double longitude;
  LocationAddress({this.latitude, this.longitude, this.value});

  factory LocationAddress.fromJson(Map<String, dynamic> json) {
    return LocationAddress(
        latitude: json['latitude'],
        longitude: json['longitude'],
        value: json['value']);
  }
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'value': value,
    };
  }

  void editAddress({double newLatitude, double newLongitude, String newValue}) {
    latitude = newLatitude;
    longitude = newLongitude;
    value = newValue;
  }
}
