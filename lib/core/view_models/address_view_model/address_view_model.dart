import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:grocery_app/core/models/address.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressViewModel extends ChangeNotifier {
  GoogleMapController controller;

  void setController(GoogleMapController value) {
    controller = value;
  }
  
  bool _loading = false;
  bool get loading => _loading;

  List<LocationAddress> _locationAddressList = [];
  List<LocationAddress> get locationAddressList => _locationAddressList;

  LocationAddress _currentAddress;
  LocationAddress get currentAddress => _currentAddress;

  Future<void> registerLocalDatabase() async {
    saveLocationAddressList([]);
  }

  Future initializeData() async {
    try {
      _locationAddressList = await readLocationAddressList();
    } catch (e) {
      await registerLocalDatabase();
      _locationAddressList = await readLocationAddressList();
    }
    notifyListeners();
  }

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;

  CameraPosition _position = CameraPosition(
    target: LatLng(19.084383799507364, 72.88087688252803),
    zoom: 13,
  );
  CameraPosition get position => _position;
  Marker _marker;
  Set<Marker> get markers => _marker != null ? {_marker} : {};
  String addressValue;

  void toggleMapType() {
    _mapType == MapType.normal
        ? _mapType = MapType.hybrid
        : _mapType = MapType.normal;
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    _position = position;
  }

  Set<Polygon> _polygons;
  void setPolygons(Set<Polygon> value) {
    _polygons = value;
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (_rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1);
  }
  bool _rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;
    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; 
    }
    double m = (aY - bY) / (aX - bX);
    double bee = (-aX) * m + aY; 
    double x = (pY - bee) / m; 
    return x > pX;
  }

  void setMarker() {
    if (_checkIfValidMarker(_position.target, _polygons.first.points)) {
      _marker = Marker(
        markerId: MarkerId(
          _position.target.latitude.toString() +
              "," +
              _position.target.longitude.toString(),
        ),
        position: _position.target,
      );
      getAddressInfo();
      notifyListeners();
    }
  }

  Location _location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  void gotoMyLocation() async {
    _loading = true;
    notifyListeners();
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await _location.getLocation();
      _position = CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 18,
      );
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_position),
      );
    } catch (e) {
      print(e.toString());
    }
    _loading = false;
    notifyListeners();
  }

  void getAddressInfo() async {
    
    final coordinated =
        Coordinates(_marker.position.latitude, _marker.position.longitude);
    var addressInfo =
        await Geocoder.local.findAddressesFromCoordinates(coordinated);
    addressValue = addressInfo.first.addressLine;
    notifyListeners();
  }

  void initializeForEdit({LocationAddress address}) {
    _currentAddress = address;

    _marker = Marker(
      markerId: MarkerId('1'),
      position: LatLng(address.latitude, address.longitude),
    );
    _position = CameraPosition(
        target: LatLng(address.latitude, address.longitude), zoom: 17);
    addressValue = address.value;
  }

  void initializeForAdd() {
    _currentAddress = null;
    _marker = null;
    _position = CameraPosition(
      target: LatLng(19.084383799507364, 72.88087688252803),
      zoom: 15,
    );
    addressValue = null;
  }

  void addLocationAddress() {
    if(_marker!=null&&addressValue!=null){
    _locationAddressList.add(
      LocationAddress(
          value: addressValue,
          latitude: _marker.position.latitude,
          longitude: _marker.position.longitude),
    );
    notifyListeners();
    saveLocationAddressList(_locationAddressList);
    }
  }

  void editAddress() {
    _locationAddressList
        .where((element) => element == _currentAddress)
        .first
        .editAddress(
          newLatitude: _marker.position.latitude,
          newLongitude: _marker.position.longitude,
          newValue: addressValue,
        );

    saveLocationAddressList(_locationAddressList);
    notifyListeners();
  }

  void deleteAddress({LocationAddress address}) {
    _locationAddressList.remove(address);
    notifyListeners();
    saveLocationAddressList(_locationAddressList);
  }

  Future<List<LocationAddress>> readLocationAddressList() async {
    List<LocationAddress> list = [];
    final prefs = await SharedPreferences.getInstance();
    prefs.getStringList("address").forEach((element) {
      list.add(LocationAddress.fromJson(json.decode(element)));
    });
    return list;
  }

  void saveLocationAddressList(
      List<LocationAddress> listLocationAddress) async {
    List<String> list = [];
    final prefs = await SharedPreferences.getInstance();
    listLocationAddress.forEach((element) {
      list.add(json.encode(element.toJson()));
    });
    prefs.setStringList("address", list);
  }
}
