import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();

String newId() => const Uuid().v4();
