import 'package:flutter/painting.dart';

/// Splits a long text into pages that each fit within [viewportSize].
/// Replaces Swift's Core Text CTFramesetterCreateFrame pagination.
List<String> paginateText(
  String text,
  TextStyle style,
  Size viewportSize,
) {
  if (text.isEmpty) return [''];

  final pages = <String>[];
  int startOffset = 0;

  while (startOffset < text.length) {
    final remaining = text.substring(startOffset);
    final painter = TextPainter(
      text: TextSpan(text: remaining, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: viewportSize.width);

    if (painter.height <= viewportSize.height) {
      // All remaining text fits on one page
      pages.add(remaining);
      break;
    }

    // Find the last line that fits within the viewport height
    final metrics = painter.computeLineMetrics();
    double accumulatedHeight = 0;
    int linesOnPage = 0;

    for (final line in metrics) {
      if (accumulatedHeight + line.height > viewportSize.height) break;
      accumulatedHeight += line.height;
      linesOnPage++;
    }

    if (linesOnPage == 0) {
      // Safety: at least one line per page
      linesOnPage = 1;
    }

    // Find the character offset at the end of the last visible line
    final lastLineBottom = metrics
        .take(linesOnPage)
        .fold<double>(0, (sum, m) => sum + m.height);
    final position = painter.getPositionForOffset(
      Offset(viewportSize.width, lastLineBottom - 1),
    );
    int endOffset = startOffset + position.offset;

    // Ensure we advance at least one character
    if (endOffset <= startOffset) {
      endOffset = startOffset + 1;
    }

    pages.add(text.substring(startOffset, endOffset));
    startOffset = endOffset;
  }

  return pages.isEmpty ? [''] : pages;
}
