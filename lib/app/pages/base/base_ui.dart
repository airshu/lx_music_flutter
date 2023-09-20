

import 'package:flutter/material.dart';

class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key, required this.title});

  final String title;

  @override
  State<BaseStatefulWidget> createState() => BaseStatefulWidgetState();
}

class BaseStatefulWidgetState extends State<BaseStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



class BaseStatelessWidget extends StatelessWidget {
  const BaseStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
