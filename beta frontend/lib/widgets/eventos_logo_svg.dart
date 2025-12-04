import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// EVENTOS logo rendered from the official SVG.
///
/// Usage:
///   const EventosLogoSvg(height: 40);              // uses SVG colors
///   const EventosLogoSvg(height: 40, color: Colors.white); // tinted
class EventosLogoSvg extends StatelessWidget {
  final double height;
  final Color? color;

  const EventosLogoSvg({
    super.key,
    required this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/eventos_logo.svg',
      height: height,
      fit: BoxFit.contain,
      // If color is provided, tint the whole logo:
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
