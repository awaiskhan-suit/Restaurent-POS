/// All image asset paths live here, so screens never hard-code them.
/// Change the filename here only; every screen picks it up automatically.
class AppImages {
  AppImages._();

  static const String _base = 'assets/images';

  /// Welcome screen full-screen background (YOUR image).
  static const String welcomeBackground = '$_base/background.jpg';

  /// Food photos used by the sample data.
  static const String burger = '$_base/burger.jpg';
  static const String pasta = '$_base/pasta.jpg';
}