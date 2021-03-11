import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_app/core/futures/areas_polygons_provider.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';

class AddressPage extends ConsumerWidget {
  final bool forEdit;
  AddressPage({this.forEdit = false});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var addressModel = watch(addressViewModelProvider);
    var areasPolygonsFuture = watch(areasPolygonsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(forEdit ? 'Edit Location Address' : 'Add Location Address'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                areasPolygonsFuture.when(
                  data: (areasPolygons) {
                    addressModel.setPolygons(areasPolygons);
                    return GoogleMap(
                      compassEnabled: true,
                      onCameraMove: addressModel.onCameraMove,
                      markers: addressModel.markers,
                      mapType: addressModel.mapType,
                      polygons: areasPolygons,
                      initialCameraPosition: addressModel.position,
                      onMapCreated: (controller) =>
                          addressModel.setController(controller),
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: RawMaterialButton(
                    elevation: 2,
                    child: Icon(
                      Icons.layers_outlined,
                    ),
                    onPressed: addressModel.toggleMapType,
                    constraints: BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    shape: CircleBorder(),
                    fillColor: Colors.white,
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.gps_not_fixed,
                    color: addressModel.mapType == MapType.normal
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.add,
                    size: 8,
                    color: addressModel.mapType == MapType.normal
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 104,
                  child: RawMaterialButton(
                    elevation: 2,
                    child: addressModel.loading
                        ? CircularProgressIndicator()
                        : Icon(Icons.gps_fixed),
                    onPressed: addressModel.gotoMyLocation,
                    constraints: BoxConstraints.tightFor(
                      width: 56.0,
                      height: 56.0,
                    ),
                    shape: CircleBorder(),
                    fillColor: Colors.white,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 104 + 56.0 + 8,
                  child: RawMaterialButton(
                    elevation: 2,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                    onPressed: addressModel.setMarker,
                    constraints: BoxConstraints.tightFor(
                      width: 56.0,
                      height: 56.0,
                    ),
                    shape: CircleBorder(),
                    fillColor: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 2,
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, left: 16, right: 16, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Address',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                              child: Text(addressModel.addressValue??
                                  "")),
                        ),
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        MaterialButton(
                          color: Theme.of(context).accentColor,
                          onPressed: addressModel.markers != null
                              ? () {
                                  forEdit
                                      ? addressModel.editAddress()
                                      : addressModel.addLocationAddress();
                                  Navigator.pop(context);
                                }
                              : null,
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
