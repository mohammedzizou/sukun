/// Validates the input based on the specified criteria.
///
/// The [val] parameter represents the input value to be validated.
/// The [min] parameter represents the minimum length allowed for the input.
/// The [max] parameter represents the maximum length allowed for the input.
/// The [type] parameter represents the type of input being validated.
///
/// Returns a localized error message if the input is invalid, otherwise returns null.
library;

import 'package:get/get.dart';

bool validCardNumber(String cardNumber) {
  // Remove any non-digit characters from the card number 
  cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

  // Check if the card number is empty or less than 13 digits
  if (cardNumber.isEmpty || cardNumber.length < 16) {
    return false;
  }

  // Reverse the card number and convert it to a list of integers
  List<int> digits = cardNumber.split('').map(int.parse).toList();
  digits = digits.reversed.toList();

  int sum = 0;
  bool isSecondDigit = false;

  // Perform the Luhn algorithm
  for (int digit in digits) {
    if (isSecondDigit) {
      digit *= 2;
      if (digit > 9) {
        digit -= 9;
      }
    }
    sum += digit;
    isSecondDigit = !isSecondDigit;
  }

  // Check if the sum is divisible by 10
  return sum % 10 == 0;
}

validInput(String val, int min, int max, String type) {
  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "337".tr;
    }
  }
  if (type == "Text") {
    if (!RegExp(r'[a-zA-Z]').hasMatch(val) ||
        RegExp(r'^[^a-zA-Z]+$').hasMatch(val)) {
      return "338".tr;
    }
  }

  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "339".tr;
    } else {
      return null;
    }
  }

  if (type == "number") {
    if (!GetUtils.isNum(val) || val.contains('.')) {
      return "340".tr;
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "341".tr;
    }
  }
  if (type == "double") {
    double? parsedValue = double.tryParse(val);
    if (parsedValue == null) {
      return "342".tr;
    }
  }

  if (type == "CreditCard") {
    if (val.isEmpty) {
      return "343".tr;
    }
    if (val.length < 19) {
      return "${"344".tr} 16";
    }
    if (val.length > 19) {
      return "${"345".tr} 16";
    }
    if (!validCardNumber(val)) {
      return "Card Number is not valid".tr;
    }
    return null;
  }

  if (val.isEmpty) {
    return "343".tr;
  }

  if (val.length < min) {
    return "${"344".tr} $min";
  }

  if (val.length > max) {
    return "${"345".tr} $max";
  }
}
