import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Policy Screen"),
    );
  }
}
