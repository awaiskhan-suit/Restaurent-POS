// lib/screens/thermal_print_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../Colors/app_color.dart';
import '../models/order_model.dart';

class ThermalPrintScreen extends StatefulWidget {
  const ThermalPrintScreen({
    super.key,
    required this.order,
    this.customerName = 'Walk-in Customer',
  });

  final OrderModel order;

  /// Customer name for this specific slip (local to each receipt)
  final String customerName;

  @override
  State<ThermalPrintScreen> createState() => _ThermalPrintScreenState();
}

class _ThermalPrintScreenState extends State<ThermalPrintScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _paperOut;
  late final String _invoiceNo;
  bool _showReceipt = false;

  @override
  void initState() {
    super.initState();

    _invoiceNo = _generateInvoiceNo();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _paperOut = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Start printer animation, then show full receipt
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showReceipt = true);
      }
    });
  }

  /// Auto-generated invoice number, e.g. INV-20261023-483920
  String _generateInvoiceNo() {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final seq = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'INV-$datePart-$seq';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(double value) {
    final decimals = value % 1 == 0 ? 0 : 2;
    return 'Rs ${value.toStringAsFixed(decimals)}';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateStr = order.createdAt != null
        ? DateFormat('dd MMM yyyy').format(order.createdAt!)
        : '—';
    final timeStr = order.createdAt != null
        ? DateFormat('hh:mm a').format(order.createdAt!)
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: Text(
          'Print Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: _showReceipt
            ? _ThermalReceipt(
          order: order,
          invoiceNo: _invoiceNo,
          customerName: widget.customerName,
          dateStr: dateStr,
          timeStr: timeStr,
          formatPrice: _formatPrice,
        )
            : _PrinterAnimation(
          animation: _paperOut,
          order: order,
          invoiceNo: _invoiceNo,
          customerName: widget.customerName,
          dateStr: dateStr,
          timeStr: timeStr,
          formatPrice: _formatPrice,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Thermal printer body + paper rolling out
// -----------------------------------------------------------------------------
class _PrinterAnimation extends StatelessWidget {
  const _PrinterAnimation({
    required this.animation,
    required this.order,
    required this.invoiceNo,
    required this.customerName,
    required this.dateStr,
    required this.timeStr,
    required this.formatPrice,
  });

  final Animation<double> animation;
  final OrderModel order;
  final String invoiceNo;
  final String customerName;
  final String dateStr;
  final String timeStr;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    // Thermal roll width ~ 280 logical px
    const double rollWidth = 280;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Paper height grows as it "prints"
        final paperHeight = 80.0 + (420.0 * t);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Printer housing
            Container(
              width: rollWidth + 40,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'THERMAL PRINTER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Slot
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            // Paper coming out
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: Transform.translate(
                  offset: Offset(0, -8 + (8 * (1 - t))),
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Container(
                      width: rollWidth,
                      height: paperHeight,
                      margin: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F0),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _ReceiptContent(
                          order: order,
                          invoiceNo: invoiceNo,
                          customerName: customerName,
                          dateStr: dateStr,
                          timeStr: timeStr,
                          formatPrice: formatPrice,
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              t < 1.0 ? 'Printing…' : 'Done',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13.sp,
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Full receipt after animation
// -----------------------------------------------------------------------------
class _ThermalReceipt extends StatelessWidget {
  const _ThermalReceipt({
    required this.order,
    required this.invoiceNo,
    required this.customerName,
    required this.dateStr,
    required this.timeStr,
    required this.formatPrice,
  });

  final OrderModel order;
  final String invoiceNo;
  final String customerName;
  final String dateStr;
  final String timeStr;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _ReceiptContent(
          order: order,
          invoiceNo: invoiceNo,
          customerName: customerName,
          dateStr: dateStr,
          timeStr: timeStr,
          formatPrice: formatPrice,
          compact: false,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared receipt content (thermal style)
// -----------------------------------------------------------------------------
class _ReceiptContent extends StatelessWidget {
  const _ReceiptContent({
    required this.order,
    required this.invoiceNo,
    required this.customerName,
    required this.dateStr,
    required this.timeStr,
    required this.formatPrice,
    required this.compact,
  });

  final OrderModel order;
  final String invoiceNo;
  final String customerName;
  final String dateStr;
  final String timeStr;
  final String Function(double) formatPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textDark = Colors.black87;
    final textMuted = Colors.black54;

    TextStyle headStyle() => TextStyle(
        color: textDark, fontSize: 10, fontWeight: FontWeight.w700);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 0,
        vertical: compact ? 12 : 0,
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Icon(Icons.restaurant, size: 22, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            order.restaurantName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.restaurantAddress,
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 10, height: 1.3),
          ),
          const SizedBox(height: 2),
          Text(
            order.restaurantPhone,
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _dashedLine(),
          const SizedBox(height: 6),

          // Invoice number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice #',
                  style: TextStyle(color: textMuted, fontSize: 10)),
              Text(
                invoiceNo,
                style: TextStyle(
                  color: textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Customer name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer',
                  style: TextStyle(color: textMuted, fontSize: 10)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  customerName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Date & time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: TextStyle(color: textMuted, fontSize: 10)),
              Text(timeStr, style: TextStyle(color: textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          _dashedLine(),
          const SizedBox(height: 8),

          // Header: S.No | ITEM | QTY | PRICE | NET AMT
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('S.No', style: headStyle()),
              ),
              Expanded(
                flex: 6,
                child: Text('ITEM', style: headStyle()),
              ),
              Expanded(
                flex: 2,
                child: Text('QTY',
                    textAlign: TextAlign.center, style: headStyle()),
              ),
              Expanded(
                flex: 4,
                child: Text('PRICE',
                    textAlign: TextAlign.right, style: headStyle()),
              ),
              Expanded(
                flex: 5,
                child: Text('NET AMT',
                    textAlign: TextAlign.right, style: headStyle()),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _dashedLine(),
          const SizedBox(height: 6),

          // Items
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final unitPrice =
            item.quantity > 0 ? item.subtotal / item.quantity : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: textDark, fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      item.name,
                      style: TextStyle(color: textDark, fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textDark, fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      formatPrice(unitPrice.toDouble()),
                      textAlign: TextAlign.right,
                      style: TextStyle(color: textDark, fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      formatPrice(item.subtotal),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 4),
          _dashedLine(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                formatPrice(order.total),
                style: TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _dashedLine(),
          const SizedBox(height: 10),
          Text(
            'Thank you! Visit again',
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${order.status.toUpperCase()}',
            style: TextStyle(color: textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _dashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}