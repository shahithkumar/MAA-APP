import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  bool _isLoading = true;
  List<dynamic> _moodLogs = [];
  Map<String, dynamic>? _summary;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mapping from stored 'mood_emoji' value to icon and color
  final Map<String, Map<String, dynamic>> _moodConfig = {
    'happy': {'icon': '😊', 'color': Colors.amber},
    'calm': {'icon': '😌', 'color': Colors.teal},
    'sad': {'icon': '😔', 'color': Colors.blue},
    'angry': {'icon': '😠', 'color': Colors.red},
    'tired': {'icon': '😴', 'color': Colors.indigo},
    'anxious': {'icon': '😰', 'color': Colors.orange},
    'stressed': {'icon': '😫', 'color': Colors.deepOrange},
    'grateful': {'icon': '✨', 'color': Colors.purple},
    'loved': {'icon': '🥰', 'color': Colors.pink},
    'excited': {'icon': '🤩', 'color': Colors.yellow},
    'joyful': {'icon': '🥳', 'color': Colors.amberAccent},
    'energetic': {'icon': '⚡', 'color': Colors.yellow},
    'proud': {'icon': '⭐', 'color': Colors.orangeAccent},
    'relaxed': {'icon': '🧘', 'color': Colors.tealAccent},
    'neutral': {'icon': '😐', 'color': Colors.blueGrey},
    'focused': {'icon': '🎯', 'color': Colors.cyan},
    'lonely': {'icon': '👤', 'color': Colors.blueGrey},
    'grief': {'icon': '😢', 'color': Colors.indigo},
    'frustrated': {'icon': '😤', 'color': Colors.deepOrange},
    'overwhelmed': {'icon': '🌊', 'color': Colors.deepPurple},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _apiService.getMoodLogs();
      final summary = await _apiService.getMoodSummary();
      setState(() {
        _moodLogs = logs;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching mood data: $e');
      setState(() => _isLoading = false);
    }
  }

  int _getMoodValue(String label) {
    String lbl = label.toLowerCase();
    if (lbl.contains('happy') || lbl.contains('joy') || lbl.contains('excite') || lbl.contains('proud') || lbl.contains('energetic')) return 5;
    if (lbl.contains('calm') || lbl.contains('relax') || lbl.contains('focused') || lbl.contains('grateful') || lbl.contains('love')) return 4;
    if (lbl.contains('neutral')) return 3;
    if (lbl.contains('tired') || lbl.contains('anxious') || lbl.contains('stress') || lbl.contains('overwhelm')) return 2;
    if (lbl.contains('sad') || lbl.contains('angry') || lbl.contains('lonely') || lbl.contains('grief') || lbl.contains('frustrate')) return 1;
    return 3;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _moodLogs.where((log) {
      final dateField = log['created_at'] ?? log['date_time'];
      if (dateField == null) return false;
      final logDate = DateTime.parse(dateField);
      return isSameDay(logDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Mood Journey', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Insights', icon: Icon(Icons.auto_awesome_rounded, size: 20)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month_rounded, size: 20)),
            Tab(text: 'Logs', icon: Icon(Icons.list_alt_rounded, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInsightsTab(),
                _buildCalendarTab(),
                _buildLogsTab(),
              ],
            ),
    );
  }

  // --- INSIGHTS TAB ---
  Widget _buildInsightsTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_summary != null) _buildSummaryCard(),
            const SizedBox(height: 32),
            _buildMoodChart(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    if (_moodLogs.isEmpty) return const SizedBox();

    // Take last 7 entries for a trend chart
    final trendLogs = _moodLogs.take(7).toList().reversed.toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood Trend', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text('Showing your last 7 activities', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= trendLogs.length) return const SizedBox();
                        final dateStr = trendLogs[index]['created_at'] ?? trendLogs[index]['date_time'];
                        final date = DateTime.parse(dateStr);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendLogs.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), _getMoodValue(e.value['mood_label']).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.primaryColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CALENDAR TAB ---
  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryColor),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryColor),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              todayTextStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              selectedDecoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: Colors.transparent), // We use builders instead
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  final log = events.first as Map<String, dynamic>;
                  final moodVal = (log['mood_emoji'] ?? 'happy').toString().toLowerCase();
                  final config = _moodConfig[moodVal] ?? _moodConfig['happy']!;
                  return Positioned(
                    bottom: 1,
                    child: Text(config['icon'], style: const TextStyle(fontSize: 10)),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedDay != null) ...[
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     DateFormat('EEEE, MMM dd').format(_selectedDay!),
                     style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 16),
                   ...(_getEventsForDay(_selectedDay!)).map((log) => Padding(
                     padding: const EdgeInsets.only(bottom: 16.0),
                     child: _buildMoodItem(log),
                   )).toList(),
                   if (_getEventsForDay(_selectedDay!).isEmpty)
                     Center(
                       child: Padding(
                         padding: const EdgeInsets.only(top: 20),
                         child: Text("No entries for this day", style: GoogleFonts.outfit(color: AppTheme.textLight)),
                       ),
                     ),
                 ],
               ),
             ),
          ],
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- LOGS TAB ---
  Widget _buildLogsTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recent Entries', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            if (_moodLogs.isEmpty)
              _emptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moodLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildMoodItem(_moodLogs[index]),
              ),
          ],
        ),
      ),
    );
  }

  // --- REUSED WIDGETS ---
  Widget _emptyState() {
     return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.calendar_today_rounded, size: 60, color: AppTheme.textLight.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('No mood logs yet.\nStart tracking today!', 
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.textLight)),
            ],
          ),
        ),
      );
  }

  Widget _buildSummaryCard() {
    final dominantMood = _summary!['dominant_mood'] ?? 'Unknown';
    final count = _summary!['total_entries'] ?? 0;
    final summaryText = _summary!['summary'] ?? '';
    final moodCounts = _summary!['mood_counts'] as Map<String, dynamic>? ?? {};
    final suggestions = _summary!['suggestions'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Current Pulse',
                        style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dominantMood,
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count logs',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              // Mood Distribution Bar
              if (moodCounts.isNotEmpty) ...[
                 _buildMoodDistribution(moodCounts),
                 const SizedBox(height: 24),
              ],

              Text(
                summaryText,
                style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textDark, height: 1.5, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...suggestions.map((s) => _buildSuggestionCard(s.toString())).toList(),
        ]
      ],
    );
  }

  Widget _buildMoodDistribution(Map<String, dynamic> counts) {
    int total = 0;
    counts.forEach((key, value) => total += (value as int));
    
    if (total == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           children: [
             Icon(Icons.donut_small_rounded, size: 18, color: AppTheme.textLight),
             const SizedBox(width: 8),
             Text('Mood Mix', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
           ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 12,
            child: Row(
              children: counts.entries.map((e) {
                final width = (e.value as int) / total;
                return Expanded(
                  flex: (width * 100).toInt(),
                  child: Container(
                    color: _getMoodColor(e.key),
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
               child: Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
    );
  }

  Color _getMoodColor(String label) {
    final key = label.toLowerCase();
    return _moodConfig[key]?['color'] ?? Colors.grey;
  }

  Widget _buildMoodItem(dynamic log) {
    String dateStr = 'Unknown Date';
    String timeStr = '';
    
    final dateField = log['created_at'] ?? log['date_time'];

    if (dateField != null) {
      try {
        final dateTime = DateTime.parse(dateField).toLocal();
        dateStr = DateFormat('MMM dd').format(dateTime); 
        timeStr = DateFormat('h:mm a').format(dateTime);
      } catch (_) {}
    }
    
    final moodVal = (log['mood_emoji'] ?? 'happy').toString().toLowerCase();
    final config = _moodConfig[moodVal] ?? _moodConfig['happy']!;
    final moodColor = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: moodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                config['icon'],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['mood_label'] ?? 'Unknown',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                if (log['note'] != null && log['note'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      log['note'],
                      style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateStr, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              if (timeStr.isNotEmpty)
                Text(timeStr, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0);
  }
}
