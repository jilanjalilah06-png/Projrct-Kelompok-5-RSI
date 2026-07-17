import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constanst/api_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/language_controller.dart';

class P4StokJualScreen extends StatefulWidget {
  const P4StokJualScreen({super.key});

  @override
  State<P4StokJualScreen> createState() => _P4StokJualScreenState();
}

class _P4StokJualScreenState extends State<P4StokJualScreen> {
  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthController>();
    final products = context.read<ProductController>();
    await products.loadCategories();

    final sellerId = auth.currentUser?.id;
    if (sellerId != null) {
      await products.loadSellerProducts(sellerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<ProductController>();
    final currentUserId = auth.currentUser?.id;
    final products = controller.products.where((p) => p.sellerId == currentUserId).toList();
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenBg = isDark ? const Color(0xFF121212) : _background;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onAdd: _openAddStockPage),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: controller.isLoading && products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 160),
                              _EmptyMessage(
                                message: isEnglish 
                                    ? 'No sellable stock in database.' 
                                    : 'Belum ada stok jual dari database.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                            itemCount: products.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductCard(
                                product: product,
                                onEdit: () => _openEditStockPage(product),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddStockPage() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddStockPage()),
    );

    if (created == true) {
      await _loadData();
    }
  }

  Future<void> _openEditStockPage(ProductModel product) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditStockPage(product: product)),
    );

    if (updated == true) {
      await _loadData();
    }
  }
}

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  CategoryModel? _selectedCategory;
  _ProductGrade _selectedGrade = _ProductGrade.standard;
  bool _saving = false;

  List<int>? _imageBytes;
  String? _imageName;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser?.role != UserModel.rolePetani) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses ditolak: Hanya untuk Petani.'),
          ),
        );
        Navigator.pop(context);
        return;
      }
      context.read<ProductController>().loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ProductController>();
    final categories = controller.categories
        .where((category) => category.name == 'Beras' || category.name == 'Jagung')
        .toList();

    final screenBg = isDark ? const Color(0xFF121212) : _P4StokJualScreenState._background;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: isEnglish ? 'Add Product' : 'Tambah Produk',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputLabel(isEnglish ? 'Select Product' : 'Pilih Produk'),
                    const SizedBox(height: 10),
                    _CategoryDropdown(
                      value: _selectedCategory,
                      categories: categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _nameController.text = value?.name ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Product Name/Type' : 'Nama/Jenis Produk'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _nameController,
                      hintText: isEnglish ? 'Example: Pandan Wangi Rice' : 'Contoh: Beras Pandan Wangi',
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Description' : 'Deskripsi'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _descriptionController,
                      hintText: isEnglish ? 'Short description of product' : 'Deskripsi singkat produk',
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Price/Kg' : 'Harga/Kg'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _priceController,
                      hintText: '12000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Stock (Kg)' : 'Stok (Kg)'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _stockController,
                      hintText: '50',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Product Photo' : 'Foto Produk'),
                    const SizedBox(height: 10),
                    _ImageUploadCard(
                      imageBytes: _imageBytes,
                      imageName: _imageName,
                      onTap: _pickImage,
                      isDark: isDark,
                      isEnglish: isEnglish,
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Product Grade' : 'Grade Produk'),
                    const SizedBox(height: 12),
                    _GradeSelector(
                      selected: _selectedGrade,
                      onChanged: (grade) {
                        setState(() => _selectedGrade = grade);
                      },
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saving ? null : () => _save(isEnglish),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _P4StokJualScreenState._green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Text(
                                isEnglish ? 'Save' : 'Simpan',
                                style: const TextStyle(
                                  fontSize: 22,
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

  Future<void> _save(bool isEnglish) async {
    final category = _selectedCategory;
    final name = _nameController.text.trim();
    final priceText = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final stockText = _stockController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (category == null || name.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish 
                ? 'Please complete product, name, price, and stock.' 
                : 'Lengkapi produk, nama, harga, dan stok.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<ProductController>();
    final success = await controller.createProduct(
      categoryId: category.id,
      name: _selectedGrade == _ProductGrade.premium && !name.toLowerCase().contains('premium')
          ? '$name Premium'
          : name,
      description: _descriptionController.text.trim().isEmpty
          ? 'Stok jual ${category.name} dari petani AgriConnect'
          : _descriptionController.text.trim(),
      price: double.parse(priceText),
      stock: int.parse(stockText),
      unit: 'kg',
      imageBytes: _imageBytes,
      imageName: _imageName,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ?? (isEnglish ? 'Failed to save stock.' : 'Gagal menyimpan stok.'),
          ),
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;

  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1E1E1E) : _P4StokJualScreenState._green;

    return Container(
      height: 54,
      color: headerBg,
      padding: const EdgeInsets.only(left: 24, right: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isEnglish ? 'Product List' : 'Daftar Produk',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: isEnglish ? 'Add stock' : 'Tambah stok',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1E1E1E) : _P4StokJualScreenState._green;

    return Container(
      height: 58,
      color: headerBg,
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
  final ProductModel product;
  final VoidCallback? onEdit;

  const _ProductCard({required this.product, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPremium = product.name.toLowerCase().contains('premium') ||
        product.name.toLowerCase().contains('grade a') ||
        product.name.toLowerCase().contains('organik');

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : _P4StokJualScreenState._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _P4StokJualScreenState._muted;
    final iconBg = isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Section
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22).copyWith(
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
              child: (product.image != null && product.image!.isNotEmpty)
                  ? Image.network(
                      '${ApiConstants.storageUrl}/${product.image}',
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                    )
                  : _buildFallbackImage(),
            )
          ),
          // Product Info Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${isEnglish ? "Stock: " : "Stok: "}${product.stock} ${product.unit}',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _GradeBadge(isPremium: isPremium),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_formatRupiah(product.price)}/${product.unit}',
                        style: const TextStyle(
                          color: Color(0xFF00883E),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _StatusBadge(status: product.status),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      isEnglish ? 'Edit Product' : 'Edit Produk',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _P4StokJualScreenState._green,
                      side: const BorderSide(color: Color(0xFF2D832F), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      product.category?['name'] == 'Jagung' 
          ? 'assets/image/jagung.jpg' 
          : 'assets/image/beras.jpg',
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          product.category?['name'] == 'Jagung' ? Icons.eco : Icons.grain,
          color: const Color(0xFF079447),
          size: 48,
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }
}

class _GradeBadge extends StatelessWidget {
  final bool isPremium;

  const _GradeBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badgeBg = isPremium 
        ? (isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFFF1B8))
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7));
    final textColor = isPremium 
        ? (isDark ? const Color(0xFFFF9A3C) : const Color(0xFFD46B08))
        : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        isPremium 
            ? (isEnglish ? 'Premium' : 'Premium') 
            : (isEnglish ? 'Standard' : 'Standar'),
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isPublic = status == 'public';

    final badgeBg = isPublic 
        ? const Color(0xFFE2F0E9) 
        : (status == 'ditolak' ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3CD));
    final textColor = isPublic 
        ? const Color(0xFF2C6A4F) 
        : (status == 'ditolak' ? const Color(0xFFC62828) : const Color(0xFF856404));

    String label = isEnglish ? 'Review' : 'Tinjau';
    if (isPublic) {
      label = isEnglish ? 'Public' : 'Public';
    } else if (status == 'ditolak') {
      label = isEnglish ? 'Rejected' : 'Ditolak';
    } else {
      label = isEnglish ? 'Private' : 'Privat';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    return Text(
      text,
      style: TextStyle(
        color: labelColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final CategoryModel? value;
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<CategoryModel>(
      value: value,
      isExpanded: true,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      decoration: _inputDecoration(isDark),
      hint: Text(
        isEnglish ? '-- Select --' : '-- Pilih --',
        style: TextStyle(
          color: isDark ? const Color(0xFFB0B0B0) : _P4StokJualScreenState._title,
          fontSize: 20,
        ),
      ),
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category.name,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ))
          .toList(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : _P4StokJualScreenState._title;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: textColor,
        fontSize: 20,
      ),
      decoration: _inputDecoration(isDark, hintText: hintText),
    );
  }
}

InputDecoration _inputDecoration(bool isDark, {String? hintText}) {
  final fillBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
  final borderSide = isDark ? BorderSide.none : const BorderSide(color: Color(0xFFD0D5DD));

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF98A2B3),
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: fillBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: borderSide,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: borderSide,
    ),
  );
}

class _GradeSelector extends StatelessWidget {
  final _ProductGrade selected;
  final ValueChanged<_ProductGrade> onChanged;

  const _GradeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Row(
      children: [
        Expanded(
          child: _GradeButton(
            label: isEnglish ? 'Standard' : 'Standar',
            selected: selected == _ProductGrade.standard,
            onTap: () => onChanged(_ProductGrade.standard),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _GradeButton(
            label: isEnglish ? 'Premium' : 'Premium',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? const Color(0xFF2A2A2A) : Colors.transparent;
    final unselectedText = isDark ? Colors.white : _P4StokJualScreenState._title;

    return Material(
      color: selected ? _P4StokJualScreenState._green : unselectedBg,
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
                color: selected ? Colors.white : unselectedText,
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

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _P4StokJualScreenState._muted,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum _ProductGrade { standard, premium }

class _ImageUploadCard extends StatelessWidget {
  final List<int>? imageBytes;
  final String? imageName;
  final VoidCallback onTap;
  final bool isDark;
  final bool isEnglish;

  const _ImageUploadCard({
    required this.imageBytes,
    required this.imageName,
    required this.onTap,
    required this.isDark,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final borderBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white70 : const Color(0xFF667085);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: borderBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFD0D5DD),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(imageBytes!),
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                imageName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish ? 'Tap to change photo' : 'Ketuk untuk mengubah foto',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload_outlined,
                color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF079447),
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                isEnglish ? 'Upload Product Photo' : 'Unggah Foto Produk',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF001A3D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish ? 'Format: JPG, PNG (max 2MB)' : 'Format: JPG, PNG (maks 2MB)',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class EditStockPage extends StatefulWidget {
  final ProductModel product;

  const EditStockPage({super.key, required this.product});

  @override
  State<EditStockPage> createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  bool _saving = false;

  List<int>? _imageBytes;
  String? _imageName;
  bool _imageChanged = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = image.name;
          _imageChanged = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.round().toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenBg = isDark ? const Color(0xFF121212) : _P4StokJualScreenState._background;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: isEnglish ? 'Edit Product' : 'Edit Produk',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current/New Image Preview
                    _InputLabel(isEnglish ? 'Product Photo' : 'Foto Produk'),
                    const SizedBox(height: 10),
                    _EditImageCard(
                      imageBytes: _imageBytes,
                      imageName: _imageName,
                      currentImagePath: widget.product.image,
                      imageChanged: _imageChanged,
                      onTap: _pickImage,
                      isDark: isDark,
                      isEnglish: isEnglish,
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Product Name' : 'Nama Produk'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _nameController,
                      hintText: isEnglish ? 'Product name' : 'Nama produk',
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Description' : 'Deskripsi'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _descriptionController,
                      hintText: isEnglish ? 'Short description' : 'Deskripsi singkat',
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Price/Kg' : 'Harga/Kg'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _priceController,
                      hintText: '12000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _InputLabel(isEnglish ? 'Stock (Kg)' : 'Stok (Kg)'),
                    const SizedBox(height: 10),
                    _TextInput(
                      controller: _stockController,
                      hintText: '50',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saving ? null : () => _save(isEnglish),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _P4StokJualScreenState._green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Text(
                                isEnglish ? 'Save Changes' : 'Simpan Perubahan',
                                style: const TextStyle(
                                  fontSize: 22,
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

  Future<void> _save(bool isEnglish) async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final stockText = _stockController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (name.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish
                ? 'Please complete name, price, and stock.'
                : 'Lengkapi nama, harga, dan stok.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<ProductController>();
    final success = await controller.updateProduct(
      widget.product.id,
      name: name,
      description: _descriptionController.text.trim(),
      price: double.parse(priceText),
      stock: int.parse(stockText),
      imageBytes: _imageChanged ? _imageBytes : null,
      imageName: _imageChanged ? _imageName : null,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ?? (isEnglish ? 'Failed to update product.' : 'Gagal memperbarui produk.'),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEnglish ? 'Product updated successfully!' : 'Produk berhasil diperbarui!'),
        backgroundColor: _P4StokJualScreenState._green,
      ),
    );
    Navigator.pop(context, true);
  }
}

class _EditImageCard extends StatelessWidget {
  final List<int>? imageBytes;
  final String? imageName;
  final String? currentImagePath;
  final bool imageChanged;
  final VoidCallback onTap;
  final bool isDark;
  final bool isEnglish;

  const _EditImageCard({
    required this.imageBytes,
    required this.imageName,
    required this.currentImagePath,
    required this.imageChanged,
    required this.onTap,
    required this.isDark,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final borderBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white70 : const Color(0xFF667085);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: borderBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFD0D5DD),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (imageChanged && imageBytes != null) ...[
              // Show newly selected image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(imageBytes!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                imageName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish ? 'Tap to change photo' : 'Ketuk untuk mengubah foto',
                style: TextStyle(color: textColor, fontSize: 13),
              ),
            ] else if (currentImagePath != null && currentImagePath!.isNotEmpty) ...[
              // Show current server image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConstants.storageUrl}/$currentImagePath',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    currentImagePath!.contains('jagung') 
                        ? 'assets/image/jagung.jpg' 
                        : 'assets/image/beras.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      height: 160,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: isDark ? Colors.white54 : const Color(0xFF667085),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: const Color(0xFF079447),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEnglish ? 'Tap to change photo' : 'Ketuk untuk mengubah foto',
                    style: TextStyle(
                      color: const Color(0xFF079447),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // No image at all
              Icon(
                Icons.cloud_upload_outlined,
                color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF079447),
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                isEnglish ? 'Upload Product Photo' : 'Unggah Foto Produk',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF001A3D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEnglish ? 'Format: JPG, PNG (max 2MB)' : 'Format: JPG, PNG (maks 2MB)',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
