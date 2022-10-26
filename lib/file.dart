// ignore_for_file: public_member_api_docs, sort_constructors_first
class FileLanguageModel {
  final String filePath;
  final String fileName;
  final MyFileType fileType;
  final String language;
  final int status;
  FileLanguageModel({required this.filePath, required this.fileName, required this.fileType, this.language = 'en', this.status = 0});

  FileLanguageModel copyWith({String? filePath, String? fileName, MyFileType? fileType, String? language, int? status}) {
    return FileLanguageModel(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      language: language ?? this.language,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'FileLanguageModel(filePath: $filePath, fileName: $fileName, fileType: $fileType, language: $language)';
  }
}

enum MyFileType {
  TXT,
  JSON,
  XML,
  HTML,
  IDLE,
}
