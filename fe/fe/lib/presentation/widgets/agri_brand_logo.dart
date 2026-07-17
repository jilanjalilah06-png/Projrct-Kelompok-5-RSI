import 'package:flutter/material.dart';

/// AgriConnect brand logo widget that uses actual PNG image assets.
///
/// - When [showText] is false, renders just the round corn icon.
/// - When [showText] is true, renders the icon + "AgriConnect" text row.
/// - Set [useTextLogo] to true to show the horizontal text-logo image
///   (used inside the app after login — dashboards, profile headers, etc.).
class AgriBrandLogo extends StatelessWidget {
  final double iconSize;
  final TextStyle? textStyle;
  final Color? textColor;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showText;
  final Color? iconBackground;
  final double gap;

  /// When true, renders the horizontal text logo image (logo_text.png)
  /// instead of the icon + text layout.
  final bool useTextLogo;

  /// Optional height override for the text logo image.
  final double? textLogoHeight;

  const AgriBrandLogo({
    super.key,
    this.iconSize = 42,
    this.textStyle,
    this.textColor,
    this.subtitle,
    this.subtitleStyle,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showText = true,
    this.iconBackground,
    this.gap = 10,
    this.useTextLogo = false,
    this.textLogoHeight,
  });

  @override
  Widget build(BuildContext context) {
    // ── Text‑logo variant (used inside dashboards / headers) ──
    if (useTextLogo) {
      return Image.asset(
        'assets/logo_text.png',
        height: textLogoHeight ?? iconSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    // ── Round‑icon variant ──
    final logo = Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconBackground,
        shape: BoxShape.circle,
      ),
      clipBehavior: iconBackground != null ? Clip.antiAlias : Clip.none,
      child: ClipOval(
        child: Image.asset(
          'assets/logo_round.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );

    if (!showText) return logo;

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        logo,
        SizedBox(width: gap),
        Flexible(
          fit: mainAxisSize == MainAxisSize.min ? FlexFit.loose : FlexFit.tight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AgriConnect',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle ??
                    TextStyle(
                      color: textColor ?? const Color(0xFF1B5E20),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: subtitleStyle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
