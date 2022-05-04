class SudokuUtils<T> {

  List<List<T>> getCellMatrix(List<List<T>> matrix, int row, int col) {
    List<List<T>> result = [];

    for (var i = 0; i < 7; i += 3) {
      var startRow = i;
      var endRow = i + 2;

      if (row >= startRow && row <= endRow) {
        for (var j = 0; j < 7; j += 3) {
          var startCol = j;
          var endCol = j + 2;

          if (col >= startCol && col <= endCol) {
            result = _subsetMatrix(
                matrix, startRow, endRow + 1, startCol, endCol + 1);
          }
        }
      }
    }

    return result;
  }

  List<List<T>> _subsetMatrix(
      List<List<T>> matrix, int x, int x1, int y, int y1) {
    List<List<T>> matrix = [];

    for (var i = x; i < x1; i++) {
      List<T> row = [];

      for (var j = y; j < y1; j++) {
        row.add(matrix[i][j]);
      }

      matrix.add(row);
    }

    return matrix;
  }
}
