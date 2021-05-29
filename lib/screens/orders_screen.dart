import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return  Scaffold(
      appBar: AppBar(
        title: Text("Your orders"),
      ),
      body: ListView.builder(itemBuilder: (ctx, index) => {

      }, itemCount: ordersData.orders.length,),
    );
  }
}