import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';

/// Тип экспорта
enum ExportType { pdf, csv }

/// Результат экспорта
class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  ExportResult.success(this.filePath)
      : success = true,
        error = null;

  ExportResult.failure(this.error)
      : success = false,
        filePath = null;
}

/// Сервис для экспорта данных
class ExportService {
  final _dateFormat = DateFormat('dd.MM.yyyy');
  final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  final _moneyFormat = NumberFormat('#,##0.00', 'ru');

  // ==================== REPAIRS ====================

  /// Экспорт ремонтов в PDF
  Future<ExportResult> exportRepairsToPdf(
    List<Repair> repairs, {
    String? title,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final pdf = pw.Document();
      final reportTitle = title ?? 'Отчёт по ремонтам';

      // Сортировка по дате
      final sortedRepairs = List<Repair>.from(repairs)
        ..sort((a, b) => b.date.compareTo(a.date));

      // Статистика
      final totalRevenue = sortedRepairs.fold<double>(
        0,
        (sum, r) => sum + r.cost,
      );
      final completedCount =
          sortedRepairs.where((r) => r.status.value == 'completed').length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildPdfHeader(reportTitle, dateFrom, dateTo),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            // Статистика
            _buildStatsSection(
              totalRepairs: sortedRepairs.length,
              completedRepairs: completedCount,
              totalRevenue: totalRevenue,
            ),
            pw.SizedBox(height: 20),
            // Таблица ремонтов
            _buildRepairsTable(sortedRepairs),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'repairs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = await _saveFile(bytes, fileName);

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.failure('Ошибка создания PDF: $e');
    }
  }

  /// Экспорт ремонтов в CSV
  Future<ExportResult> exportRepairsToCsv(List<Repair> repairs) async {
    try {
      final rows = <List<dynamic>>[
        // Заголовок
        [
          'ID',
          'Дата',
          'Автомобиль',
          'Тип детали',
          'Позиция',
          'Статус',
          'Стоимость',
          'Описание',
        ],
        // Данные
        ...repairs.map((r) => [
          r.id,
          _dateFormat.format(r.date),
          '${r.carMake} ${r.carModel}',
          r.partType,
          r.partPosition,
          r.status.displayName,
          r.cost,
          r.description,
        ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName =
          'repairs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = await _saveFile(
        csvData.codeUnits.map((e) => e).toList(),
        fileName,
        addBom: true,
      );

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.failure('Ошибка создания CSV: $e');
    }
  }

  // ==================== CLIENTS ====================

  /// Экспорт клиентов в PDF
  Future<ExportResult> exportClientsToPdf(List<Client> clients) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildPdfHeader('База клиентов', null, null),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Text(
              'Всего клиентов: ${clients.length}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            _buildClientsTable(clients),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'clients_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = await _saveFile(bytes, fileName);

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.failure('Ошибка создания PDF: $e');
    }
  }

  /// Экспорт клиентов в CSV
  Future<ExportResult> exportClientsToCsv(List<Client> clients) async {
    try {
      final rows = <List<dynamic>>[
        ['ID', 'Имя', 'Телефон', 'Количество авто'],
        ...clients.map((c) => [c.id, c.name, c.phone, c.carCount]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName =
          'clients_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = await _saveFile(
        csvData.codeUnits.map((e) => e).toList(),
        fileName,
        addBom: true,
      );

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.failure('Ошибка создания CSV: $e');
    }
  }

  // ==================== CARS ====================

  /// Экспорт автомобилей в CSV
  Future<ExportResult> exportCarsToCsv(List<Car> cars) async {
    try {
      final rows = <List<dynamic>>[
        ['ID', 'Марка', 'Модель', 'Гос. номер', 'Владелец'],
        ...cars.map((c) => [
          c.id,
          c.make,
          c.model,
          c.plate,
          c.clientName,
        ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName =
          'cars_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = await _saveFile(
        csvData.codeUnits.map((e) => e).toList(),
        fileName,
        addBom: true,
      );

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.failure('Ошибка создания CSV: $e');
    }
  }

  // ==================== PDF BUILDERS ====================

  pw.Widget _buildPdfHeader(
    String title,
    DateTime? dateFrom,
    DateTime? dateTo,
  ) {
    String dateRange = '';
    if (dateFrom != null || dateTo != null) {
      final from = dateFrom != null ? _dateFormat.format(dateFrom) : '...';
      final to = dateTo != null ? _dateFormat.format(dateTo) : '...';
      dateRange = '$from — $to';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'FitProgressor',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#FF8C00'),
              ),
            ),
            pw.Text(
              _dateTimeFormat.format(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (dateRange.isNotEmpty)
          pw.Text(
            dateRange,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Страница ${context.pageNumber} из ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildStatsSection({
    required int totalRepairs,
    required int completedRepairs,
    required double totalRevenue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Всего ремонтов', totalRepairs.toString()),
          _buildStatItem('Выполнено', completedRepairs.toString()),
          _buildStatItem('Выручка', '${_moneyFormat.format(totalRevenue)} ₽'),
        ],
      ),
    );
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildRepairsTable(List<Repair> repairs) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 28,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
      headers: ['Дата', 'Автомобиль', 'Деталь', 'Статус', 'Сумма'],
      data: repairs
          .map((r) => [
                _dateFormat.format(r.date),
                '${r.carMake} ${r.carModel}',
                '${r.partType}\n${r.partPosition}',
                r.status.displayName,
                '${_moneyFormat.format(r.cost)} ₽',
              ])
          .toList(),
    );
  }

  pw.Widget _buildClientsTable(List<Client> clients) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 28,
      headers: ['Имя', 'Телефон', 'Авто'],
      data: clients
          .map((c) => [c.name, c.phone, c.carCount.toString()])
          .toList(),
    );
  }

  // ==================== FILE UTILS ====================

  Future<File> _saveFile(
    List<int> bytes,
    String fileName, {
    bool addBom = false,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');

    if (addBom) {
      // Добавляем BOM для корректного отображения UTF-8 в Excel
      final bom = [0xEF, 0xBB, 0xBF];
      await file.writeAsBytes([...bom, ...bytes]);
    } else {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  /// Поделиться файлом
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}
