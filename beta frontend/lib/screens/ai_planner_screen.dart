import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import '../features/ai_planner/data/ai_planner_repository.dart';
import '../features/ai_planner/domain/models/ai_planner_request.dart';
import '../features/ai_planner/domain/models/ai_plan.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  int _currentIndex = 1; // AI Planner tab

  // Form state
  final List<_EventType> _types = [
    _EventType('Birthday'),
    _EventType('Wedding'),
    _EventType('Corporate'),
    _EventType('Anniversary'),
    _EventType('Baby Shower'),
    _EventType('Engagement'),
    _EventType('Other'),
  ];

  // Indian cities for dropdown
  final List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  final TextEditingController _guestsCtrl = TextEditingController(text: '50-100');
  final TextEditingController _budgetCtrl = TextEditingController(text: '50000');
  final TextEditingController _themeCtrl = TextEditingController(text: 'Bollywood theme with DJ');

  final AiPlannerRepository _repository = AiPlannerRepository();
  
  bool _isLoading = false;
  AiPlanResponse? _planResponse;
  String? _errorMessage;

  String? get _selectedType {
    final selected = _types.where((t) => t.selected).toList();
    return selected.isEmpty ? null : selected.first.label;
  }

  @override
  void initState() {
    super.initState();
    // Set default selections
    _types[0] = _types[0].copyWith(selected: true);
    _selectedLocation = _cities[0];
    _selectedDate = DateTime.now().add(const Duration(days: 30));
    _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  }

  @override
  void dispose() {
    _guestsCtrl.dispose();
    _budgetCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _generatePlan() async {
    if (_selectedType == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type and location.')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date.')),
      );
      return;
    }

    // Parse budget
    final budgetText = _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final budget = double.tryParse(budgetText) ?? 50000;

    // Combine date and time
    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime?.hour ?? 18,
      _selectedTime?.minute ?? 0,
    );

    setState(() {
      _isLoading = true;
      _planResponse = null;
      _errorMessage = null;
    });

    try {
      final request = AiPlannerRequest(
        eventType: _selectedType!,
        location: _selectedLocation!,
        guests: _guestsCtrl.text.trim(),
        budget: budget,
        date: eventDateTime.toUtc().toIso8601String(),
        description: _themeCtrl.text.trim(),
      );

      final response = await _repository.generatePlan(request);

      setState(() {
        _planResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('AppApiException: ', '').replaceAll('Exception: ', '');
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to generate plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  // Toggle selection - allow unselecting
                  _types[i] = _types[i].copyWith(selected: !_types[i].selected);
                  // Unselect all others
                  for (int j = 0; j < _types.length; j++) {
                    if (j != i) {
                      _types[j] = _types[j].copyWith(selected: false);
                    }
                  }
                }),
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                selectedLocation: _selectedLocation,
                cities: _cities,
                onSelectDate: _selectDate,
                onSelectTime: _selectTime,
                onLocationChanged: (value) => setState(() => _selectedLocation = value),
                guestsCtrl: _guestsCtrl,
                budgetCtrl: _budgetCtrl,
                themeCtrl: _themeCtrl,
                onGenerate: _generatePlan,
                isLoading: _isLoading,
              ),
              _AiSuggestionsCard(
                isLoading: _isLoading,
                planResponse: _planResponse,
                errorMessage: _errorMessage,
                onViewPackages: () {
                  if (_planResponse != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Found ${_planResponse!.totalMatches} matching services')),
                    );
                  }
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
    _EventType('Birthday'),
    _EventType('Wedding'),
    _EventType('Corporate'),
    _EventType('Anniversary'),
    _EventType('Baby Shower'),
    _EventType('Engagement'),
    _EventType('Other'),
  ];

  final List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  final TextEditingController _guestsCtrl = TextEditingController(text: '50-100');
  final TextEditingController _budgetCtrl = TextEditingController(text: '50000');
  final TextEditingController _themeCtrl = TextEditingController(text: 'Bollywood theme with DJ');

  final AiPlannerRepository _repository = AiPlannerRepository();
  
  bool _isLoading = false;
  AiPlanResponse? _planResponse;
  String? _errorMessage;

  String? get _selectedType {
    final selected = _types.where((t) => t.selected).toList();
    return selected.isEmpty ? null : selected.first.label;
  }

  @override
  void initState() {
    super.initState();
    _types[0] = _types[0].copyWith(selected: true);
    _selectedLocation = _cities[0];
    _selectedDate = DateTime.now().add(const Duration(days: 30));
    _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  }

  @override
  void dispose() {
    _guestsCtrl.dispose();
    _budgetCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _generatePlan() async {
    if (_selectedType == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type and location.')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date.')),
      );
      return;
    }

    final budgetText = _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final budget = double.tryParse(budgetText) ?? 50000;

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime?.hour ?? 18,
      _selectedTime?.minute ?? 0,
    );

    setState(() {
      _isLoading = true;
      _planResponse = null;
      _errorMessage = null;
    });

    try {
      final request = AiPlannerRequest(
        eventType: _selectedType!,
        location: _selectedLocation!,
        guests: _guestsCtrl.text.trim(),
        budget: budget,
        date: eventDateTime.toUtc().toIso8601String(),
        description: _themeCtrl.text.trim(),
      );

      final response = await _repository.generatePlan(request);
      setState(() {
        _planResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('AppApiException: ', '').replaceAll('Exception: ', '');
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to generate plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                _types[i] = _types[i].copyWith(selected: !_types[i].selected);
                for (int j = 0; j < _types.length; j++) {
                  if (j != i) {
                    _types[j] = _types[j].copyWith(selected: false);
                  }
                }
              }),
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              selectedLocation: _selectedLocation,
              cities: _cities,
              onSelectDate: _selectDate,
              onSelectTime: _selectTime,
              onLocationChanged: (value) => setState(() => _selectedLocation = value),
              guestsCtrl: _guestsCtrl,
              budgetCtrl: _budgetCtrl,
              themeCtrl: _themeCtrl,
              onGenerate: _generatePlan,
              isLoading: _isLoading,
            ),
            _AiSuggestionsCard(
              isLoading: _isLoading,
              planResponse: _planResponse,
              errorMessage: _errorMessage,
              onViewPackages: () {
                if (_planResponse != null) {
                  // TODO: Navigate to packages screen with filters
                  // NavigationHelper.navigateToPackagesWithFilters(
                  //   context,
                  //   categories: _planResponse!.plan.recommendedCategories,
                  //   location: _locationCtrl.text.trim(),
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Found ${_planResponse!.totalMatches} matching services')),
                  );
                }
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
    const headerHeight = 210.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: headerHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4F6D), Color(0xFFFF6B5A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
            child: Column(
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AI Planner',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Plan Your Perfect Event',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: 0.9,
                  child: const Text(
                    'Tell us about your event and we\'ll suggest themes, decor, food, music and more',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                      height: 1.4,
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
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? selectedLocation;
  final List<String> cities;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final void Function(String?) onLocationChanged;
  final TextEditingController guestsCtrl;
  final TextEditingController budgetCtrl;
  final TextEditingController themeCtrl;
  final VoidCallback onGenerate;
  final bool isLoading;

  const _FormCard({
    required this.types,
    required this.onToggleType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedLocation,
    required this.cities,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onLocationChanged,
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
                child: _PickerButton(
                  label: selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Event date',
                  icon: Icons.calendar_today_outlined,
                  onTap: onSelectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerButton(
                  label: selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Start time',
                  icon: Icons.schedule_outlined,
                  onTap: onSelectTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LocationDropdown(
            selectedLocation: selectedLocation,
            cities: cities,
            onChanged: onLocationChanged,
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
  final AiPlanResponse? planResponse;
  final String? errorMessage;
  final VoidCallback onViewPackages;

  const _AiSuggestionsCard({
    required this.isLoading,
    required this.planResponse,
    required this.errorMessage,
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
            : errorMessage != null
                ? _ErrorState(message: errorMessage!)
                : planResponse != null
                    ? _PlanSuggestions(
                        planResponse: planResponse!,
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
          'Generating your event plan with AI…',
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

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('error'),
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text(
          'Failed to generate plan',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PlanSuggestions extends StatelessWidget {
  final AiPlanResponse planResponse;
  final VoidCallback onViewPackages;

  const _PlanSuggestions({
    required this.planResponse,
    required this.onViewPackages,
  });

  @override
  Widget build(BuildContext context) {
    final plan = planResponse.plan;
    
    return Column(
      key: const ValueKey('plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                plan.theme,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (!planResponse.isAIGenerated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Fallback',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Decor section
        if (plan.decor.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.palette_outlined, title: 'Decor Ideas'),
          const SizedBox(height: 8),
          ...plan.decor.map((item) => _BulletLine(text: item)),
          const SizedBox(height: 12),
        ],
        
        // Food section
        if (plan.food.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.restaurant_outlined, title: 'Food Suggestions'),
          const SizedBox(height: 8),
          ...plan.food.map((item) => _BulletLine(text: item)),
          const SizedBox(height: 12),
        ],
        
        // Music section
        if (plan.music.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.music_note_outlined, title: 'Music & Entertainment'),
          const SizedBox(height: 8),
          ...plan.music.map((item) => _BulletLine(text: item)),
          const SizedBox(height: 16),
        ],
        
        const Divider(),
        const SizedBox(height: 12),
        
        // Matching services count
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Text(
              'Found ${planResponse.totalMatches} matching services',
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Recommended categories
        const Text(
          'Recommended categories',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: plan.recommendedCategories.map((cat) => _CategoryChip(cat)).toList(),
        ),
        const SizedBox(height: 16),
        
        // View packages button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onViewPackages,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'View Matching Packages',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryColor, fontSize: 16)),
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

  _EventType copyWith({bool? selected}) {
    return _EventType(label, selected: selected ?? this.selected);
  }
}

// Picker button widget for date/time selection
class _PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.textGrey.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textGrey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.contains('/') || label.contains(':') || label.contains('AM') || label.contains('PM')
                      ? AppTheme.textDark
                      : AppTheme.textGrey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Location dropdown widget
class _LocationDropdown extends StatelessWidget {
  final String? selectedLocation;
  final List<String> cities;
  final void Function(String?) onChanged;

  const _LocationDropdown({
    required this.selectedLocation,
    required this.cities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.textGrey.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppTheme.textGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLocation,
                hint: const Text(
                  'Select location',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textGrey),
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14,
                ),
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}