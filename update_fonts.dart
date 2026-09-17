import 'package:flutter/foundation.dart';
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int count = 0;
  for (var file in files) {
    String content = file.readAsStringSync();
    String original = content;
    
    // Replace fontFamily strings
    content = content.replaceAll(RegExp(r"fontFamily:\s*'(Inter|Poppins|Manrope)'"), "fontFamily: 'Plus Jakarta Sans'");
    
    // Replace GoogleFonts calls
    content = content.replaceAll(RegExp(r"GoogleFonts\.(inter|poppins|manrope)TextTheme"), "GoogleFonts.plusJakartaSansTextTheme");
    content = content.replaceAll(RegExp(r"GoogleFonts\.(inter|poppins|manrope)\b"), "GoogleFonts.plusJakartaSans");
    
    if (content != original) {
      file.writeAsStringSync(content);
      count++;
      debugPrint('Updated ${file.path}');
    }
  }
  debugPrint('Updated $count files.');
}
