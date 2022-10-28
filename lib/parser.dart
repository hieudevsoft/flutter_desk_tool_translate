import 'dart:io';

abstract class Parser {
  static List<String> parserText(File file) {
    return file.readAsLinesSync();
  }

  static Map<String, String> parseXmlOrHtml(File file) {
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

  static Map<String, String> parseJson(File file) {
    final map = <String, String>{};
    file.readAsLinesSync().forEach((element) {
      if (element.isNotEmpty) {
        final key = element.split(':')[0];
        final value = element.split(':')[1];
        final valuePush = value.substring(0, value.length - 1);
        map.putIfAbsent('$key:#', () => valuePush.replaceFirst("'", "").replaceFirst('"', ''));
      }
    });
    return map;
  }

  static Map<String, String> parseStrings(File file) {
    final map = <String, String>{};
    file.readAsLinesSync().forEach((element) {
      if (element.isNotEmpty && element.contains('=')) {
        final key = element.split('=')[0];
        final value = element.split('=')[1];
        final valuePush = value.substring(0, value.length - 2);
        map.putIfAbsent('$key = #', () => valuePush.replaceFirst("'", "").replaceFirst('"', ''));
      }
    });
    return map;
  }
}
