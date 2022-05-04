import 'dart:ui';

class GridItem {

  late int row;

  late int col;

  late int value;

  late Color color;

  late bool isEditable;

  GridItem.empty();

  GridItem(this.row, this.col, this.value, this.color, this.isEditable);
}