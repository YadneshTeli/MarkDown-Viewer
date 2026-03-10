import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'markdown_parser.dart';

class ExportService {
  /// Share the raw markdown content as a text file.
  Future<void> shareMarkdown({
    required String content,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
    );
  }

  /// Copy markdown content to clipboard.
  Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  /// Generate and share a PDF from the markdown content.
  Future<void> exportToPdf({
    required String content,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Load fonts via Google Fonts (from printing package, cached automatically)
    final baseFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();
    final monoFont = await PdfGoogleFonts.robotoMonoRegular();

    final parser = MarkdownParser();
    final blocks = parser.parseBlocks(content);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return blocks.map((block) {
            return _renderBlock(block, baseFont, boldFont, italicFont, monoFont);
          }).toList();
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${fileName.replaceAll(RegExp(r'\.md$|\.markdown$'), '')}.pdf',
    );
  }

  // ─── Block Renderer ─────────────────────────────────────────────────

  pw.Widget _renderBlock(
    MdBlock block,
    pw.Font baseFont,
    pw.Font boldFont,
    pw.Font italicFont,
    pw.Font monoFont,
  ) {
    switch (block.type) {
      case MdBlockType.heading:
        final fontSize = _headingFontSize(block.level);
        return pw.Padding(
          padding: pw.EdgeInsets.only(top: block.level <= 2 ? 16 : 10, bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                block.text,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: fontSize,
                  color: PdfColors.blueGrey800,
                ),
              ),
              if (block.level <= 2)
                pw.Divider(
                  color: PdfColors.grey300,
                  thickness: block.level == 1 ? 1.5 : 0.75,
                ),
            ],
          ),
        );

      case MdBlockType.paragraph:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.RichText(
            text: _buildInlineSpan(block.text, baseFont, boldFont, italicFont, monoFont),
          ),
        );

      case MdBlockType.code:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Text(
              block.text,
              style: pw.TextStyle(font: monoFont, fontSize: 10, color: PdfColors.grey800),
            ),
          ),
        );

      case MdBlockType.listItem:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('•  ', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.Expanded(
                child: pw.RichText(
                  text: _buildInlineSpan(block.text, baseFont, boldFont, italicFont, monoFont),
                ),
              ),
            ],
          ),
        );

      case MdBlockType.orderedListItem:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 24,
                child: pw.Text(
                  '${block.level}.',
                  style: pw.TextStyle(font: baseFont, fontSize: 12),
                ),
              ),
              pw.Expanded(
                child: pw.RichText(
                  text: _buildInlineSpan(block.text, baseFont, boldFont, italicFont, monoFont),
                ),
              ),
            ],
          ),
        );

      case MdBlockType.blockquote:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Container(
            padding: const pw.EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.blueGrey300, width: 3),
              ),
            ),
            child: pw.RichText(
              text: _buildInlineSpan(
                block.text, baseFont, boldFont, italicFont, monoFont,
                color: PdfColors.grey700,
              ),
            ),
          ),
        );

      case MdBlockType.hr:
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          child: pw.Divider(color: PdfColors.grey400, thickness: 1),
        );
    }
  }

  double _headingFontSize(int level) {
    switch (level) {
      case 1: return 26;
      case 2: return 22;
      case 3: return 18;
      case 4: return 16;
      case 5: return 14;
      default: return 12;
    }
  }

  // ─── Inline formatting (bold, italic, code, links) ──────────────────

  pw.TextSpan _buildInlineSpan(
    String text,
    pw.Font baseFont,
    pw.Font boldFont,
    pw.Font italicFont,
    pw.Font monoFont, {
    PdfColor color = PdfColors.black,
  }) {
    final spans = <pw.TextSpan>[];
    // Pattern: `code`, **bold**, *italic*, [text](url), or plain text
    final regex = RegExp(
      r'`([^`]+)`'             // inline code
      r'|\*\*(.+?)\*\*'        // bold
      r'|\*(.+?)\*'            // italic
      r'|\[([^\]]+)\]\([^\)]+\)' // link (capture text only)
      r'|([^`*\[]+)',          // plain text
    );

    for (final match in regex.allMatches(text)) {
      if (match.group(1) != null) {
        // inline code
        spans.add(pw.TextSpan(
          text: match.group(1),
          style: pw.TextStyle(font: monoFont, fontSize: 11, color: PdfColors.deepOrange800, background: pw.BoxDecoration(color: PdfColors.grey100)),
        ));
      } else if (match.group(2) != null) {
        // bold
        spans.add(pw.TextSpan(
          text: match.group(2),
          style: pw.TextStyle(font: boldFont, fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
        ));
      } else if (match.group(3) != null) {
        // italic
        spans.add(pw.TextSpan(
          text: match.group(3),
          style: pw.TextStyle(font: italicFont, fontSize: 12, fontStyle: pw.FontStyle.italic, color: color),
        ));
      } else if (match.group(4) != null) {
        // link — render as underlined blue text
        spans.add(pw.TextSpan(
          text: match.group(4),
          style: pw.TextStyle(
            font: baseFont,
            fontSize: 12,
            color: PdfColors.blue700,
            decoration: pw.TextDecoration.underline,
          ),
        ));
      } else if (match.group(5) != null) {
        // plain text
        spans.add(pw.TextSpan(
          text: match.group(5),
          style: pw.TextStyle(font: baseFont, fontSize: 12, color: color),
        ));
      }
    }

    if (spans.isEmpty) {
      return pw.TextSpan(
        text: text,
        style: pw.TextStyle(font: baseFont, fontSize: 12, color: color),
      );
    }

    return pw.TextSpan(children: spans);
  }
}

