import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ReadContext on BuildContext {
  T read<T>() => Provider.of<T>(this, listen: false);
}

extension WatchContext on BuildContext {
  T watch<T>() => Provider.of<T>(this);
}
