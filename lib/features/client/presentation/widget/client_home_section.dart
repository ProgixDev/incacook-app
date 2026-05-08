import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/features/client/presentation/widget/section_dots.dart';

class ClientHomeSection extends StatefulWidget {
  const ClientHomeSection({
    super.key,
    required this.title,
    required this.children,
    this.height = 300,
    this.viewportFraction = 0.92,
  });

  final String title;
  final List<Widget> children;
  final double height;
  final double viewportFraction;

  @override
  State<ClientHomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<ClientHomeSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handleScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              SectionDots(
                count: widget.children.length,
                activeIndex: _currentPage,
              ),
            ],
          ),
        ),
        const Gap(AppSizes.md),
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.children.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: widget.children[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
