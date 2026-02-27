import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'affirmation_category_detail.dart';
import 'custom_affirmations_list.dart';
import 'custom_affirmation_flow.dart';
import '../widgets/feature_info_sheet.dart';


class AffirmationsHomeScreen extends StatefulWidget {
  const AffirmationsHomeScreen({super.key});

  @override
  State<AffirmationsHomeScreen> createState() => _AffirmationsHomeScreenState();
}

class _AffirmationsHomeScreenState extends State<AffirmationsHomeScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> featuredAffirmations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final results = await Future.wait([
        _apiService.getAffirmationCategories(),
        _apiService.getGenericAffirmations(),
      ]);
      
      setState(() {
        categories = results[0] as List<Map<String, dynamic>>;
        featuredAffirmations = results[1] as List<Map<String, dynamic>>;
        isLoading = false;
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load affirmations: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Affirmations', 
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textDark),
            onPressed: () => FeatureInfoSheet.show(context, 'affirmations'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  CustomAffirmationsListScreen()),
        ),
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.favorite, color: AppTheme.textDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF3E5F5), // Soft Lavender
              const Color(0xFFFFE0B2).withOpacity(0.5), // Soft Orange/Peach
              const Color(0xFFE0F7FA).withOpacity(0.5), // Soft Cyan
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                          const SizedBox(height: 16),
                          Text(error!, style: GoogleFonts.outfit(color: AppTheme.errorColor)),
                          TextButton(onPressed: _loadData, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Greeting
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning, Sunshine! ✨",
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "What would you like to manifest today?",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                          
                          const SizedBox(height: 32),

                          // Quick Actions Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildGlassAction(
                                  onTap: _showRandomAffirmation,
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'Surprise Me',
                                  color: const Color(0xFF9C27B0),
                                  delay: 200.ms,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGlassAction(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CustomAffirmationFlowScreen()),
                                  ),
                                  icon: Icons.edit_note_rounded,
                                  label: 'Create New',
                                  color: const Color(0xFFE91E63),
                                  delay: 300.ms,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
    
                          // Featured Carousel
                          if (featuredAffirmations.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Daily Boosts',
                                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: featuredAffirmations.length,
                                itemBuilder: (context, index) {
                                  final affirmation = featuredAffirmations[index];
                                  return Container(
                                    width: 280,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.format_quote_rounded, color: AppTheme.primaryColor, size: 24),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Text(
                                              affirmation['text'] ?? '',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16, 
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textDark,
                                                fontStyle: FontStyle.italic,
                                                height: 1.4,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.spa, size: 12, color: AppTheme.primaryColor),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                affirmation['category_name'] ?? 'General',
                                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
    
                          // Categories Grid
                          Text(
                            'Categories',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 16),
                          
                          if (categories.isEmpty)
                             Center(child: Text("No categories found", style: GoogleFonts.outfit(color: AppTheme.textLight)))
                          else
                          GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AffirmationCategoryDetailScreen(
                                            categoryId: category['id'],
                                            categoryName: category['name'] ?? 'Unknown',
                                          ),
                                        ),
                                      );
                                    },
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.4),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                )
                                              ],
                                            ),
                                            child: Text(
                                              category['icon'] ?? '🌸',
                                              style: const TextStyle(fontSize: 32),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            category['name'] ?? 'Unknown',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${category['affirmation_count'] ?? 0} items',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12, 
                                              color: AppTheme.textLight,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (400 + index * 50).ms).scale(duration: 300.ms);
                                },
                              ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  void _showRandomAffirmation() async {
    try {
      final randomAff = await _apiService.getRandomAffirmation();
      if (randomAff != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 48),
                  const SizedBox(height: 24),
                  Text(
                    randomAff['text'] ?? randomAff['affirmation_text'] ?? randomAff['message'] ?? '...',
                    style: GoogleFonts.outfit(fontSize: 22, fontStyle: FontStyle.italic, height: 1.4, color: AppTheme.textDark),
                    textAlign: TextAlign.center,
                  ),
                  if (randomAff['category_name'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        randomAff['category_name'],
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close", style: GoogleFonts.outfit(color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRandomAffirmation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text("Another", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildGlassAction({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    required Duration delay,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2);
  }
}