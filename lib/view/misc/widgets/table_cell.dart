import 'package:flutter/material.dart';
import 'package:table_sticky_headers/cell_dimensions.dart';

class TableCell extends StatelessWidget {
  TableCell.content({
    this.text,
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 200),
    this.colorBg = Colors.transparent,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.legend(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 100),
    this.colorBg = Colors.blueGrey,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.transparent,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.stickyRow(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 100),
    this.colorBg = Colors.grey,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.end,
        _padding = EdgeInsets.zero;

  TableCell.stickyColumn(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 200),
    this.colorBg = Colors.grey,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.start,
        _padding = EdgeInsets.zero;

  final CellDimensions cellDimensions;

  final String? text;
  final Widget? child;
  final Function()? onTap;

  final double? cellWidth;
  final double? cellHeight;

  final Color colorBg;
  final Color _colorHorizontalBorder;
  final Color _colorVerticalBorder;

  final TextAlign _textAlign;
  final EdgeInsets _padding;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    assert(!(text == null && child == null),
        "Both text and child cannot be null.");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellWidth,
        height: cellHeight,
        padding: _padding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: text == null
                    ? child
                    : Text(
                        text!,
                        style: textStyle,
                        textAlign: _textAlign,
                      ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: _colorVerticalBorder),
            right: BorderSide(color: _colorHorizontalBorder),
            bottom: BorderSide(color: _colorVerticalBorder),
            left: BorderSide(color: _colorHorizontalBorder),
          ),
          color: colorBg,
        ),
      ),
    );
  }
}
