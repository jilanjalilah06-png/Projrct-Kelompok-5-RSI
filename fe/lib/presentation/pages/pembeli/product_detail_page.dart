import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Detail Produk',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.grain,
                size: 80,
                color: AgriColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Beras Premium Cianjur',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rp 14.000 / kg',
              style: TextStyle(
                fontSize: 18,
                color: AgriColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dijual oleh: Pak Budi – Cianjur',
              style: TextStyle(color: AgriColors.textLight),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Beras premium kualitas terbaik dari Cianjur, diproses dengan standar higienis tinggi. Cocok untuk konsumsi harian maupun kebutuhan restoran.',
              style: TextStyle(color: AgriColors.textDark, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
                child: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
