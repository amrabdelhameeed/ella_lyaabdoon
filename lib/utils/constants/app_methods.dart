// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart' as sv;

class AppMethods {
  AppMethods._(); // Private constructor

  static var numFormatter = NumberFormat.decimalPattern('en_us');

  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  static DateTime getDateFormatted(DateTime date) {
    return dateFormat.parse(date.toString());
  }

  static Color getTextColor(num percentageDifference) {
    return percentageDifference >= 0 ? Colors.green : Colors.red;
  }

  static String getFirstTwoWords(String name) {
    // Split the string by spaces
    List<String> words = name.split(' ');

    // Return the first two words, joined by a space
    // If there are fewer than two words, just return the available ones
    return words.take(2).join(' ');
  }

  static bool isDarkMode(context) =>
      Theme.of(context).brightness == Brightness.dark;

  static double _calculatePercentage(int upvotes, int downvotes) {
    if (upvotes == 0 && downvotes == 0) {
      return -1;
    } else if (upvotes == 0) {
      return 0;
    } else if (downvotes == 0) {
      return 1;
    }

    return (upvotes / (upvotes + downvotes));
  }

  static String getCategoryLabel(int currentPage) {
    if (currentPage == 0) {
      return "Weekly Voting".tr();
    } else if (currentPage == 1) {
      return "Monthly Voting".tr();
    } else if (currentPage == 2) {
      return "Six-Month Voting".tr();
    } else {
      return "Yearly Voting".tr();
    }
  }

  static double calculateTotalPriceWithFees(
    String city,
    double initialPrice, {
    bool justFees = true,
  }) {
    double shippingFee = 0.0;

    if (city == 'Alexandria') {
      if (initialPrice >= 1000000) {
        shippingFee = 300.0;
      } else if (initialPrice >= 900000) {
        shippingFee = 295.0;
      } else if (initialPrice >= 700000) {
        shippingFee = 285.0;
      } else if (initialPrice >= 500000) {
        shippingFee = 275.0;
      } else if (initialPrice >= 300000) {
        shippingFee = 270.0;
      } else if (initialPrice >= 100000) {
        shippingFee = 265.0;
      } else {
        shippingFee = 260.0;
      }
    } else if (city == 'Aswan') {
      if (initialPrice <= 1000000) {
        shippingFee = 450.0;
      }
    } else if (city == 'Asyut') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Beheira') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Beni Suef') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Cairo') {
      if (initialPrice >= 1000000) {
        shippingFee = 250.0;
      } else if (initialPrice >= 900000) {
        shippingFee = 240.0;
      } else if (initialPrice >= 700000) {
        shippingFee = 230.0;
      } else if (initialPrice >= 500000) {
        shippingFee = 220.0;
      } else if (initialPrice >= 300000) {
        shippingFee = 190.0;
      } else if (initialPrice >= 100000) {
        shippingFee = 180.0;
      } else {
        shippingFee = 170.0;
      }
    } else if (city == 'Dakahlia') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Damietta') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Faiyum') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Gharbia') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Giza') {
      if (initialPrice >= 1000000) {
        shippingFee = 275.0;
      } else if (initialPrice >= 900000) {
        shippingFee = 265.0;
      } else if (initialPrice >= 700000) {
        shippingFee = 255.0;
      } else if (initialPrice >= 500000) {
        shippingFee = 225.0;
      } else if (initialPrice >= 300000) {
        shippingFee = 215.0;
      } else if (initialPrice >= 100000) {
        shippingFee = 205.0;
      } else {
        shippingFee = 195.0;
      }
    } else if (city == 'Ismailia') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Kafr el-Sheikh') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Luxor') {
      if (initialPrice <= 1000000) {
        shippingFee = 450.0;
      }
    } else if (city == 'Matrouh') {
      if (initialPrice <= 1000000) {
        shippingFee = 500.0;
      }
    } else if (city == 'Minya') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Monufia') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Port Said') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Qalyubia') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Qena') {
      if (initialPrice <= 1000000) {
        shippingFee = 450.0;
      }
    } else if (city == 'Red Sea') {
      if (initialPrice <= 1000000) {
        shippingFee = 450.0;
      }
    } else if (city == 'Sharqia') {
      if (initialPrice <= 1000000) {
        shippingFee = 300.0;
      }
    } else if (city == 'Sohag') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else if (city == 'Suez') {
      if (initialPrice <= 1000000) {
        shippingFee = 350.0;
      }
    } else {
      return 0.0;
    }

    if (justFees) {
      // Return just the shipping fee
      return shippingFee;
    } else {
      double totalPriceWithFees = initialPrice + shippingFee;
      return totalPriceWithFees;
    }
  }

  static Color getRandomColor({bool isDark = false}) {
    int red = Random().nextInt(256);
    int green = Random().nextInt(256);
    int blue = Random().nextInt(256);
    double alpha = Random().nextDouble();
    if (isDark) {
      // Generate a darker color by reducing the color components
      red = (red * 0.5).floor();
      green = (green * 0.5).floor();
      blue = (blue * 0.5).floor();
    } else {
      // Generate a lighter color by increasing the color components
      red = (red * 2).floor().clamp(0, 255);
      green = (green * 2).floor().clamp(0, 255);
      blue = (blue * 2).floor().clamp(0, 255);
    }

    return Color.fromRGBO(red, green, blue, alpha);
  }

  static Color getCustomColorForSection(String sectionName) {
    Color defaultColor = Colors.grey; // A neutral gray color

    if (sectionName == "Financial Results") {
      return Colors.blue; // Good contrast with both black and white
    } else if (sectionName == "Announcements") {
      return Colors.red; // Good contrast with both black and white
    } else if (sectionName == "Shareholding Structure") {
      return Colors.deepOrange; // Good contrast with both black and white
    } else if (sectionName == "General Assemblies") {
      return Colors.green; // Good contrast with both black and white
    } else if (sectionName == "Financial Statements") {
      return Colors.purple; // Good contrast with both black and white
    } else if (sectionName == "General") {
      return Colors.amber; // Good contrast with both black and white
    }

    return defaultColor;
  }

  static String processHtmlWithPdfLinks(String htmlContent) {
    final document = htmlParser.parse(htmlContent);

    // Find all anchor (<a>) elements in the HTML document.
    final anchorElements = document.querySelectorAll('a');

    // Iterate through the anchor elements to check for links ending with ".pdf."
    for (final anchor in anchorElements) {
      final hrefAttribute = anchor.attributes['href'];
      // Check if the href attribute exists and ends with ".pdf."
      if (hrefAttribute != null &&
          hrefAttribute.endsWith('.pdf') &&
          hrefAttribute.startsWith('/') &&
          !hrefAttribute.contains('.com')) {
        // Check if the link is a relative link (starts with "/") or already has "www." in it.
        anchor.attributes['href'] = 'https://egx.com.eg$hrefAttribute';
      }
    }

    // Convert the modified HTML document back to a string.
    final processedHtml = document.outerHtml;

    return processedHtml;
  }

  static bool containsArabicLetters(String input) {
    final RegExp arabicPattern = RegExp(r'[\u0600-\u06FF]+');

    return arabicPattern.hasMatch(input);
  }

  static String processTextWithPdfLinks(String text) {
    if (text.endsWith('.pdf') &&
        text.startsWith('/') &&
        !text.contains('.com')) {
      // Check if the link is a relative link (starts with "/") or already has "www." in it.
      text = 'https://egx.com.eg$text';
    }
    return text;
  }

  static String generateCountryFlag(String countryCode) {
    String flag = countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
    return flag;
  }

  static void openWhatsApp(phoneNumber) async {
    String message = '';

    String encodedMessage = Uri.encodeComponent(message);

    String url = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Failed to launch WhatsApp');
    }
  }

  static Future openLink(context, String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {}
  }

  static bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidEnglish(String value) {
    RegExp regex = RegExp(r'^[a-zA-Z]+$');
    return (regex.hasMatch(value)) ? true : false;
  }

  static bool isEgyptianNumber(String phone) {
    return phone.substring(0, 3) == '+20';
  }

  static String removeWhiteSpace(String inputString) {
    // Create a regular expression to match white spaces
    RegExp regExp = RegExp(r'\s+');

    // Use replaceAll to remove white spaces
    String resultString = inputString.replaceAll(regExp, '');

    return resultString;
  }

  static Future<List<String>> loadFilesWithExtension(
    String targetExtension,
  ) async {
    List<Directory?> directories = [
      Directory('/storage/emulated/0/'),
      // await getExternalStorageDirectory(),
      // await getApplicationDocumentsDirectory(),
      // await getApplicationSupportDirectory(),
    ];

    List<String> filePaths = [];

    for (var directory in directories) {
      if (directory != null) {
        filePaths.addAll(_scanDirectory(directory, targetExtension));
      }
    }

    return filePaths;
  }

  static List<String> _scanDirectory(
    Directory directory,
    String targetExtension,
  ) {
    List<String> filePaths = [];
    try {
      for (var entity in directory.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith(targetExtension)) {
          filePaths.add(entity.path);
        }
      }
    } on PlatformException catch (e) {
      print("PlatformException : ${e.toString()}");
    } on FileSystemException catch (e) {
      print("FileSystemException : ${e.toString()}");
    }
    return filePaths;
  }

  static List<String> videoFileExtensions = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
    'webm',
    '3gp',
    'mpeg',
    'mpg',
    'm4v',
    'ogv',
    'ts',
    'vob',
    'mts',
    'm2ts',
    'divx',
    'asf',
    'dat',
    'm2v',
    'qt',
    'mod',
    'tod',
    'vro',
  ];

  static final extensionToMimeTypeMap = {
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'bmp': 'image/bmp',
    'txt': 'text/plain',
    'html': 'text/html',
    'xml': 'application/xml',
    'json': 'application/json',
    // Add more extensions and their corresponding MIME types as needed
  };

  // Define a function to get the MIME type based on a file's extension
  String getMimeTypeFromExtension(String extension) {
    // Get the corresponding MIME type from the map
    final mimeType = extensionToMimeTypeMap[extension.toLowerCase()];

    // If the MIME type is not found, default to a generic value (e.g., 'application/octet-stream')
    return mimeType ?? 'application/octet-stream';
  }

  // static Future<void> showOpenWithAppDialog(BuildContext context, String filePath) async {
  //   try {
  //     final result = await OpenFile.open(filePath);
  //     if (result.type == ResultType.done) {
  //       print('File opened with success.');
  //     } else {
  //       print('File open failed: ${result.message}');
  //     }
  //   } catch (e) {
  //     print('Error opening file: $e');
  //   }
  // }
}
