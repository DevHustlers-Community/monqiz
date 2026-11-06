import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Re-export FaIcon and FaIconData for easy single-import access
export 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FaIcon, FaIconData;

/// MONQIZ Design System Icons
/// Standardized mapping from FontAwesome 6 as specified in `code.html`
abstract final class AppIcons {
  /// Droplet icon for Blood branding (fa-droplet)
  static const FaIconData droplet = FontAwesomeIcons.droplet;

  /// Shield Heart for visual identity & emergency protection (fa-shield-heart)
  static const FaIconData shieldHeart = FontAwesomeIcons.shieldHeart;

  /// Heart for pledge donation & primary CTA (fa-heart)
  static const FaIconData heart = FontAwesomeIcons.heart;

  /// Hospital for partner medical centers (fa-hospital)
  static const FaIconData hospital = FontAwesomeIcons.hospital;

  /// Share nodes for sharing emergency blood requests (fa-share-nodes)
  static const FaIconData share = FontAwesomeIcons.shareNodes;

  /// Phone volume for emergency 24/7 hotline 19888 (fa-phone-volume)
  static const FaIconData hotline = FontAwesomeIcons.phoneVolume;

  /// Magnifying glass for clinical search input (fa-magnifying-glass)
  static const FaIconData search = FontAwesomeIcons.magnifyingGlass;

  /// Chevron down for dropdown menus & selects (fa-chevron-down)
  static const FaIconData chevronDown = FontAwesomeIcons.chevronDown;

  /// Clock for remaining time countdown (fa-clock)
  static const FaIconData clock = FontAwesomeIcons.clock;

  /// Clinically verified shield (fa-shield-check / shield-halved)
  static const FaIconData shieldVerified = FontAwesomeIcons.shieldHalved;

  /// Location dot for distance and hospital address (fa-location-dot)
  static const FaIconData location = FontAwesomeIcons.locationDot;

  /// Circle check for donation eligibility (fa-circle-check)
  static const FaIconData eligible = FontAwesomeIcons.circleCheck;

  /// Hourglass for donation rest interval (fa-hourglass-half)
  static const FaIconData restInterval = FontAwesomeIcons.hourglassHalf;

  /// Fingerprint for biometric verified identity (fa-fingerprint)
  static const FaIconData fingerprint = FontAwesomeIcons.fingerprint;

  /// Door open for 24/7 emergency reception desk (fa-door-open)
  static const FaIconData doorOpen = FontAwesomeIcons.doorOpen;

  /// Certificate for Ministry of Health (MOH) accreditation (fa-certificate)
  static const FaIconData certificate = FontAwesomeIcons.certificate;

  /// Magic sparkles for Figma guidance (fa-wand-magic-sparkles)
  static const FaIconData sparkles = FontAwesomeIcons.wandMagicSparkles;

  /// Mobile device icon for layout preview (fa-mobile-screen-button)
  static const FaIconData mobile = FontAwesomeIcons.mobileScreenButton;

  /// System and feedback icons
  static const FaIconData circleExclamation = FontAwesomeIcons.circleExclamation;
  static const FaIconData rotateRight = FontAwesomeIcons.rotateRight;
  static const FaIconData user = FontAwesomeIcons.user;
  static const FaIconData lock = FontAwesomeIcons.lock;
  static const FaIconData envelope = FontAwesomeIcons.envelope;
  static const FaIconData phone = FontAwesomeIcons.phone;
  static const FaIconData calendar = FontAwesomeIcons.calendar;
  static const FaIconData mars = FontAwesomeIcons.mars;
  static const FaIconData venus = FontAwesomeIcons.venus;
  static const FaIconData circleCheck = FontAwesomeIcons.circleCheck;
  static const FaIconData check = FontAwesomeIcons.check;
  static const FaIconData arrowRight = FontAwesomeIcons.arrowRight;
  static const FaIconData arrowLeft = FontAwesomeIcons.arrowLeft;
  static const FaIconData plus = FontAwesomeIcons.plus;
  static const FaIconData minus = FontAwesomeIcons.minus;
  static const FaIconData eye = FontAwesomeIcons.eye;
  static const FaIconData eyeSlash = FontAwesomeIcons.eyeSlash;
}

/// Helper widget to render any Monqiz AppIcon cleanly
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  final dynamic icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (icon is FaIconData) {
      return FaIcon(icon as FaIconData, size: size, color: color);
    }
    if (icon is IconData) {
      return Icon(icon as IconData, size: size, color: color);
    }
    return const SizedBox.shrink();
  }
}
