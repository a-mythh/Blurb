// packages
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

String localDateTime(String date) {
  final timeZoneOffset = DateTime.now().timeZoneOffset;
  DateTime parsedDate =
      DateFormat('yyyy-MM-dd HH:mm:ss').parse(date).add(timeZoneOffset);
  String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(parsedDate);

  return formattedDate;
}

String formatDate(String date) {
  DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  String formattedDate = DateFormat('dd.MM.yyyy HH.mm.ss').format(parsedDate);
  return formattedDate;
}

// cell formatting for unmerged cells
void applyCellStyleToUnmergedCells({
  required Sheet sheet,
  required int column,
  required int row,
  required String colour,
  required bool isFormatted,
}) {
  CellStyle style = CellStyle(
    fontFamily: getFontFamily(FontFamily.Comic_Sans_MS),
    backgroundColorHex:
        isFormatted ? ExcelColor.fromHexString(colour) : ExcelColor.none,
    leftBorder: isFormatted
        ? Border(
            borderStyle: BorderStyle.Medium,
            borderColorHex: ExcelColor.white,
          )
        : null,
    rightBorder: isFormatted
        ? Border(
            borderStyle: BorderStyle.Medium,
            borderColorHex: ExcelColor.white,
          )
        : null,
    topBorder: isFormatted
        ? Border(
            borderStyle: BorderStyle.Medium,
            borderColorHex: ExcelColor.white,
          )
        : null,
    bottomBorder: isFormatted
        ? Border(
            borderStyle: BorderStyle.Medium,
            borderColorHex: ExcelColor.white,
          )
        : null,
    verticalAlign: VerticalAlign.Center,
    horizontalAlign:
        column == 3 ? HorizontalAlign.Center : HorizontalAlign.Left,
    textWrapping: TextWrapping.WrapText,
  );

  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
      .cellStyle = style;
}

// cell formatting for merged cells
void mergeAndFormatCells({
  required Sheet sheet,
  required int startRow,
  required int endRow,
  required String colour,
  required bool isFormatted,
}) {
  // merge cells for serial no, word, phonetic, synonyms, antonyms, saved on columns
  for (int col in [0, 1, 2, 5, 6, 7]) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startRow),
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: endRow),
    );

    CellStyle style = CellStyle(
      fontFamily: getFontFamily(FontFamily.Comic_Sans_MS),
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
      textWrapping:
          [5, 6].contains(col) ? TextWrapping.WrapText : TextWrapping.Clip,
      leftBorder: Border(borderColorHex: ExcelColor.none),
    );

    // if formatting is asked for
    if (isFormatted) {
      style = style.copyWith(
        backgroundColorHexVal: ExcelColor.fromHexString(colour),
        leftBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        rightBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        topBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        bottomBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    // formatting when merging is required
    if (startRow != endRow) {
      sheet.setMergedCellStyle(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startRow),
        style,
      );
    }
    // formatting when merging is not required
    else {
      sheet
          .cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startRow),
          )
          .cellStyle = style;
    }
  }
}

// get device permission for file management
Future<File?> getPermissionToCreateFile() async {
  bool allowed = await Permission.manageExternalStorage.isGranted;
  PermissionStatus status = PermissionStatus.granted;

  // permission not given already
  if (!allowed) status = await Permission.manageExternalStorage.request();

  String now = formatDate(DateTime.now().toString());
  File file = File("/storage/emulated/0/blurb/Saved Words ($now).xlsx");

  // check if permission is available to create and store files
  if (status.isGranted) {
    if (await file.exists()) {
      // overwrite file if present (deletion, then creation)
      await file.delete().catchError((e) {
        print(e);
        return e;
      });
    }

    // if file can be created, then return it
    return file;
  }

  // file creation has error (permission or something else)
  return null;
}

Future<void> exportToExcel({
  required List<Map<String, dynamic>> words,
  required bool isFormatted,
}) async {
  localDateTime(words[0]['saved_on']);
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];

  // set some utility variables
  Border whiteBorder = Border(
    borderColorHex: ExcelColor.white,
    borderStyle: BorderStyle.Medium,
  );
  List<String> colours = [
    '#CEECC0',
    '#C0ECD8',
    '#C0DBEC',
    '#CBC0EC',
    '#DCC0EA',
    '#ECC0E7',
    '#ECC0C1',
    '#ECE4C0',
  ];

  // Header Row
  List<CellValue> headerRow = const [
    TextCellValue("Sl. No."),
    TextCellValue("Word"),
    TextCellValue("Phonetic"),
    TextCellValue("Part of Speech"),
    TextCellValue("Meanings"),
    TextCellValue("Synonyms"),
    TextCellValue("Antonyms"),
    TextCellValue("Saved on"),
  ];
  sheetObject.appendRow(headerRow);

  // header row height and width
  sheetObject.setRowHeight(0, 24);
  sheetObject.setColumnAutoFit(0);
  sheetObject.setColumnWidth(1, 16);
  sheetObject.setColumnWidth(2, 16);
  sheetObject.setColumnAutoFit(3);
  sheetObject.setColumnWidth(4, 40);
  sheetObject.setColumnWidth(5, 26);
  sheetObject.setColumnWidth(6, 26);
  sheetObject.setColumnWidth(7, 20);

  // formatting header row
  CellStyle headersStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    leftBorder: isFormatted ? whiteBorder : null,
    rightBorder: isFormatted ? whiteBorder : null,
    topBorder: isFormatted ? whiteBorder : null,
    bottomBorder: isFormatted ? whiteBorder : null,
  );
  // formatting for headers
  for (int i = 0; i < 8; i++) {
    ExcelColor rowColour = ExcelColor.fromHexString(colours[i]);

    sheetObject
        .cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        )
        .cellStyle = headersStyle.copyWith(
      backgroundColorHexVal: isFormatted ? rowColour : ExcelColor.none,
    );
  }

  // Excel files are 1-indexed, start after the header row
  int rowIndex = 2;

  // insert each word one by one
  for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
    // single word map
    var wordData = words[wordIndex];

    // colour for current row (if required)
    String colour = colours[wordIndex % colours.length];

    // get meanings, part of speech and no. of rows
    Map<String, List> meanings = wordData['meanings'] as Map<String, List>;
    List<String> partsOfSpeech = meanings.keys.toList();
    int rowCount = partsOfSpeech.length;

    // insert all data of single word
    for (var i = 0; i < rowCount; i++) {
      String partOfSpeech = partsOfSpeech[i];
      List meaningData = meanings[partOfSpeech]!;

      // get all meanings for the part of speech along with usage
      String meaningsList = meaningData
          .map(
            (meaning) {
              String definition = meaning['definition'];
              String usage = meaning['usage'];

              String result = usage.isNotEmpty
                  ? '$definition\n\nUsage: $usage\n'
                  : '$definition\n';

              return result;
            },
          )
          .toList()
          .join("\n\n");

      // insert single row
      List<CellValue> row = [
        TextCellValue('${wordIndex + 1}.'),
        TextCellValue(wordData['word']),
        TextCellValue(wordData['phonetics'][0]['text']),
        TextCellValue(partOfSpeech),
        TextCellValue(meaningsList),
        TextCellValue(wordData['thesaurus']['synonyms'].join(', ')),
        TextCellValue(wordData['thesaurus']['antonyms'].join(', ')),
        TextCellValue(localDateTime(wordData['saved_on'])),
      ];
      sheetObject.appendRow(row);

      // format cells (parts of speech and meanings - unmerged)
      for (int col in [3, 4]) {
        applyCellStyleToUnmergedCells(
          sheet: sheetObject,
          column: col,
          row: rowIndex + i - 1,
          colour: colour,
          isFormatted: isFormatted,
        );
      }
    }

    // format cells (serial no., word, phonetic, synonyms, antonyms, saved on - merged)
    mergeAndFormatCells(
      sheet: sheetObject,
      startRow: rowIndex - 1,
      endRow: rowIndex + rowCount - 2,
      colour: colour,
      isFormatted: isFormatted,
    );

    rowIndex += rowCount;
  }

  File? file = await getPermissionToCreateFile();

  // save the excel, if file can be created
  if (file != null) {
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      print('Excel file saved at: ${file.path}');
    }
  } else {
    print('Error occurred while creating the file');
  }
}
