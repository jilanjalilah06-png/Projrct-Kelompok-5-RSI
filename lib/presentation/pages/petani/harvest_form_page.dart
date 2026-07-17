import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class HarvestFormPage extends StatelessWidget {
  const HarvestFormPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layar 13: Input Hasil Panen Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Total Massa Berat Hasil Panen (Kg)',
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Simpan Data Panen',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
