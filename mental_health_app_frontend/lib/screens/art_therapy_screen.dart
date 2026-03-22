import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';
import 'package:http/http.dart' as http;

class ArtTherapyScreen extends StatefulWidget {
  @override
  _ArtTherapyScreenState createState() => _ArtTherapyScreenState();
}

class _ArtTherapyScreenState extends State<ArtTherapyScreen> {
  // Store the path coordinates and their current painted colors
  List<ColoringPath> _paths = [];
  Color _selectedColor = Colors.blue; // Default brush
  bool _isLoading = true;
  int _currentSvgIndex = 0;
  
  final List<Map<String, String>> _svgAssets = [
    {'path': 'assets/images/mandala_zen.svg', 'name': 'Zen Mandala'},
    {'path': 'assets/images/sacred_sun.svg', 'name': 'Sacred Sun'},
    {'path': 'assets/images/star_burst.svg', 'name': 'Star Burst'},
    {'path': 'assets/images/magic_lotus.svg', 'name': 'Lotus Flower'},
  ];

  // Your color palette palette
  final List<Color> _palette = [
    Colors.redAccent, Colors.orangeAccent, Colors.amberAccent, 
    Colors.greenAccent, Colors.blueAccent, Colors.indigoAccent, 
    Colors.purpleAccent, Colors.pinkAccent, Colors.tealAccent,
    Colors.brown.shade300, Colors.grey.shade400,
    Colors.white, // Eraser
  ];

  @override
  void initState() {
    super.initState();
    _loadSvgAssets();
  }

  // 1. Read your SVG Asset from the Flutter bundle!
  // Note: Ensure you put your SVG file in your assets folder and define it in pubspec.yaml
  Future<void> _loadSvgAssets() async {
    setState(() { _isLoading = true; _paths = []; });
    try {
      // Load the specific new Lotus SVG file I created entirely from scratch using mathematical code!
      final String svgString = await rootBundle.loadString(_svgAssets[_currentSvgIndex]['path']!);
      final document = xml.XmlDocument.parse(svgString);

      // Find all the structural 'paths' in the SVG so we can tap them
      final pathNodes = document.findAllElements('path');
      List<ColoringPath> loadedPaths = [];

      for (var element in pathNodes) {
        final dString = element.getAttribute('d');
        if (dString != null) {
          // parseSvgPathData comes from the 'path_drawing' package!
          loadedPaths.add(ColoringPath(
            path: parseSvgPathData(dString),
            color: Colors.white, // initial color is unpainted (white blank)
          ));
        }
      }

      print("--- SVG PARSE SUCCESS! ---");
      print("Found ${loadedPaths.length} colorable <path> objects in SVG asset!");
      
      setState(() {
        _paths = loadedPaths;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading SVG: $e");
      setState(() { _isLoading = false; });
    }
  }

  void _onCanvasTap(TapDownDetails details, Size canvasSize) {
    if (_paths.isEmpty) return;

    // Discover the exact bounding box of the entire original SVG
    Rect totalBounds = _paths[0].path.getBounds();
    for (var p in _paths) {
      if (!p.path.getBounds().isEmpty) {
        totalBounds = totalBounds.expandToInclude(p.path.getBounds());
      }
    }
    if (totalBounds.width == 0 || totalBounds.height == 0) return;

    // Reconstruct the exact perfect Scale that was used in the canvas
    final double scaleX = canvasSize.width / totalBounds.width;
    final double scaleY = canvasSize.height / totalBounds.height;
    final double perfectScale = (scaleX < scaleY ? scaleX : scaleY) * 0.95; 

    // Inverse Mathematics! Take the real-world finger tap coordinate and reverse-translate it exactly into the mathematical SVG space!
    double touchX = details.localPosition.dx;
    double touchY = details.localPosition.dy;

    // Reverse the screen centering
    touchX -= canvasSize.width / 2;
    touchY -= canvasSize.height / 2;
    
    // Reverse the 95% zoom
    touchX /= perfectScale;
    touchY /= perfectScale;

    // Reverse the origin alignment
    touchX += totalBounds.center.dx;
    touchY += totalBounds.center.dy;

    // Create the exact mathematical needle point!
    final Offset svgSpaceTap = Offset(touchX, touchY);

    print("--- NEW TAP ---");
    print("Screen Container Touched: ${details.localPosition}");
    print("SVG Bounds: $totalBounds | Scale Used: $perfectScale");
    print("Mapped Mathematical Point: $svgSpaceTap");

    // 2. We use Path.contains() to beautifully calculate exactly which 
    // boundary the user's finger touched inside the mandala!
    // We MUST search backwards (top layer to bottom layer) so tiny shapes on top aren't blocked by the background!
    bool hitFound = false;
    for (int i = _paths.length - 1; i >= 0; i--) {
        if (_paths[i].path.contains(svgSpaceTap)) {
          print("SUCCESS! Filled Path Index: #$i.");
          setState(() {
            _paths[i].color = _selectedColor; // Flood fill it!
          });
          hitFound = true;
          break; // Stop after filling the top-most path
        }
    }

    if (!hitFound) {
      print("MISS! The mapped point $svgSpaceTap did not mathematically land inside any parsed SVG <path>. Check if the SVG paths are fully closed shapes or just un-fillable lines!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Art Therapy", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: "Undo last color",
            onPressed: () {
               setState(() {
                 for (var p in _paths) {
                   // A very simple undo: reset all if needed, or we could track specific history
                   // For now, let's just allow clearing or basic reset logic
                 }
               });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Clear Canvas",
            onPressed: () {
               setState(() {
                 for (var p in _paths) { p.color = Colors.white; }
               });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, left: 16, right: 16, bottom: 8),
            child: Text(
              "Tap to release colorful energy into the canvas ✨", 
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),

          // Image Selector Carousel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  onPressed: _currentSvgIndex > 0 ? () {
                    setState(() => _currentSvgIndex--);
                    _loadSvgAssets();
                  } : null,
                ),
                Expanded(
                  child: Text(
                    _svgAssets[_currentSvgIndex]['name']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: _currentSvgIndex < _svgAssets.length - 1 ? () {
                    setState(() => _currentSvgIndex++);
                    _loadSvgAssets();
                  } : null,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _paths.isEmpty 
                  ? const Center(child: Text("Drop the vector SVG graphic to begin!"))
                  : Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                           final double boxSize = MediaQuery.of(context).size.width * 0.9;
                           _onCanvasTap(details, Size(boxSize, boxSize));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: CustomPaint(
                            painter: SVGPainter(paths: _paths),
                          ),
                        ),
                      ),
                    ),
          ),
          
          // 3. The Art Palette Toolkit
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _palette.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final c = _palette[index];
                final isSelected = _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.grey.shade300, 
                        width: isSelected ? 3 : 1
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : [],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Data Model matching the paths
class ColoringPath {
  final Path path;
  Color color;
  ColoringPath({required this.path, required this.color});
}

// The core Painter engine that handles the drawing
class SVGPainter extends CustomPainter {
  final List<ColoringPath> paths;
  SVGPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    // 1. Calculate the exact invisible mathematical boundaries of the entire SVG drawing!
    Rect totalBounds = paths[0].path.getBounds();
    for (var p in paths) {
      if (!p.path.getBounds().isEmpty) {
        totalBounds = totalBounds.expandToInclude(p.path.getBounds());
      }
    }

    if (totalBounds.width == 0 || totalBounds.height == 0) return;

    // 2. Discover the perfect ratio so the massive drawing perfectly fits your phone!
    final double scaleX = size.width / totalBounds.width;
    final double scaleY = size.height / totalBounds.height;
    final double perfectScale = (scaleX < scaleY ? scaleX : scaleY) * 0.95; // 5% padding margin

    // 3. Command the Canvas to perfectly center and shrink the drawing
    canvas.translate(size.width / 2, size.height / 2); 
    canvas.scale(perfectScale, perfectScale); 
    canvas.translate(-totalBounds.center.dx, -totalBounds.center.dy); 

    for (var p in paths) {
      // 1. Draw the background fill color
      final fillPaint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(p.path, fillPaint);

      // 2. Draw the elegant black border outlines
      final borderPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / perfectScale; // Don't let the border get thick when zoomed!
      canvas.drawPath(p.path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
