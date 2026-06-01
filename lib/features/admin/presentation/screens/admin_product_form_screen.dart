import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_brands_provider.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_products_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/field.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/shared/widgets/image_picker_field.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? existing;
  const AdminProductFormScreen({super.key, this.existing});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _skuCtrl = TextEditingController(text: widget.existing?.sku);
  late final _descCtrl =
      TextEditingController(text: widget.existing?.description);
  late final _priceCtrl = TextEditingController(
      text: widget.existing?.price.toStringAsFixed(2));
  late final _comparePriceCtrl = TextEditingController(
      text: widget.existing?.discountPrice?.toStringAsFixed(2));
  late final _stockCtrl = TextEditingController(
      text: widget.existing?.stockQuantity?.toString());

  // Product images (up to 3). Uploaded via ImagePickerField → public URLs.
  late final List<String?> _imageUrls = List<String?>.generate(
    3,
    (i) => (widget.existing?.images ?? []).length > i
        ? widget.existing!.images[i]
        : null,
  );

  // Specs
  late final _movementCtrl =
      TextEditingController(text: widget.existing?.movementType);
  late final _caseMaterialCtrl =
      TextEditingController(text: widget.existing?.caseMaterial);
  late final _caseDiaCtrl = TextEditingController(
      text: widget.existing?.caseDiameterMm?.toString());
  late final _dialColorCtrl =
      TextEditingController(text: widget.existing?.dialColor);
  late final _bandMaterialCtrl =
      TextEditingController(text: widget.existing?.bandMaterial);
  late final _waterResCtrl = TextEditingController(
      text: widget.existing?.waterResistanceM?.toString());

  // State
  String? _selectedBrandId;
  String _status = 'DRAFT';
  bool _isNewArrival = false;
  bool _isBestSeller = false;
  bool _isFeatured = false;
  bool _isActive = true;

  List<BrandModel> _brands = [];
  bool _brandsLoading = true;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _selectedBrandId = p.brandId;
      _status = p.status.toUpperCase();
      _isNewArrival = p.isNewArrival;
      _isBestSeller = p.isBestSeller;
      _isFeatured = p.isFeatured;
      _isActive = p.isActive;
    }
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final prov = context.read<AdminBrandsProvider>();
      await prov.load();
      if (!mounted) return;
      setState(() {
        _brands = prov.brands;
        _brandsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _brandsLoading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _skuCtrl, _descCtrl, _priceCtrl, _comparePriceCtrl,
      _stockCtrl, _movementCtrl, _caseMaterialCtrl, _caseDiaCtrl,
      _dialColorCtrl, _bandMaterialCtrl, _waterResCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final images = _imageUrls
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();

    final data = {
      'name': _nameCtrl.text.trim(),
      'sku': _skuCtrl.text.trim().isNotEmpty ? _skuCtrl.text.trim() : null,
      'description': _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      'price': double.tryParse(_priceCtrl.text),
      'compare_at_price': _comparePriceCtrl.text.trim().isNotEmpty
          ? double.tryParse(_comparePriceCtrl.text)
          : null,
      'brand_id': _selectedBrandId,
      'images': images,
      'stock_quantity': int.tryParse(_stockCtrl.text) ?? 0,
      'status': _status,
      'is_new_arrival': _isNewArrival,
      'is_best_seller': _isBestSeller,
      'is_featured': _isFeatured,
      'is_active': _isActive,
      'movement_type': _movementCtrl.text.trim().isNotEmpty ? _movementCtrl.text.trim() : null,
      'case_material': _caseMaterialCtrl.text.trim().isNotEmpty ? _caseMaterialCtrl.text.trim() : null,
      'case_diameter_mm': _caseDiaCtrl.text.trim().isNotEmpty ? double.tryParse(_caseDiaCtrl.text) : null,
      'dial_color': _dialColorCtrl.text.trim().isNotEmpty ? _dialColorCtrl.text.trim() : null,
      'band_material': _bandMaterialCtrl.text.trim().isNotEmpty ? _bandMaterialCtrl.text.trim() : null,
      'water_resistance_m': _waterResCtrl.text.trim().isNotEmpty ? int.tryParse(_waterResCtrl.text) : null,
    };

    final prov = context.read<AdminProductsProvider>();
    final bool ok;
    if (widget.existing == null) {
      ok = await prov.create(data);
    } else {
      ok = await prov.update(widget.existing!.id, data);
    }

    if (!mounted) return;
    if (ok) {
      ToastHelper.showSuccess(
        context,
        widget.existing == null ? 'Product created' : 'Product updated',
      );
      Navigator.of(context).pop();
    } else {
      ToastHelper.showError(context, prov.error ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final saving = context.watch<AdminProductsProvider>().isSaving;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEdit ? 'Edit Product' : 'New Product',
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: Text(
                      isEdit ? 'Save' : 'Create',
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _section('Basic Info'),
            _field(
              label: 'Product Name',
              required: true,
              child: _input(_nameCtrl, hint: 'e.g. Submariner Date 41',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null),
            ),
            _field(
              label: 'Brand',
              required: true,
              child: _brandsLoading
                  ? const LinearProgressIndicator(color: Colors.black)
                  : DropdownButtonFormField<String>(
                      value: _selectedBrandId,
                      decoration: _dropDecoration(),
                      hint: const Text('Select brand'),
                      items: _brands
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name,
                                    style: const TextStyle(
                                        fontFamily: AppAssets.manrope,
                                        fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedBrandId = v),
                      validator: (v) =>
                          v == null ? 'Please select a brand' : null,
                    ),
            ),
            _field(
              label: 'SKU',
              child: _input(_skuCtrl, hint: 'e.g. ROL-SUB-41'),
            ),
            _field(
              label: 'Description',
              child: _input(_descCtrl,
                  hint: 'Product description…',
                  maxLines: 4),
            ),

            _section('Pricing & Stock'),
            _row([
              _field(
                label: 'Price (£)',
                required: true,
                child: _input(_priceCtrl,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    }),
              ),
              _field(
                label: 'Sale Price (£)',
                child: _input(_comparePriceCtrl,
                    hint: 'Optional',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ]),
              ),
            ]),
            _field(
              label: 'Stock Quantity',
              child: _input(_stockCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            ),

            _section('Status & Flags'),
            _field(
              label: 'Status',
              child: DropdownButtonFormField<String>(
                value: _status,
                decoration: _dropDecoration(),
                items: const [
                  DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(
                      value: 'ARCHIVED', child: Text('Archived')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'DRAFT'),
              ),
            ),
            _switches(),

            _section('Images'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            i == 0 ? 'Main' : 'Image ${i + 1}',
                            style: const TextStyle(
                              fontFamily: AppAssets.manrope,
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        ImagePickerField(
                          value: _imageUrls[i],
                          folder: 'products',
                          hint: 'Upload',
                          onChanged: (url) =>
                              setState(() => _imageUrls[i] = url),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),

            _section('Watch Specs'),
            _row([
              _field(
                label: 'Movement',
                child: _input(_movementCtrl, hint: 'e.g. Automatic'),
              ),
              _field(
                label: 'Case Material',
                child: _input(_caseMaterialCtrl, hint: 'e.g. Steel'),
              ),
            ]),
            _row([
              _field(
                label: 'Case Ø (mm)',
                child: _input(_caseDiaCtrl,
                    hint: '41',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              ),
              _field(
                label: 'Dial Color',
                child: _input(_dialColorCtrl, hint: 'e.g. Black'),
              ),
            ]),
            _row([
              _field(
                label: 'Band Material',
                child: _input(_bandMaterialCtrl, hint: 'e.g. Oyster'),
              ),
              _field(
                label: 'Water Res. (m)',
                child: _input(_waterResCtrl,
                    hint: '300',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  Widget _field({
    required String label,
    required Widget child,
    bool required = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Field(
          children: [
            FieldLabel(label, isRequired: required),
            child,
          ],
        ),
      );

  Widget _row(List<Widget> children) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((w) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: w,
                  ),
                ))
            .toList(),
      );

  Widget _input(
    TextEditingController ctrl, {
    String? hint,
    int? maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(fontFamily: AppAssets.manrope, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(fontFamily: AppAssets.manrope, color: Colors.black38),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFC62828), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFC62828), width: 1.5),
          ),
        ),
      );

  InputDecoration _dropDecoration() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      );

  Widget _switches() => Column(
        children: [
          _toggle('Active', _isActive, (v) => setState(() => _isActive = v)),
          _toggle('New Arrival', _isNewArrival,
              (v) => setState(() => _isNewArrival = v)),
          _toggle('Best Seller', _isBestSeller,
              (v) => setState(() => _isBestSeller = v)),
          _toggle(
              'Featured', _isFeatured, (v) => setState(() => _isFeatured = v)),
        ],
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          label,
          style: const TextStyle(fontFamily: AppAssets.manrope, fontSize: 14),
        ),
        value: value,
        activeColor: Colors.black,
        onChanged: onChanged,
      );
}
