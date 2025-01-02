import 'package:flutter/material.dart';

class SettingItem extends StatefulWidget {
  final String name;
  final Function onTap;
  final bool initValue;

  const SettingItem({super.key, required this.name, required this.onTap, required this.initValue});

  @override
  _SettingItemState createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  bool isSwitched = false;

  @override
  void initState() {
    isSwitched = widget.initValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.name),
      trailing: Switch(
        value: isSwitched,
        onChanged: (value) {
          setState(() {
            isSwitched = value;
          });
          widget.onTap();
        },
      ),
      onTap: () {
        setState(() {
          isSwitched = !isSwitched;
          widget.onTap();
        });
      },
    );
  }
}