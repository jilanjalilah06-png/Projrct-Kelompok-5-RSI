import 'package:flutter/material.dart';

class P4StokJualScreen extends StatefulWidget {
  const P4StokJualScreen({super.key});

  @override
  State<P4StokJualScreen> createState() => _P4StokJualScreenState();
}

class _P4StokJualScreenState extends State<P4StokJualScreen> {
  final List<_StockProduct> _products = [
    _StockProduct(
      product: 'Padi',
      variety: 'Padi',
      stock: 100,
      price: 'Rp 12.000/Kg',
      grade: _ProductGrade.standard,
    ),
    _StockProduct(
      product: 'Padi',
      variety: 'Padi Premium',
      stock: 80,
      price: 'Rp 20.000/Kg',
      grade: _ProductGrade.premium,
    ),
    _StockProduct(
      product: 'Jagung',
      variety: 'Jagung',
      stock: 50,
      price: 'Rp 4.800/Kg',
      grade: _ProductGrade.standard,
    ),
    _StockProduct(
      product: 'Jagung',
      variety: 'Jagung Premium',
      stock: 40,
      price: 'Rp 5.500/Kg',
      grade: _ProductGrade.premium,
    ),
  ];

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onAdd: _openAddStockPage),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                itemCount: _products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _ProductCard(product: _products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddStockPage() async {
    final product = await Navigator.push<_StockProduct>(
      context,
      MaterialPageRoute(builder: (_) => const AddStockPage()),
    );

    if (product == null) return;
    setState(() => _products.add(product));
  }
}

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _selectedProduct;
  _ProductGrade _selectedGrade = _ProductGrade.standard;

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P4StokJualScreenState._background,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(title: 'Tambah Stok', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _InputLabel('Pilih Produk'),
                    const SizedBox(height: 10),
                    _ProductDropdown(
                      value: _selectedProduct,
                      onChanged: (value) {
                        setState(() => _selectedProduct = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    const _InputLabel('Jenis'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _typeController,
                      hintText: 'Contoh: Pandan Wangi, Wowo Manis...',
                    ),
                    const SizedBox(height: 24),
                    const _InputLabel('Harga/Kg'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _priceController,
                      hintText: 'Rp 20.000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    const _InputLabel('Stok (Kg)'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _stockController,
                      hintText: '50 Kg',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    const _InputLabel('Grade Produk'),
                    const SizedBox(height: 12),
                    _GradeSelector(
                      selected: _selectedGrade,
                      onChanged: (grade) {
                        setState(() => _selectedGrade = grade);
                      },
                    ),
                    const SizedBox(height: 26),
                    const _InputLabel('Upload Foto'),
                    const SizedBox(height: 10),
                    const _UploadBox(),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _P4StokJualScreenState._green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final product = _selectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu.')),
      );
      return;
    }

    final variety = _typeController.text.trim().isEmpty
        ? product
        : _typeController.text.trim();
    final price = _priceController.text.trim().isEmpty
        ? 'Rp 0/Kg'
        : '${_priceController.text.trim()}/Kg';
    final stockText = _stockController.text.replaceAll(RegExp(r'[^0-9]'), '');

    Navigator.pop(
      context,
      _StockProduct(
        product: product,
        variety: variety,
        stock: int.tryParse(stockText) ?? 0,
        price: price,
        grade: _selectedGrade,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;

  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: _P4StokJualScreenState._green,
      padding: const EdgeInsets.only(left: 24, right: 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Daftar Produk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tambah stok',
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PageHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: _P4StokJualScreenState._green,
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _StockProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isPremium = product.grade == _ProductGrade.premium;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7FBE5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF079447),
                  size: 31,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.variety,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _P4StokJualScreenState._title,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Stok: ${product.stock} Kg',
                      style: const TextStyle(
                        color: _P4StokJualScreenState._muted,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _GradeBadge(isPremium: isPremium),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.price,
                  style: const TextStyle(
                    color: Color(0xFF00883E),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _P4StokJualScreenState._green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Detail',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final bool isPremium;

  const _GradeBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFFFFF1B8) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        isPremium ? 'Premium' : 'Standar',
        style: TextStyle(
          color: isPremium
              ? const Color(0xFFD46B08)
              : const Color(0xFF667085),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF667085),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ProductDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
      ),
      hint: const Text(
        '-- Pilih --',
        style: TextStyle(color: _P4StokJualScreenState._title, fontSize: 20),
      ),
      items: const [
        DropdownMenuItem(value: 'Padi', child: Text('Padi')),
        DropdownMenuItem(value: 'Jagung', child: Text('Jagung')),
      ],
      onChanged: onChanged,
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _P4StokJualScreenState._title,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
      ),
    );
  }
}

class _GradeSelector extends StatelessWidget {
  final _ProductGrade selected;
  final ValueChanged<_ProductGrade> onChanged;

  const _GradeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradeButton(
            label: 'Standar',
            selected: selected == _ProductGrade.standard,
            onTap: () => onChanged(_ProductGrade.standard),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _GradeButton(
            label: 'Premium',
            selected: selected == _ProductGrade.premium,
            onTap: () => onChanged(_ProductGrade.premium),
          ),
        ),
      ],
    );
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GradeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _P4StokJualScreenState._green : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : _P4StokJualScreenState._title,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 174,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD0D5DD),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_upload_outlined, color: Color(0xFFD0D5DD), size: 38),
          SizedBox(height: 12),
          Text(
            'Tap untuk upload foto produk',
            style: TextStyle(
              color: _P4StokJualScreenState._muted,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProductGrade { standard, premium }

class _StockProduct {
  final String product;
  final String variety;
  final int stock;
  final String price;
  final _ProductGrade grade;

  const _StockProduct({
    required this.product,
    required this.variety,
    required this.stock,
    required this.price,
    required this.grade,
  });
}
