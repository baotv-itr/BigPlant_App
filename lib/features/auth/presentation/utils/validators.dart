class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isPhoneNumber(String phone) {
    return RegExp(r'^0\d{9,10}$').hasMatch(phone);
  }
}
