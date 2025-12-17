import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../core/location/location_provider.dart';
import 'search_bar_widget.dart';
import 'eventos_logo_svg.dart';

/// Shared header card widget with functional search, date picker, and city selector
/// Can be used across all screens for consistency
class SharedHeaderCard extends StatefulWidget {
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool showCartIcon;
  final VoidCallback? onCartTap;
  final int? cartItemCount;
  final Function(String)? onSearch;
  final String? searchHint;

  const SharedHeaderCard({
    super.key,
    this.backgroundColor,
    this.backgroundGradient,
    this.showCartIcon = false,
    this.onCartTap,
    this.cartItemCount,
    this.onSearch,
    this.searchHint,
  });

  @override
  State<SharedHeaderCard> createState() => _SharedHeaderCardState();
}

class _SharedHeaderCardState extends State<SharedHeaderCard> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCity() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select City',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...LocationProvider.cities.map((city) => ListTile(
                  title: Text(city),
                  onTap: () => Navigator.pop(context, city),
                )),
          ],
        ),
      ),
    );
    if (selected != null) {
      locationProvider.setCity(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final selectedCity = locationProvider.selectedCity ?? 'Select City';
    final dateText = _selectedDate != null
        ? DateFormat('dd MMM, yyyy').format(_selectedDate!)
        : 'Event date';

    // Determine background decoration
    BoxDecoration decoration;
    if (widget.backgroundGradient != null) {
      decoration = BoxDecoration(
        gradient: widget.backgroundGradient,
        borderRadius: BorderRadius.circular(24),
      );
    } else {
      decoration = BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(24),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: decoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: widget.backgroundGradient != null
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome and Location Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Hi, Welcome',
                      style: widget.backgroundGradient != null
                          ? const TextStyle(
                              color: AppTheme.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            )
                          : AppTheme.welcomeText.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '👋',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _selectCity,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.backgroundGradient != null
                              ? Colors.white.withOpacity(0.25)
                              : AppTheme.darkGrey,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppTheme.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                selectedCity,
                                style: widget.backgroundGradient != null
                                    ? const TextStyle(
                                        color: AppTheme.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : AppTheme.locationText.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // App Logo
          const EventosLogoSvg(height: 38, color: AppTheme.white),
          const SizedBox(height: 18),
          // Search Bar
          SearchBarWidget(
            hintText: widget.searchHint ?? 'Search BBQ grill, DJ, tents...',
            showCartIcon: widget.showCartIcon,
            cartItemCount: widget.cartItemCount,
            onCartTap: widget.onCartTap,
            onSearch: widget.onSearch ?? (query) {
              // Default search handler
            },
            backgroundColor: widget.backgroundGradient != null
                ? Colors.white.withOpacity(0.2)
                : AppTheme.darkGrey,
            textColor: AppTheme.white,
            hintColor: widget.backgroundGradient != null
                ? Colors.white.withOpacity(0.8)
                : AppTheme.textGrey,
          ),
          const SizedBox(height: 12),
          // Filter Chips Row
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: widget.backgroundGradient != null
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.darkGrey,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              dateText,
                              style: widget.backgroundGradient != null
                                  ? const TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : AppTheme.locationText.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectCity,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: widget.backgroundGradient != null
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.darkGrey,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedCity,
                              style: widget.backgroundGradient != null
                                  ? const TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : AppTheme.locationText.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

