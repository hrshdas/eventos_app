import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import 'packages_screen.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  int _currentIndex = 1; // AI Planner tab

  // Form state
  final List<_EventType> _types = [
    _EventType('Birthday', selected: true),
    _EventType('Wedding'),
    _EventType('Corporate'),
    _EventType('House Party'),
    _EventType('Other'),
  ];

  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController(text: 'Mumbai, India');
  final TextEditingController _guestsCtrl = TextEditingController(text: '50–80 guests');
  final TextEditingController _budgetCtrl = TextEditingController(text: '₹50,000 – ₹1,00,000');
  final TextEditingController _themeCtrl = TextEditingController(text: 'Boho chic, fairy lights, terrace');

  bool _isLoading = false;
  bool _hasGeneratedPlan = false;

  String get _selectedType => _types.firstWhere((t) => t.selected, orElse: () => _types.first).label;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _guestsCtrl.dispose();
    _budgetCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    // Minimal validation: ensure event type + location
    if (_selectedType.isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type and enter a location.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasGeneratedPlan = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _hasGeneratedPlan = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.lightGrey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _AiHeader(),
              const SizedBox(height: 48), // space for floating pill overlap
              _FloatingDescribePill(
                onTap: () {
                  // ignore: avoid_print
                  print('Describe your event tapped');
                },
              ),
              _FormCard(
                types: _types,
                onToggleType: (i) => setState(() {
                  for (int j = 0; j < _types.length; j++) {
                    _types[j] = _types[j].copyWith(selected: j == i ? true : _types[j].selected);
                  }
                }),
                dateCtrl: _dateCtrl,
                timeCtrl: _timeCtrl,
                locationCtrl: _locationCtrl,
                guestsCtrl: _guestsCtrl,
                budgetCtrl: _budgetCtrl,
                themeCtrl: _themeCtrl,
                onGenerate: _generatePlan,
                isLoading: _isLoading,
              ),
              _AiSuggestionsCard(
                isLoading: _isLoading,
                hasGeneratedPlan: _hasGeneratedPlan,
                selectedType: _selectedType,
                location: _locationCtrl.text.trim(),
                guests: _guestsCtrl.text.trim(),
                theme: _themeCtrl.text.trim(),
                onViewPackages: () {
                  int? maxBudget;
                  final txt = _budgetCtrl.text.replaceAll(',', '');
                  final match = RegExp(r'(\d{4,})[^\d]*(\d{4,})?').firstMatch(txt);
                  if (match != null) {
                    final upper = match.group(2) ?? match.group(1);
                    if (upper != null) maxBudget = int.tryParse(upper);
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PackagesScreen(),
                      settings: RouteSettings(
                        arguments: {
                          'filters': {
                            'category': 'package',
                            if (maxBudget != null) 'maxPrice': maxBudget,
                            if (_locationCtrl.text.trim().isNotEmpty) 'location': _locationCtrl.text.trim(),
                            'isActive': true,
                          },
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Use central navigation to switch tabs in MainNavigationScreen
          // Map index: Home=0, AI Planner=1, My Events=2, Profile=3
          int mainIndex = index == 0 ? 0 : (index == 1 ? 1 : (index == 2 ? 2 : 3));
          NavigationHelper.navigateToMainScreen(context, mainIndex);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textGrey,
        backgroundColor: AppTheme.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'AI Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Content-only version for embedding inside MainNavigationScreen tab (no BottomNavigationBar)
class AiPlannerScreenContent extends StatefulWidget {
  const AiPlannerScreenContent({super.key});

  @override
  State<AiPlannerScreenContent> createState() => _AiPlannerScreenContentState();
}

class _AiPlannerScreenContentState extends State<AiPlannerScreenContent> {
  final List<_EventType> _types = [
    _EventType('Birthday', selected: true),
    _EventType('Wedding'),
    _EventType('Corporate'),
    _EventType('House Party'),
    _EventType('Other'),
  ];

  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController(text: 'Mumbai, India');
  final TextEditingController _guestsCtrl = TextEditingController(text: '50–80 guests');
  final TextEditingController _budgetCtrl = TextEditingController(text: '₹50,000 – ₹1,00,000');
  final TextEditingController _themeCtrl = TextEditingController(text: 'Boho chic, fairy lights, terrace');

  bool _isLoading = false;
  bool _hasGeneratedPlan = false;

  String get _selectedType => _types.firstWhere((t) => t.selected, orElse: () => _types.first).label;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _guestsCtrl.dispose();
    _budgetCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (_selectedType.isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type and enter a location.')),
      );
      return;
    }
    setState(() { _isLoading = true; _hasGeneratedPlan = false; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; _hasGeneratedPlan = true; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _AiHeader(),
            const SizedBox(height: 48),
            _FloatingDescribePill(onTap: () { /* affordance only */ }),
            _FormCard(
              types: _types,
              onToggleType: (i) => setState(() {
                for (int j = 0; j < _types.length; j++) {
                  _types[j] = _types[j].copyWith(selected: j == i ? true : _types[j].selected);
                }
              }),
              dateCtrl: _dateCtrl,
              timeCtrl: _timeCtrl,
              locationCtrl: _locationCtrl,
              guestsCtrl: _guestsCtrl,
              budgetCtrl: _budgetCtrl,
              themeCtrl: _themeCtrl,
              onGenerate: _generatePlan,
              isLoading: _isLoading,
            ),
            _AiSuggestionsCard(
              isLoading: _isLoading,
              hasGeneratedPlan: _hasGeneratedPlan,
              selectedType: _selectedType,
              location: _locationCtrl.text.trim(),
              guests: _guestsCtrl.text.trim(),
              theme: _themeCtrl.text.trim(),
              onViewPackages: () {
                int? maxBudget;
                final txt = _budgetCtrl.text.replaceAll(',', '');
                final match = RegExp(r'(\d{4,})[^\d]*(\d{4,})?').firstMatch(txt);
                if (match != null) {
                  final upper = match.group(2) ?? match.group(1);
                  if (upper != null) maxBudget = int.tryParse(upper);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PackagesScreen(),
                    settings: RouteSettings(
                      arguments: {
                        'filters': {
                          'category': 'package',
                          if (maxBudget != null) 'maxPrice': maxBudget,
                          if (_locationCtrl.text.trim().isNotEmpty) 'location': _locationCtrl.text.trim(),
                          'isActive': true,
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader();

  @override
  Widget build(BuildContext context) {
    const headerHeight = 200.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: headerHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4F6D), Color(0xFFFF6B5A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
            child: Column(
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Text(
                      'AI Planner',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Plan your event with AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.85,
                  child: const Text(
                    'Tell us about your event and we’ll suggest themes, decor, rentals and a timeline.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingDescribePill extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingDescribePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Center(
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxWidth: 800),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: const [
                  Icon(Icons.smart_toy_outlined, color: AppTheme.textDark, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Describe your event…',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none, color: AppTheme.textDark, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<_EventType> types;
  final void Function(int) onToggleType;
  final TextEditingController dateCtrl;
  final TextEditingController timeCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController guestsCtrl;
  final TextEditingController budgetCtrl;
  final TextEditingController themeCtrl;
  final VoidCallback onGenerate;
  final bool isLoading;

  const _FormCard({
    required this.types,
    required this.onToggleType,
    required this.dateCtrl,
    required this.timeCtrl,
    required this.locationCtrl,
    required this.guestsCtrl,
    required this.budgetCtrl,
    required this.themeCtrl,
    required this.onGenerate,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormLabel('Event type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < types.length; i++)
                GestureDetector(
                  onTap: () => onToggleType(i),
                  child: _ChoicePill(label: types[i].label, selected: types[i].selected),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LinedTextField(
                  controller: dateCtrl,
                  hintText: 'Event date',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LinedTextField(
                  controller: timeCtrl,
                  hintText: 'Start time',
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LinedTextField(
            controller: locationCtrl,
            hintText: 'Location / City',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LinedTextField(
                  controller: guestsCtrl,
                  hintText: 'Guests',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LinedTextField(
                  controller: budgetCtrl,
                  hintText: 'Budget range',
                  icon: Icons.currency_rupee_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LinedTextField(
            controller: themeCtrl,
            hintText: 'Theme / vibe (optional)',
            icon: Icons.style_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Generate Plan with AI',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSuggestionsCard extends StatelessWidget {
  final bool isLoading;
  final bool hasGeneratedPlan;
  final String selectedType;
  final String location;
  final String guests;
  final String theme;
  final VoidCallback onViewPackages;

  const _AiSuggestionsCard({
    required this.isLoading,
    required this.hasGeneratedPlan,
    required this.selectedType,
    required this.location,
    required this.guests,
    required this.theme,
    required this.onViewPackages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? _LoadingState()
            : hasGeneratedPlan
                ? _PlanSuggestions(
                    selectedType: selectedType,
                    location: location,
                    guests: guests,
                    theme: theme,
                    onViewPackages: onViewPackages,
                  )
                : const _EmptyState(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('empty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 8),
        Icon(Icons.smart_toy_outlined, color: AppTheme.textGrey, size: 40),
        SizedBox(height: 12),
        Text(
          'Your AI plan will appear here',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Fill in the details above and tap “Generate Plan”',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12.5,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loading'),
      children: const [
        SizedBox(height: 8),
        CircularProgressIndicator(strokeWidth: 2),
        SizedBox(height: 12),
        Text(
          'Thinking about your event…',
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12.5,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class _PlanSuggestions extends StatelessWidget {
  final String selectedType;
  final String location;
  final String guests;
  final String theme;
  final VoidCallback onViewPackages;

  const _PlanSuggestions({
    required this.selectedType,
    required this.location,
    required this.guests,
    required this.theme,
    required this.onViewPackages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested plan',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _BulletLine(icon: Icons.style_outlined, text: 'Theme: ${_orDefault(theme, "Classic Gold & White Decor")}'),
        _BulletLine(icon: Icons.place_outlined, text: 'Venue: ${_orDefault(location, "Rooftop restaurant in Bandra")}'),
        _BulletLine(icon: Icons.celebration_outlined, text: 'Event: ${_orDefault(selectedType, "Birthday")}, $guests'),
        const _BulletLine(icon: Icons.palette_outlined, text: 'Decor: Balloon arch, neon sign, fairy lights'),
        const _BulletLine(icon: Icons.restaurant_outlined, text: 'Food: Live BBQ + mocktail bar'),
        const _BulletLine(icon: Icons.music_note_outlined, text: 'Music: DJ + curated playlist'),
        const SizedBox(height: 16),
        const Text(
          'Recommended categories',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _CategoryChip('Decor'),
            _CategoryChip('Rentals'),
            _CategoryChip('Talent & Staff'),
            _CategoryChip('Ready-to-book packages'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onViewPackages,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'View matching packages',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _orDefault(String v, String d) {
    final s = v.trim();
    return s.isEmpty ? d : s;
  }
}

class _BulletLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BulletLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  const _ChoicePill({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFFE5E8) : const Color(0xFFF3F3F3);
    final fg = selected ? AppTheme.primaryColor : AppTheme.textDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.primaryColor.withOpacity(0.45) : Colors.transparent,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxLines;

  const _LinedTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.textGrey),
        hintStyle: const TextStyle(color: AppTheme.textGrey),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.textGrey.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}

class _EventType {
  final String label;
  final bool selected;
  _EventType(this.label, {this.selected = false});

  _EventType copyWith({String? label, bool? selected}) {
    return _EventType(label ?? this.label, selected: selected ?? this.selected);
  }
}