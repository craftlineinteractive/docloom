class CameraPickerOption<T> {
  const CameraPickerOption({
    required this.value,
    required this.label,
    this.caption,
  });

  final T value;
  final String label;
  final String? caption;
}
