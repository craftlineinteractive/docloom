class IdCardLayout {
  const IdCardLayout._();

  static const int a4Width = 2480;
  static const int a4Height = 3508;
  static const int cardWidth = 1011;
  static const int cardHeight = 638;
  static const int leftMargin = (a4Width - cardWidth) ~/ 2; // 734
  static const int frontTop = 500;
  static const int cardGap = 200;
  static const int backTop = frontTop + cardHeight + cardGap; // 1338
}
