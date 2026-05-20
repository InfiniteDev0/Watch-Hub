import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/orders/logic/providers/order_provider.dart';
import 'package:watch_hub/features/profile/data/models/address_model.dart';
import 'package:watch_hub/features/profile/logic/providers/profile_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ProfileProvider>().fetchAddresses(userId).then((_) {
          if (!mounted) return;
          final addresses = context.read<ProfileProvider>().addresses;
          if (addresses.isNotEmpty) {
            final def = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
            setState(() => _selectedAddress = def);
          }
        });
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping address'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    final shippingAddress = {
      'full_name': _selectedAddress!.fullName,
      'street': _selectedAddress!.street,
      'city': _selectedAddress!.city,
      'postal_code': _selectedAddress!.postalCode,
      'country': _selectedAddress!.country,
    };

    final order = await context.read<OrderProvider>().placeOrder(
          shippingAddress: shippingAddress,
        );

    if (!mounted) return;

    if (order != null) {
      // Cart was cleared server-side; sync local provider
      await context.read<CartProvider>().fetchCart();
      if (!mounted) return;
      // Navigate to order detail, replacing both checkout and cart
      context.go('/profile/orders/${order.id}');
    } else {
      final err =
          context.read<OrderProvider>().error ?? 'Failed to place order';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final profileProvider = context.watch<ProfileProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final addresses = profileProvider.addresses;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order summary ──────────────────────────────────
                  const _SectionLabel('Order Summary'),
                  const SizedBox(height: 12),
                  if (cart != null)
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} × ${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: AppAssets.manrope,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: AppAssets.manrope,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(color: Color(0xFFF0F0F0), height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(cart?.total ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Shipping address ───────────────────────────────
                  const _SectionLabel('Shipping Address'),
                  const SizedBox(height: 12),
                  if (profileProvider.addressesLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                  else if (addresses.isEmpty)
                    _NoAddressPrompt(
                      onAdd: () => context.push('/profile/addresses'),
                    )
                  else
                    _AddressPicker(
                      addresses: addresses,
                      selected: _selectedAddress,
                      onSelect: (a) => setState(() => _selectedAddress = a),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: orderProvider.isPlacing ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: orderProvider.isPlacing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Address picker ─────────────────────────────────────────────────

class _AddressPicker extends StatelessWidget {
  final List<AddressModel> addresses;
  final AddressModel? selected;
  final ValueChanged<AddressModel> onSelect;

  const _AddressPicker({
    required this.addresses,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.map((address) {
        final isSelected = selected?.id == address.id;
        return GestureDetector(
          onTap: () => onSelect(address),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected ? Colors.black : Colors.black38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.fullName,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${address.street}, ${address.city}',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${address.postalCode}, ${address.country}',
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NoAddressPrompt extends StatelessWidget {
  final VoidCallback onAdd;

  const _NoAddressPrompt({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: Colors.black38),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No saved addresses',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text(
              'Add',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: AppAssets.manrope,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.black54,
      ),
    );
  }
}
