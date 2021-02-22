import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/futures/orders_list_future_provider.dart';
import 'widgets/order_card.dart';

class OrdersPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var ordersListStream = watch(ordersListFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: ordersListStream.when(
        data: (ordersList) => RefreshIndicator(
          onRefresh: () => context.refresh(ordersListFutureProvider),
          child: ListView(
            padding: EdgeInsets.all(4),
            children: ordersList
                .map((e) => OrderCard(
                      order: e,
                      key: Key(e.id),
                    ))
                .toList(),
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Text(error.toString()),
      ),
    );
  }
}
