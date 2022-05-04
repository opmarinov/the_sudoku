import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/level_screen.dart';

import 'event_colors.dart';
import 'grid_item.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key, required this.level}) : super(key: key);

  final double level;

  final gridLength = 9;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<int>> grid = [[]];
  List<List<GridItem>> gridItems = [[]];

  var selectedCell = GridItem.empty();

  bool isSolved = false;

  double SQUARE_WIDTH = 0.0;
  double SQUARE_HEIGHT = 0.0;

  var _selectedIndex = 0;

  @override
  void initState() {
    grid = _generateGrid();

    super.initState();
  }

  _generateGrid() {
    var grid = _fillGridWithNegativeOne();

    var numbers = _generateUniqueNumberedArray(widget.gridLength);

    for (var i = 0; i < grid.length; i++) {
      var row = grid[i];

      fillRow(row, numbers);

      moveThree(grid, numbers, i);

      if (i == 2 || i == 5) {
        moveOne(grid, numbers, i);
      }
    }

    _shuffleBasic(grid);

    _shuffle3x3Rows(grid);

    remove(grid);

    gridItems = gridToGridItems(grid);

    return grid;
  }

  List<int> _generateUniqueNumberedArray(int length) {
    List<int> numbers = [];

    var random = Random();

    var randomNumber = random.nextInt(length);

    for (int i = 0; i < length; i++) {
      if (numbers.contains(randomNumber)) {
        while (numbers.contains(randomNumber)) {
          randomNumber = random.nextInt(length);
        }
      }

      numbers.add(randomNumber);
    }

    return numbers;
  }

  _fillGridWithNegativeOne() {
    var grid = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => -1,
      ),
    );

    return grid;
  }

  _getVisualGrid() {
    return List.generate(
      gridItems.length,
      (row) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          gridItems[row].length,
          (col) {
            var item = gridItems[row][col];

            return _createBox(item, row, col);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double level = widget.level;

    SQUARE_WIDTH = MediaQuery.of(context).size.height * 0.05;
    SQUARE_HEIGHT = SQUARE_WIDTH;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSolved ? const Text('Congrats !!!') : Container(),
            Text('Level: ${level.floor()}'),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getVisualGrid(),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                9,
                (value) => InkWell(
                  onTap: () {
                    try {
                      _enterValue(value);
                    } catch (err) {
                      print('error');
                    }
                  },
                  child: Container(
                    width: SQUARE_WIDTH - 5,
                    height: SQUARE_WIDTH - 5,
                    margin: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text('${value + 1}'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Select level',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Reset',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Remove',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  _removeValue(GridItem item) {
    var row = item.row;
    var col = item.col;

    gridItems[row][col].value = -1;
    gridItems[row][col].color = EventColors.MARKED_COLOR;

    setState(() {});
  }

  Container _createBox(GridItem item, row, col) {
    var value = item.value;

    return Container(
      width: SQUARE_WIDTH,
      height: SQUARE_WIDTH,
      decoration: BoxDecoration(
        border: _getBorder(row, col),
        color: item.color,
      ),
      child: item.isEditable
          ? InkWell(
              child: Center(
                child: value == -1 ? const Text('') : Text('${value + 1}'),
              ),
              onTap: () {
                selectedCell.row = row;
                selectedCell.col = col;

                // gridItems[row][col].color = Colors.grey.shade200;

                // clear previous
                _clearColors();

                // fill in
                _fillWithColor(EventColors.MARKED_COLOR, row, col);

                setState(() {});
              },
            )
          : Center(
              child: Text(
                '${value + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Border _getBorder(int row, int col) {
    return Border(
      top: BorderSide(
          width: row % 3 == 0 ? 3.0 : 0.0, color: EventColors.BORDER_COLOR),
      left: BorderSide(
          width: col % 3 == 0 ? 3.0 : 0.0, color: EventColors.BORDER_COLOR),
      right: BorderSide(
          width: col == 8 ? 3.0 : 0.0, color: EventColors.BORDER_COLOR),
      bottom: BorderSide(
          width: row == 8 ? 3.0 : 0.0, color: EventColors.BORDER_COLOR),
    );
  }

  void moveOne(grid, List<int> numbers, i) {
    var last = numbers[grid.length - 1];
    numbers.remove(last);
    numbers.insert(0, last);
  }

  void moveThree(grid, List<int> numbers, i) {
    var first = numbers[grid.length - 1];
    var second = numbers[grid.length - 2];
    var third = numbers[grid.length - 3];

    numbers.remove(first);
    numbers.insert(0, first);

    numbers.remove(second);
    numbers.insert(0, second);

    numbers.remove(third);
    numbers.insert(0, third);
  }

  _swapRows(grid, a, b) {
    var first = grid[a];
    var second = grid[b];

    grid[a] = second;
    grid[b] = first;
  }

  _swapCols(grid, a, b) {
    var columnA = _getColumn(grid, a);
    var columnB = _getColumn(grid, b);

    _swapColumnValues(grid, columnA, b);
    _swapColumnValues(grid, columnB, a);
  }

  _getColumn(grid, index) {
    List column = [];

    for (var row in grid) {
      column.add(row[index]);
    }

    return column;
  }

  _swapColumnValues(grid, values, column) {
    for (var i = 0; i < grid.length; i++) {
      var row = grid[i];

      row[column] = values[i];
    }
  }

  void _shuffle3x3Rows(grid) {
    var toSwap = _generateUniqueNumberedArray(3);

    for (var i = 1; i <= grid.length; i++) {
      if (i % 3 == 0) {
        for (var swapIndex in toSwap) {
          var index = i - 1;

          _swapRows(grid, index - 2, swapIndex);
          _swapRows(grid, index - 1, swapIndex);
          _swapRows(grid, index, swapIndex);

          toSwap = _generateUniqueNumberedArray(3);
        }
      }
    }
  }

  void _shuffleBasic(grid) {
    for (var i = 0; i < 3; ++i) {
      _swapRows(grid, i, i + 3);
      _swapCols(grid, i, i + 3);
    }
  }

  void fillRow(row, List<int> numbers) {
    for (var j = 0; j < row.length; j++) {
      var number = numbers[j];
      row[j] = number;
    }
  }

  void remove(grid) {
    var len = widget.gridLength;

    for (var i = 0; i < widget.level; i++) {
      var toRemoveRows = _generateUniqueNumberedArray(len);
      var toRemoveCols = _generateUniqueNumberedArray(len);

      for (var j = 0; j < len; j++) {
        var x = toRemoveRows[j];
        var y = toRemoveCols[j];

        grid[x][y] = -1;
      }
    }
  }

  List<List<GridItem>> _getSmallMatrix(grid, row, col) {
    List<List<GridItem>> result = [];

    for (var i = 0; i < 7; i += 3) {
      var startRow = i;
      var endRow = i + 2;

      if (row >= startRow && row <= endRow) {
        for (var j = 0; j < 7; j += 3) {
          var startCol = j;
          var endCol = j + 2;

          if (col >= startCol && col <= endCol) {
            result =
                _getMatrix(grid, startRow, endRow + 1, startCol, endCol + 1);
          }
        }
      }
    }

    return result;
  }

  List<List<GridItem>> _getMatrix(grid, x, x1, y, y1) {
    List<List<GridItem>> matrix = [];

    for (var i = x; i < x1; i++) {
      List<GridItem> row = [];

      for (var j = y; j < y1; j++) {
        row.add(grid[i][j]);
      }

      matrix.add(row);
    }

    return matrix;
  }

  List<List<GridItem>> gridToGridItems(List<List<int>> grid) {
    List<List<GridItem>> newGrid = [];

    for (var i = 0; i < grid.length; i++) {
      List<GridItem> rowItems = [];

      for (var j = 0; j < grid[i].length; ++j) {
        var value = grid[i][j];

        var row = i;
        var col = j;

        var isEditable = value == -1;

        var item =
            GridItem(row, col, value, EventColors.DEFAULT_COLOR, isEditable);

        rowItems.add(item);
      }

      newGrid.add(rowItems);
    }

    return newGrid;
  }

  void _fillWithColor(Color color, row, col) {
    var subrows = gridItems[row].sublist(0, col);
    var subrows2 = gridItems[row].sublist(col, gridItems.length);

    _fillInWithGradient(subrows.reversed, color);
    _fillInWithGradient(subrows2, color);

    List columns = _getColumn(gridItems, col);

    var subcolumns = columns.sublist(0, row);
    var subcolumns2 = columns.sublist(row, gridItems.length);

    _fillInWithGradient(subcolumns.reversed, color);
    _fillInWithGradient(subcolumns2, color);

    var matrix = _getSmallMatrix(gridItems, row, col);

    for (var row in matrix) {
      _fillInWithGradient(row, color);
    }
  }

  _fillInWithGradient(gridItems, color) {
    var opacity = 1.0;

    for (var row in gridItems) {
      if (row.color != EventColors.ERROR_COLOR) {
        row.color = color.withOpacity(opacity);
      }

      opacity -= 0.1;
    }
  }

  void _clearColors() {
    for (var i = 0; i < gridItems.length; i++) {
      for (var j = 0; j < gridItems[i].length; ++j) {
        if (gridItems[i][j].color == EventColors.ERROR_COLOR) continue;
        gridItems[i][j].color = EventColors.DEFAULT_COLOR;
      }
    }
  }

  _checkIfValueIsContainedIn3x3Matrix(value, rowIndex, colIndex) {
    var result = false;

    var matrix = _getSmallMatrix(gridItems, rowIndex, colIndex);

    for (List<GridItem> row in matrix) {
      var isContained = row.any((item) => item.value == value);

      if (isContained) {
        result = true;
        break;
      }
    }

    return result;
  }

  _enterValue(value) {
    var rowIndex = selectedCell.row;
    var colIndex = selectedCell.col;

    if (gridItems[rowIndex][colIndex].value == value) {
      return;
    }

    var row = gridItems[rowIndex].map((e) => e.value);
    var col = _getColumn(gridItems, colIndex).map((e) => e.value);

    var isInSmallMatrix =
        _checkIfValueIsContainedIn3x3Matrix(value, rowIndex, colIndex);

    var showError =
        row.contains(value) || col.contains(value) || isInSmallMatrix;

    if (showError) {
      gridItems[rowIndex][colIndex].color = EventColors.ERROR_COLOR;
    } else {
      gridItems[rowIndex][colIndex].color = EventColors.ENTERED_COLOR;
    }

    gridItems[rowIndex][colIndex].value = value;

    isSolved = _isSolved();

    if (isSolved) {
      for (var i = 0; i < gridItems.length; ++i) {
        for (var j = 0; j < gridItems[i].length; ++j) {
          _fillWithColor(Colors.orangeAccent, i, j);
        }
      }
    }

    setState(() {});
  }

  bool _isSolved() {
    for (var i = 0; i < gridItems.length; ++i) {
      for (var j = 0; j < gridItems[i].length; ++j) {
        var item = gridItems[i][j];

        if (item.color == Colors.red || item.value == -1) {
          return false;
        }
      }
    }

    return true;
  }

  void _onItemTapped(int value) {
    switch (value) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LevelScreen(),
          ),
        );
        break;
      case 1:
        grid = _generateGrid();
        setState(() {});
        break;
      case 2:
        try {
          _removeValue(selectedCell);
        } catch (error) {
          print(error);
        }
        break;
    }
  }
}
