import 'dart:io';

// required for isolated testing
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("Error: Not enough arguments provided.");
    print("Usage: dart annotate_localization.dart <file_path>");
    exit(1);
  }

  return AnnotateLocalization()(arguments[0]);
}

class AnnotateLocalization {
  void _replaceContent({
    required String path,
    required String pattern,
    required String replacement,
    required String fileContent,
  }) {
    final replacedContent = fileContent.replaceAll(
        RegExp(pattern, caseSensitive: false), replacement);
    final tempFile = File('$path.tmp');
    tempFile.writeAsStringSync(replacedContent);

    // Check if the replacement was successful
    if (tempFile.existsSync()) {
      // Overwrite the original file with the new file
      tempFile.renameSync(path);
    } else {
      print("Error: Annotation failed.");
      exit(1);
    }
  }

  void call(String filePath) {
    // Mapper generator-config options
    String searchParameter = 'abstract class AppLocalizations {\n';

    String requiredImports = '''
import 'package:l10_mapper_annotation/l10_mapper_annotation.dart';
part 'app_localizations.g.dart';

@L10MapperAnnotation()
abstract class AppLocalizations {
''';

    // Write imports and annotations to app_localization.dart file
    print('\nAdding required imports to generated app_localizations');
    replaceString(
        path: filePath, pattern: searchParameter, replacement: requiredImports);
  }

  void replaceString({
    required String path,
    required String pattern,
    required String replacement,
  }) {
    // Check if the input file exists
    final inputFile = File(path);
    if (!inputFile.existsSync()) {
      print("Error: Input file does not exist.");
      exit(1);
    }

    // Backup the original file
    final backupFile = File('$path.bak');
    inputFile.copySync(backupFile.path);

    // Perform the search and replace and write the result to a new file
    final fileContent = inputFile.readAsStringSync();

    // verify if replacement operation was previously successful
    final alreadyReplaced = fileContent.contains(replacement);
    if (alreadyReplaced) {
      print(
          "Error: AnnotateLocalization failed as specified replacement already exists!");
      exit(1);
    }

    _replaceContent(
      path: path,
      pattern: pattern,
      replacement: replacement,
      fileContent: fileContent,
    );

    print("Annotation completed successfully.");
  }
}