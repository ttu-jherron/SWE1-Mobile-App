import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class AppHeaderHero extends StatelessWidget {
  final String titleLine1;
  final String titleLine2;
  final String subtitle;
  final ImageProvider image;
  final double imageScale;
  final double imageOffsetY;
  final double circleDiameter;
  final double circleOffsetY;
  final double belowSpacing; // new

  const AppHeaderHero({
    super.key,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    required this.image,
    this.imageScale = 1.0,
    this.imageOffsetY = 0.0,
    this.circleDiameter = 160,
    this.circleOffsetY = 0.0,
    this.belowSpacing = 0.0, // new
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Ebony clay header with a big rounded bottom-right corner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.xxl *
                    2.0, // Increase top padding for more vertical space
                Spacing.xl,
                Spacing.xxl, // Increase bottom padding for more vertical space
              ),
              decoration: const BoxDecoration(
                color: AppColors.ebonyClay,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(
                    50,
                  ), // Add curvature to bottom left
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment:
                    MainAxisAlignment.start, // Moves content to the top
                children: [
                  Transform.translate(
                    offset: const Offset(0, -50), // Move up by 20 pixels
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$titleLine1\n',
                            style: const TextStyle(
                              fontSize: TypographyScale.hero,
                              fontWeight: FontWeight.w800,
                              color: AppColors.sandyYellow,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: titleLine2,
                            style: const TextStyle(
                              fontSize: TypographyScale.hero,
                              fontWeight: FontWeight.w800,
                              color: AppColors.sandyYellow,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Transform.translate(
                    offset: const Offset(14, -60),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                      ), // Move slightly left
                      child: const Text(
                        "don’t buy. borrow.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: TypographyScale.subtitle,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Centered circular image below the header
            Center(
              child: Transform.translate(
                offset: Offset(0, circleOffsetY),
                child: SizedBox(
                  width: circleDiameter,
                  height: circleDiameter,
                  child: ClipOval(
                    child: Transform.translate(
                      offset: Offset(0, imageOffsetY),
                      child: Transform.scale(
                        scale: imageScale,
                        alignment: Alignment.center,
                        child: Image(image: image, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (belowSpacing > 0)
          SizedBox(height: belowSpacing), // pushes fields down
      ],
    );
  }
}
