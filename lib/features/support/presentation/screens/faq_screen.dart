import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'FAQ',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: const [
          _FaqCategory(
            title: 'Orders & Shipping',
            items: [
              _FaqItem(
                question: 'How long does shipping take?',
                answer:
                    'Standard shipping typically takes 5–7 business days. Express shipping (2–3 business days) is available at checkout for an additional fee.',
              ),
              _FaqItem(
                question: 'Can I track my order?',
                answer:
                    'Yes. Once your order ships, you will receive a tracking number via email. You can also view your order status in the Orders section of your profile.',
              ),
              _FaqItem(
                question: 'What is your return policy?',
                answer:
                    'We accept returns within 30 days of delivery. Items must be unworn, in original packaging, with all tags attached. Initiated returns are refunded to the original payment method within 5–10 business days.',
              ),
              _FaqItem(
                question: 'Can I modify or cancel my order?',
                answer:
                    'Orders can be cancelled while they are in "Pending" status — simply go to your order in the Orders page and tap "Cancel Order". Once an order has been confirmed or shipped, modifications are no longer possible.',
              ),
            ],
          ),
          _FaqCategory(
            title: 'Products & Authenticity',
            items: [
              _FaqItem(
                question: 'Are all watches authentic?',
                answer:
                    'Absolutely. Every watch on WatchHub is sourced directly from authorised dealers and comes with full manufacturer documentation. We do not sell replicas or grey-market pieces.',
              ),
              _FaqItem(
                question: 'Do you offer warranties?',
                answer:
                    'All watches carry the original manufacturer warranty. In addition, WatchHub provides a 12-month service guarantee covering manufacturer defects beyond the standard warranty.',
              ),
              _FaqItem(
                question: 'How do I choose the right watch size?',
                answer:
                    'Each product page lists the case diameter (mm) and case thickness under "Product Details". As a general guide, case diameters of 38–42 mm suit most wrists. If you need personalised advice, contact our support team.',
              ),
            ],
          ),
          _FaqCategory(
            title: 'Payments & Security',
            items: [
              _FaqItem(
                question: 'What payment methods do you accept?',
                answer:
                    'We accept all major credit and debit cards (Visa, Mastercard, Amex), PayPal, and Apple Pay / Google Pay where available.',
              ),
              _FaqItem(
                question: 'Is my payment information secure?',
                answer:
                    'Yes. All transactions are encrypted using TLS 1.3. We do not store full card numbers — payment data is tokenised and processed by our PCI-DSS compliant payment provider.',
              ),
              _FaqItem(
                question: 'Can I pay in instalments?',
                answer:
                    'Instalment options (e.g. buy-now-pay-later) are available at checkout depending on your region. Eligible orders will display the option automatically during payment.',
              ),
            ],
          ),
          _FaqCategory(
            title: 'Account & Profile',
            items: [
              _FaqItem(
                question: 'How do I update my profile?',
                answer:
                    'Go to Profile → Personal Information to edit your name and phone number. Changes are saved to your account immediately.',
              ),
              _FaqItem(
                question: 'How do I change my password?',
                answer:
                    'Use the Forgot Password flow on the login screen. You will receive a one-time code to your registered email, which you can use to set a new password.',
              ),
              _FaqItem(
                question: 'Can I delete my account?',
                answer:
                    'Yes. Please contact our support team via the Contact page or email support@watchhub.com. Accounts are permanently deleted within 30 days of the request, in accordance with our privacy policy.',
              ),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Category accordion ──────────────────────────────────────────────────────

class _FaqCategory extends StatefulWidget {
  final String title;
  final List<_FaqItem> items;

  const _FaqCategory({required this.title, required this.items});

  @override
  State<_FaqCategory> createState() => _FaqCategoryState();
}

class _FaqCategoryState extends State<_FaqCategory> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: AppAssets.instrumentSerif,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE8E8E8)),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.items
                .map((item) => _FaqItemTile(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Individual Q&A tile ─────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqItemTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqItemTile({required this.item});

  @override
  State<_FaqItemTile> createState() => _FaqItemTileState();
}

class _FaqItemTileState extends State<_FaqItemTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _open ? Icons.remove : Icons.add,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              widget.item.answer,
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                color: Colors.black54,
                height: 1.7,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
