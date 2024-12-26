import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  ReusableCard(
      {required this.colour,
      this.iconData,
      this.cardChild,
      required this.onPress});
  final Color colour;
  final Widget? cardChild;
  final IconData? iconData;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 350,
        height: 100,
        margin: const EdgeInsets.all(18.0),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colour,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Icon(
                iconData,
                size: 40,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: cardChild,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
