class BoothEntry {
  String booth;
  String espositore1;
  String espositore2;
  bool checked;

  BoothEntry({
    required this.booth,
    required this.espositore1,
    required this.espositore2,
    this.checked = false,
  });

  List<String> toList() => [booth, espositore1, espositore2, checked.toString()];

  static BoothEntry fromList(List<dynamic> values) {
    return BoothEntry(
      booth: values[0],
      espositore1: values[1],
      espositore2: values[2],
      checked: values[3].toLowerCase() == 'true',
    );
  }
}
