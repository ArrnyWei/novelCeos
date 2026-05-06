import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/reading_theme.dart';
import '../../services/reading_settings_service.dart';
import '../../widgets/paginated_text.dart';
import '../../widgets/reading_settings_overlay.dart';
import 'reader_controller.dart';

/// Horizontal paginated reader — translates Swift's ReadPageViewController + DZMReadView.
/// Uses PageView instead of UIPageViewController.
class HorizontalReaderPage extends StatefulWidget {
  final ReaderController ctrl;
  const HorizontalReaderPage({super.key, required this.ctrl});

  @override
  State<HorizontalReaderPage> createState() => _HorizontalReaderPageState();
}

class _HorizontalReaderPageState extends State<HorizontalReaderPage> {
  final _pageController = PageController();
  List<String> _pages = [''];
  int _currentPage = 0;

  ReaderController get ctrl => widget.ctrl;

  @override
  void initState() {
    super.initState();
    // React to content changes
    ever(ctrl.chapterContent, (_) => _repaginate());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _repaginate() {
    if (!mounted) return;
    final settings = Get.find<ReadingSettingsService>();
    final padding = 24.w;
    final viewportWidth = MediaQuery.of(context).size.width - padding * 2;
    final viewportHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        60; // nav bar space

    final font = ReadingFont.findById(settings.fontFamilyId.value);
    final style = GoogleFonts.getFont(
      font.googleFontName,
      textStyle: TextStyle(
        fontSize: settings.fontSize.value,
        height: settings.lineSpacing.value,
        color: Color(settings.textColor.value),
      ),
    );

    final pages =
        paginateText(ctrl.chapterContent.value, style, Size(viewportWidth, viewportHeight));

    setState(() {
      _pages = pages;
      _currentPage = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onTapScreen(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final x = details.globalPosition.dx;

    if (x < screenWidth / 3) {
      // Left third → previous page
      _goToPrevPage();
    } else if (x > screenWidth * 2 / 3) {
      // Right third → next page
      _goToNextPage();
    } else {
      // Center → toggle settings overlay
      ctrl.showSettingsOverlay.toggle();
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else if (ctrl.hasPrev) {
      ctrl.prevChapter();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else if (ctrl.hasNext) {
      ctrl.nextChapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<ReadingSettingsService>();

    return Obx(() {
      final bgColor = Color(settings.backgroundColor.value);
      final txtColor = Color(settings.textColor.value);
      final font = ReadingFont.findById(settings.fontFamilyId.value);
      final style = GoogleFonts.getFont(
        font.googleFontName,
        textStyle: TextStyle(
          fontSize: settings.fontSize.value,
          height: settings.lineSpacing.value,
          color: txtColor,
        ),
      );

      // Re-paginate when settings change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctrl.chapterContent.value.isNotEmpty && _pages.length <= 1) {
          _repaginate();
        }
      });

      if (ctrl.isLoadingContent.value) {
        return Container(
          color: bgColor,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return GestureDetector(
        onTapUp: _onTapScreen,
        child: Container(
          color: bgColor,
          child: Stack(
            children: [
              // Page content
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 12.h),
                  child: Text(_pages[i], style: style),
                ),
              ),

              // Page indicator
              Positioned(
                bottom: 8.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: txtColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              // Settings overlay (toggle on center tap)
              Obx(() => ctrl.showSettingsOverlay.value
                  ? ReadingSettingsOverlay(
                      ctrl: ctrl,
                      onDismiss: () =>
                          ctrl.showSettingsOverlay.value = false,
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    });
  }
}
