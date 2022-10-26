import 'dart:io';

abstract class Parser {
  static List<String> parserText(File file) {
    return file.readAsLinesSync();
  }

  static Map<String, String> parserXmlOrHtml(File file) {
    final map = <String, String>{};
    file.readAsLinesSync().forEach((element) {
      if (element.isNotEmpty) {
        final startTag = element.substring(0, element.indexOf('>') + 1);
        final endTag = element.substring(element.lastIndexOf('</'));
        final content = element.substring(startTag.length, element.lastIndexOf('</'));
        map.putIfAbsent('$startTag#$endTag', () => content);
      }
    });
    return map;
  }
}
