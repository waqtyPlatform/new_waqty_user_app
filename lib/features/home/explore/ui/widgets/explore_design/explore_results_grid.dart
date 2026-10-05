part of '../explore_design_widgets.dart';

class ExploreResultsGrid extends StatelessWidget {
  const ExploreResultsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final places = explorePlaces;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          for (var i = 0; i < places.length; i += 2) ...[
            Row(children: _rowChildren(places, i)),
            if (i + 2 < places.length) SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }

  List<Widget> _rowChildren(List<ExplorePlaceData> places, int index) {
    final first = Expanded(child: ExplorePlaceCard(data: places[index]));
    final second = index + 1 < places.length
        ? Expanded(child: ExplorePlaceCard(data: places[index + 1]))
        : const Expanded(child: SizedBox.shrink());
    final gap = SizedBox(width: 12.w);

    return [first, gap, second];
  }
}
