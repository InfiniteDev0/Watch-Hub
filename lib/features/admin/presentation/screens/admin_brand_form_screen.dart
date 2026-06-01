import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/admin/logic/providers/admin_brands_provider.dart';
import 'package:watch_hub/features/admin/presentation/widgets/field.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/shared/widgets/image_picker_field.dart';

class AdminBrandFormScreen extends StatefulWidget {
  final BrandModel? existing;
  const AdminBrandFormScreen({super.key, this.existing});

  @override
  State<AdminBrandFormScreen> createState() => _AdminBrandFormScreenState();
}

class _AdminBrandFormScreenState extends State<AdminBrandFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameCtrl =
      TextEditingController(text: widget.existing?.name);
  late final _descCtrl =
      TextEditingController(text: widget.existing?.description);
  late String? _logoUrl = widget.existing?.logoUrl;
  late String? _bannerUrl = widget.existing?.bannerUrl;
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      'logo_url': (_logoUrl != null && _logoUrl!.isNotEmpty) ? _logoUrl : null,
      'banner_url':
          (_bannerUrl != null && _bannerUrl!.isNotEmpty) ? _bannerUrl : null,
      'is_active': _isActive,
    };

    final prov = context.read<AdminBrandsProvider>();
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
        widget.existing == null ? 'Brand created' : 'Brand updated',
      );
      Navigator.of(context).pop();
    } else {
      ToastHelper.showError(context, prov.error ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final saving = context.watch<AdminBrandsProvider>().isSaving;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEdit ? 'Edit Brand' : 'New Brand',
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
            _section('Brand Info'),
            _field(
              label: 'Brand Name',
              required: true,
              child: _input(
                _nameCtrl,
                hint: 'e.g. Rolex',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
            _field(
              label: 'Description',
              child: _input(
                _descCtrl,
                hint: 'Short brand description…',
                maxLines: 3,
              ),
            ),
            _section('Media'),
            _field(
              label: 'Logo',
              child: SizedBox(
                width: 140,
                child: ImagePickerField(
                  value: _logoUrl,
                  folder: 'brands/logos',
                  hint: 'Upload logo',
                  aspectRatio: 1.0,
                  onChanged: (url) => setState(() => _logoUrl = url),
                ),
              ),
            ),
            _field(
              label: 'Banner',
              child: ImagePickerField(
                value: _bannerUrl,
                folder: 'brands/banners',
                hint: 'Upload banner',
                aspectRatio: 16 / 9,
                onChanged: (url) => setState(() => _bannerUrl = url),
              ),
            ),
            _section('Settings'),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Active',
                style: TextStyle(fontFamily: AppAssets.manrope, fontSize: 14),
              ),
              value: _isActive,
              activeColor: Colors.black,
              onChanged: (v) => setState(() => _isActive = v),
            ),
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

  Widget _input(
    TextEditingController ctrl, {
    String? hint,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontFamily: AppAssets.manrope, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: AppAssets.manrope, color: Colors.black38),
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
}
