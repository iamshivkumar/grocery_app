import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';
import 'address_page.dart';
import 'widgets/address_card.dart';

class AddressListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var addressModel = watch(addressViewModelProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addressModel.initializeForAdd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('My Address'),
      ),
      body: ListView(
        padding: EdgeInsets.all(2),
        children: addressModel.locationAddressList
            .map(
              (e) => AddressCard(address: e),
            )
            .toList(),
      ),
    );
  }
}
