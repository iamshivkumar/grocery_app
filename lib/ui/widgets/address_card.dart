import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_app/core/models/address.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';
import 'package:grocery_app/ui/address_page.dart';

class AddressCard extends StatefulWidget {
  final LocationAddress address;
  AddressCard({this.address});

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  GoogleMapController _controller;
  @override
  Widget build(BuildContext context) {
    var addressModel = context.read(addressViewModelProvider);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: Colors.white,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: GoogleMap(
                    key: Key(widget.address.value),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          widget.address.latitude, widget.address.longitude),
                      zoom: 17,
                    ),
                    onMapCreated: (value) => _controller = value,
                    markers: {
                      Marker(
                        markerId: MarkerId("1"),
                        position: LatLng(
                            widget.address.latitude, widget.address.longitude),
                      ),
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.address.value,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  MaterialButton(
                    child: Text('EDIT'),
                    onPressed: () async {
                      addressModel.initializeForEdit(address: widget.address);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddressPage(
                            forEdit: true,
                          ),
                        ),
                      );
                      await _controller.moveCamera(
                        CameraUpdate.newLatLng(
                          LatLng(widget.address.latitude,
                              widget.address.longitude),
                        ),
                      );
                    },
                    color: Theme.of(context).accentColor,
                  ),
                  TextButton(
                    onPressed: () => showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(
                          'Are you sure you want to delete "${widget.address.value}"',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('No'),
                          ),
                          MaterialButton(
                            onPressed: () {
                              addressModel.deleteAddress(
                                  address: widget.address);
                              Navigator.pop(context);
                            },
                            color: Theme.of(context).primaryColor,
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    ),
                    child: Text('DELETE'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
