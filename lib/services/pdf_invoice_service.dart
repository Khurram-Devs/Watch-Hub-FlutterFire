import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';

class PDFInvoiceService {
  static Future<void> generateAndDownloadInvoice(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final orderDoc = await FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .get();

    final order = orderDoc.data();
    if (order == null) throw Exception("Order not found");

    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final pdf = pw.Document();

    final createdAt = (order['createdAt'] as Timestamp).toDate();
    final items = (order['items'] as List<dynamic>).cast<Map<String, dynamic>>();
    final total = order['total'] as num? ?? 0;
    final subtotal = order['subtotal'] as num? ?? 0;
    final tax = order['tax'] as num? ?? 0;
    final shipping = order['shipping'] as num? ?? 0;
    final discount = order['discount'] as num? ?? 0;

    final List<pw.TableRow> productRows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(child: pw.Text('#', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)), padding: const pw.EdgeInsets.all(4)),
          pw.Padding(child: pw.Text('Product', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)), padding: const pw.EdgeInsets.all(4)),
          pw.Padding(child: pw.Text('Unit Price', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)), padding: const pw.EdgeInsets.all(4)),
          pw.Padding(child: pw.Text('Qty', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)), padding: const pw.EdgeInsets.all(4)),
          pw.Padding(child: pw.Text('Subtotal', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)), padding: const pw.EdgeInsets.all(4)),
        ],
      )
    ];

    int index = 1;
    for (final item in items) {
      final doc = await (item['productRef'] as DocumentReference).get();
      final product = doc.data() as Map<String, dynamic>? ?? {};
      final title = product['title'] ?? 'Unknown';
      final price = (product['price'] as num?)?.toDouble() ?? 0.0;
      final qty = item['quantity'] ?? 1;

      productRows.add(
        pw.TableRow(
          children: [
            pw.Padding(child: pw.Text('$index', style: pw.TextStyle(font: ttf)), padding: const pw.EdgeInsets.all(4)),
            pw.Padding(child: pw.Text(title, style: pw.TextStyle(font: ttf)), padding: const pw.EdgeInsets.all(4)),
            pw.Padding(child: pw.Text('\$${price.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)), padding: const pw.EdgeInsets.all(4)),
            pw.Padding(child: pw.Text('$qty', style: pw.TextStyle(font: ttf)), padding: const pw.EdgeInsets.all(4)),
            pw.Padding(child: pw.Text('\$${(price * qty).toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)), padding: const pw.EdgeInsets.all(4)),
          ],
        ),
      );
      index++;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('WatchHub - Premium Watch Store',
                style: pw.TextStyle(font: ttf, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Invoice', style: pw.TextStyle(font: ttf, fontSize: 18)),
            pw.SizedBox(height: 8),
            pw.Text('Order ID: $orderId', style: pw.TextStyle(font: ttf)),
            pw.Text('Date: $createdAt', style: pw.TextStyle(font: ttf)),
            pw.Divider(),

            pw.SizedBox(height: 10),
            pw.Text('Products:', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: productRows,
            ),

            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Subtotal: \$${subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                    pw.Text('Tax: \$${tax.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                    pw.Text('Shipping: \$${shipping.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                    pw.Text('Discount: -\$${discount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 24),
            pw.Text('Thank you for shopping with WatchHub!',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_$orderId.pdf',
    );
  }
}
