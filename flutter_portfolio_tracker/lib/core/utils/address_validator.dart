abstract final class AddressValidator {
  static final _hexRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');

  static bool isValid(String address) => _hexRegex.hasMatch(address.trim());

  static String? errorMessage(String address) =>
      isValid(address) ? null : 'Must be 0x followed by 40 hex characters.';
}
