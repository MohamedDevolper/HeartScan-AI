import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../results/results_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _fileName;
  String? _filePath; // To store the actual file path
  final _recordController = TextEditingController();
  final _sampleIndexController = TextEditingController(text: "1100");
  bool _isAnalyzing = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'pdf', 'png', 'jpg', 'hea', 'dat', 'atr'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
        // Use filename without extension as default record name
        _recordController.text = _fileName!.split('.').first;
      });
    }
  }

  Future<void> _analyzeData() async {
    if (_recordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a record name.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // IMPORTANT: Replace this IP with your Computer's IPv4 Address (from ipconfig)
      const String computerIP = '192.168.0.188'; // Change this to your PC IP
      const String apiUrl = 'http://$computerIP:8000/predict';
      
      // Sending JSON (Matches your FastAPI RequestData schema)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'record': _recordController.text,
          'sample_index': int.tryParse(_sampleIndexController.text) ?? 1100,
          'visualize': true,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result.containsKey('error')) {
          throw Exception(result['error']);
        }

        // Extract probabilities into the format expected by ResultsScreen
        Map<String, String> confidenceScores = {};
        if (result['probabilities'] != null) {
          (result['probabilities'] as Map).forEach((key, value) {
             confidenceScores[value['meaning']] = value['probability'];
          });
        }

        // Save to History
        await AuthService().saveScanResult(
          diagnosis: result['meaning'],
          confidenceScores: confidenceScores,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                diagnosis: result['meaning'],
                confidenceScores: confidenceScores,
                plotBase64: result['plot'],
              ),
            ),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}\nMake sure files exist on PC.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'), 
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Heartbeat Data', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Upload your ECG or Heartbeat data file for AI analysis.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade().slideY(),
            const SizedBox(height: 40),
            
            // Upload Box
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.document_upload,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .moveY(begin: -5, end: 5, duration: 1500.ms),
                    const SizedBox(height: 20),
                    Text(
                      _fileName ?? 'Tap to select file',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _fileName != null ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: CSV, PDF, JPG, PNG',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 200.ms).scale(),

            const SizedBox(height: 24),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR ENTER MANUALLY',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.2))),
              ],
            ).animate().fade(delay: 300.ms).slideX(),
            
            const SizedBox(height: 24),

            // Input Fields wrapped in an animated container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _recordController,
                    decoration: InputDecoration(
                      labelText: 'Record Name (e.g. 100)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Iconsax.document_text, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sampleIndexController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sample Index (e.g. 1100)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Iconsax.status_up, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),

            _isAnalyzing 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(
                    onPressed: _analyzeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Analyze Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.5),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
