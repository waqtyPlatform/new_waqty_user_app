import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'provider_details_shared.dart';

class ProviderDetailsShimmer extends StatelessWidget {
  const ProviderDetailsShimmer({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SingleChildScrollView(
        child: Column(
          children: [
            _animate(
              const SizedBox(
                height: 250,
                width: double.infinity,
                child: ColoredBox(color: pdPlate),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  PdCard(
                    radius: 24,
                    child: _animate(
                      Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Bone(width: 170, height: 20),
                                    SizedBox(height: 8),
                                    _Bone(width: 210, height: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const _Bone(width: 100, height: 26),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _Bone(width: 145, height: 34),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Expanded(child: _Bone(height: 44)),
                              SizedBox(width: 8),
                              Expanded(child: _Bone(height: 44)),
                              SizedBox(width: 8),
                              Expanded(child: _Bone(height: 44)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _animate(const _Bone(height: 74, radius: 18)),
                  const SizedBox(height: 14),
                  _animate(const _Bone(height: 44)),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _animate(const _Bone(height: 76, radius: 18)),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: pd(context, 'back'),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const BackButtonIcon(),
                ),
              ),
              const Spacer(),
              _animate(const _Bone(width: 44, height: 44)),
              const SizedBox(width: 8),
              _animate(const _Bone(width: 44, height: 44)),
            ],
          ),
        ),
      ),
    ],
  );
  Widget _animate(Widget child) => Shimmer.fromColors(
    baseColor: const Color(0xFFE6E5E0),
    highlightColor: const Color(0xFFF6F6F3),
    child: child,
  );
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height, radius;
  const _Bone({this.width, required this.height, this.radius = 999});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: pdPlate,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
