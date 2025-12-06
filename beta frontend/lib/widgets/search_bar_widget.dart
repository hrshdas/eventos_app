import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable search bar widget with debouncing
class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final Duration debounceDuration;
  final bool showCartIcon;
  final int? cartItemCount;
  final VoidCallback? onCartTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search...',
    this.onSearch,
    this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.showCartIcon = false,
    this.cartItemCount,
    this.onCartTap,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.onChanged?.call(value);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch?.call(value);
    });
  }

  void _onSubmitted(String value) {
    _debounceTimer?.cancel();
    widget.onSearch?.call(value);
  }

  void clearSearch() {
    _controller.clear();
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.darkGrey;
    final txtColor = widget.textColor ?? AppTheme.white;
    final hintClr = widget.hintColor ?? AppTheme.textGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppTheme.textGrey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: txtColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: hintClr, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSubmitted,
            ),
          ),
          if (_controller.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: clearSearch,
              child: Icon(Icons.clear, color: hintClr, size: 18),
            ),
          ],
          if (widget.showCartIcon) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onCartTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: AppTheme.white,
                      size: 20,
                    ),
                  ),
                  if (widget.cartItemCount != null && widget.cartItemCount! > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.cartItemCount! > 9 ? '9+' : widget.cartItemCount}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

