import 'package:flutter/material.dart';

class TwoTextRow extends StatelessWidget {
  final String text1;
  final String text2;
  TwoTextRow({@required this.text1, @required this.text2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text1),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text2,style: TextStyle(
            color: Theme.of(context).primaryColor
          ),),
        ),
      ],
    );
  }
}
