import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tool_translate/parser.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tool_translate/file.dart';
import 'package:tool_translate/language_list.dart';
import 'package:tool_translate/theme.dart';

//?Check if current enviroment is a desktop enviroment
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && [TargetPlatform.windows, TargetPlatform.android].contains(defaultTargetPlatform)) {
    await SystemTheme.accentColor.load();
  }
  if (isDesktop) {
    await WindowManager.instance.ensureInitialized();
    WindowManager.instance.waitUntilReadyToShow().then((_) async => {
          await WindowManager.instance.setTitleBarStyle(
            TitleBarStyle.normal,
            windowButtonVisibility: true,
          ),
          await WindowManager.instance.setSize(const Size(745, 545)),
          await WindowManager.instance.setMinimumSize(const Size(350, 600)),
          await WindowManager.instance.center(animate: true),
          await WindowManager.instance.show(),
          await WindowManager.instance.setPreventClose(false),
        });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme(context: context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Translate',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
      ),
      theme: ThemeData(
        visualDensity: VisualDensity.standard,
      ),
      locale: appTheme.locale,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _nameFile = 'Pick File';
  String? languageCodeSelected = listDetailRegion[0][0];
  String? languageTranslate = listDetailRegion[1][0];
  final translate = TranslateDirect();
  final List<FileLanguageModel> files = List.empty(growable: true);
  bool _isFileAlreadySelected = false;
  late PlatformFile file;
  String error = '';
  MyFileType fileTypeSeleced = MyFileType.TXT;
  List<MyFileType> filesType = [
    MyFileType.TXT,
    MyFileType.JSON,
    MyFileType.XML,
    MyFileType.HTML,
    MyFileType.STRINGS,
  ];
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: error.isNotEmpty,
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('From language:'),
                const SizedBox(
                  width: 12,
                ),
                DropdownButton<String>(
                  items: listDetailRegion
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e[0],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(e[1]),
                              const Text(' - '),
                              Text(e[0]),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  value: languageCodeSelected,
                  onChanged: (value) {
                    setState(() {
                      languageCodeSelected = value;
                    });
                  },
                  icon: const Icon(Icons.language_rounded),
                  borderRadius: BorderRadius.circular(20),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('From type:'),
                const SizedBox(
                  width: 12,
                ),
                DropdownButton<MyFileType>(
                  items: filesType
                      .map(
                        (e) => DropdownMenuItem<MyFileType>(
                            value: e,
                            child: Text(
                              e.name.toLowerCase(),
                              textAlign: TextAlign.center,
                            )),
                      )
                      .toList(),
                  value: fileTypeSeleced,
                  onChanged: (value) {
                    setState(() {
                      fileTypeSeleced = value ?? MyFileType.TXT;
                    });
                  },
                  icon: const Icon(Icons.file_download_rounded),
                  borderRadius: BorderRadius.circular(20),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox.fromSize(
              size: Size(width / 2, width / 6),
              child: InkWell(
                onTap: () async {
                  final FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: ['xml', 'txt', 'html', 'dat', 'doc', 'strings'],
                  );
                  if (result == null) {
                    setState(() {
                      error = 'File is not picked!!!';
                    });
                  } else {
                    file = result.files.single;

                    setState(() {
                      _isFileAlreadySelected = true;
                      _nameFile = file.name;
                      error = '';
                    });
                  }
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.green.shade200,
                highlightColor: Colors.blue.shade200,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_nameFile),
                      Visibility(
                        visible: _nameFile.isEmpty,
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.green,
                        ),
                      ),
                      const Icon(Icons.file_open_rounded),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_isFileAlreadySelected) {
                  final languageCode = await _showDialogPickMutipleLanguage();

                  if (files.isEmpty) {
                    final fileAdd = FileLanguageModel(
                      filePath: file.path.toString().substring(
                            0,
                            file.path.toString().lastIndexOf('\\'),
                          ),
                      fileName: file.name.substring(0, file.name.lastIndexOf('.')),
                      fileType: MyFileType.TXT,
                      language: languageCode ?? 'en',
                    );
                    setState(() {
                      files.add(fileAdd);
                    });
                  } else {
                    final isExist = files.indexWhere((element) => element.language == languageCode) != -1;
                    if (!isExist) {
                      final fileAdd = FileLanguageModel(
                        filePath: file.path.toString().substring(
                              0,
                              file.path.toString().lastIndexOf('\\'),
                            ),
                        fileName: file.name.substring(0, file.name.lastIndexOf('.')),
                        fileType: MyFileType.TXT,
                        language: languageCode ?? 'en',
                      );
                      setState(() {
                        files.add(fileAdd);
                      });
                    } else {}
                  }
                } else {
                  setState(() {
                    error = 'File is not picked!!!';
                  });
                }
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const CircleBorder(),
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.all(16.0),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.purple.shade400),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: _buildFileDownload(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileDownload() {
    return Wrap(
      children: files
          .map(
            (e) => Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 5,
              ),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            color: Colors.yellow.shade400,
                            size: 42,
                          ),
                          Text('${e.fileName}_${e.language}.${e.fileType.name.toLowerCase()}'),
                          DropdownButton<MyFileType>(
                            items: filesType
                                .map(
                                  (e) => DropdownMenuItem<MyFileType>(
                                    value: e,
                                    alignment: AlignmentDirectional.center,
                                    child: Text(
                                      e.name.toLowerCase(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                                .toList(),
                            value: e.fileType,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                files[files.indexOf(e)] = e.copyWith(fileType: value ?? MyFileType.TXT);
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                          ),
                          e.status == 0
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      files[files.indexWhere((element) => e.language == element.language)] = e.copyWith(status: 1);
                                    });
                                    _translateContent(_getParserFile(fileTypeSeleced), e.language).then((value) {
                                      if (value is List<String>) {
                                        final fileDirectory = File("${e.filePath}\\${e.fileName}_${e.language}.${e.fileType.name.toLowerCase()}");
                                        if (fileDirectory.existsSync()) {
                                          fileDirectory.deleteSync(recursive: true);
                                          fileDirectory.createSync(recursive: true);
                                        }
                                        fileDirectory.writeAsStringSync(value.join("\n"));
                                      }
                                      setState(() {
                                        files[files.indexWhere((element) => e.language == element.language)] = e.copyWith(status: 2);
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.download_rounded,
                                    color: Colors.yellow.shade600,
                                  ),
                                )
                              : e.status == 1
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.yellow.shade600),
                                    )
                                  : Icon(
                                      Icons.download_done,
                                      color: Colors.green.shade300,
                                    ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            files.remove(e);
                          });
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<dynamic> _translateContent(dynamic content, String languageTranslate) async {
    List<String> listStringConvert = <String>[];
    final completer = Completer();
    if (content is List) {
      try {
        Future ft = Future(
          () {},
        );
        for (var element in content) {
          ft = ft.then((value) async {
            final trans = await translate.translate(languageCodeSelected ?? 'en', languageTranslate, element);
            String result = '';
            if (trans['sentences'] is List && trans['sentences'].isNotEmpty) {
              result = trans['sentences'][0]['trans'];
            }
            listStringConvert.add(result);
            if (listStringConvert.length == content.length) completer.complete(listStringConvert);
          }, onError: (err, stackTrace) {
            setState(() {
              error = err;
            });
          });
        }
      } catch (e) {
        setState(() {
          error = 'File is error!!!';
        });
      }
    } else if (content is Map<String, String>) {
      try {
        Future ft = Future(
          () {},
        );
        for (var element in content.keys) {
          ft = ft.then((value) async {
            final trans = await translate.translate(languageCodeSelected ?? 'en', languageTranslate, content[element] ?? '');
            String result = '';
            if (trans['sentences'] is List && trans['sentences'].isNotEmpty) {
              result = trans['sentences'][0]['trans'];
            }
            final contentAdd = element.replaceFirst(
              '#',
              fileTypeSeleced == MyFileType.JSON
                  ? '"$result"'
                  : fileTypeSeleced == MyFileType.STRINGS
                      ? '"$result";'
                      : result,
            );
            listStringConvert.add(contentAdd);
            if (listStringConvert.length == content.length) completer.complete(listStringConvert);
          }, onError: (err, stackTrace) {
            setState(() {
              error = err;
            });
          });
        }
      } catch (e) {
        setState(() {
          error = 'File is error!!!';
        });
      }
    }

    return completer.future;
  }

  Future<String?> _showDialogPickMutipleLanguage() {
    return showDialog<String>(
      useSafeArea: true,
      barrierLabel: 'Select lanaguae',
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              minHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: MediaQuery.of(context).size.width * 0.5,
              minWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: listDetailRegion.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final item = listDetailRegion[index];
                return ListTile(
                  trailing: Text(item[0]),
                  title: Text(item[1]),
                  onTap: () {
                    Navigator.pop(context, item[0]);
                  },
                );
              },
            ),
          ),
          title: const Text('Select language'),
          icon: const Icon(Icons.language_rounded),
          iconColor: Colors.green.shade400,
        );
      },
    );
  }

  dynamic _getParserFile(MyFileType fileTypeSeleced) {
    if (fileTypeSeleced == MyFileType.TXT) {
      return Parser.parserText(File(file.path ?? ''));
    } else if (fileTypeSeleced == MyFileType.XML || fileTypeSeleced == MyFileType.HTML) {
      return Parser.parseXmlOrHtml(File(file.path ?? ''));
    } else if (fileTypeSeleced == MyFileType.JSON) {
      return Parser.parseJson(File(file.path ?? ''));
    } else {
      return Parser.parseStrings(File(file.path ?? ''));
    }
  }
}

class TranslateDirect {
  final googleApi =
      'https://translate.google.com/translate_a/single?client=gtx&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=sos&dt=ss&dt=t&otf=1&ssel=3&tsel=0&dj=1';
  final dio = Dio();
  Future translate(String sl, String tl, String query) {
    Completer translateCompleter = Completer();
    dio.get(googleApi, queryParameters: {'sl': sl, 'tl': tl, 'q': query}).then((response) {
      translateCompleter.complete(response.data);
    }, onError: (object) {
      translateCompleter.completeError(object);
    });

    return translateCompleter.future;
  }
}
