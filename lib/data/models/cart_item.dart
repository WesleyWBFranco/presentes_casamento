import 'package:presentes_casamento/data/models/present.dart';

class CartItem {
  final Present present;
  final String presentId;
  int selectedQuantity;

  CartItem({
    required this.present,
    required this.presentId,
    required this.selectedQuantity,
  });
}
