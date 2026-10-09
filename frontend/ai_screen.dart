import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  int _selectedModule = 0;
  final List<String> _modules = ['Analyse d\'image', 'Prédiction risque', 'Dictée vocale'];

  // Prédiction
  Map<String, dynamic>? _resultGrossesse;
  Map<String, dynamic>? _resultCardiaque;
  Map<String, dynamic>? _resultSante;
  bool _isPredicting = false;

  // Controllers de base
  final _ageController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _bsController = TextEditingController();
  final _tempController = TextEditingController();
  final _hrController = TextEditingController();

  // Controllers cardiaques
  final _ejectionController = TextEditingController();
  final _creatinineController = TextEditingController();
  bool _anaemia = false;
  bool _diabetes = false;

  // Image analysis
  String? _selectedImagePath;
  String? _selectedImageName;
  Map<String, dynamic>? _imageResult;
  bool _isAnalyzing = false;
  String _selectedAnalysisType = 'Échographie sein';

  @override
  void dispose() {
    _ageController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _bsController.dispose();
    _tempController.dispose();
    _hrController.dispose();
    _ejectionController.dispose();
    _creatinineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF1A237E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Module IA',
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                  Text('Analyse médicale intelligente',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: List.generate(_modules.length, (i) => GestureDetector(
              onTap: () => setState(() => _selectedModule = i),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _selectedModule == i
                      ? const LinearGradient(colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)])
                      : null,
                  color: _selectedModule == i ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Text(_modules[i],
                    style: GoogleFonts.poppins(
                        color: _selectedModule == i ? Colors.white : const Color(0xFF1A237E),
                        fontWeight: FontWeight.w500)),
              ),
            )),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: [
              _buildImageAnalysis(),
              _buildRiskPrediction(),
              _buildVoiceDictation(),
            ][_selectedModule],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PRÉDICTION RISQUE
  // ─────────────────────────────────────────────

  Widget _buildRiskPrediction() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paramètres cliniques',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
                  const SizedBox(height: 16),
                  Text('Paramètres généraux',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _inputFieldController('Âge', '34', _ageController),
                  const SizedBox(height: 10),
                  _inputFieldController('Tension systolique (mmHg)', '120', _systolicController),
                  const SizedBox(height: 10),
                  _inputFieldController('Tension diastolique (mmHg)', '80', _diastolicController),
                  const SizedBox(height: 10),
                  _inputFieldController('Glycémie (mmol/L)', '7.5', _bsController),
                  const SizedBox(height: 10),
                  _inputFieldController('Température corporelle (°F)', '98.6', _tempController),
                  const SizedBox(height: 10),
                  _inputFieldController('Fréquence cardiaque (bpm)', '75', _hrController),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Paramètres cardiaques',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _inputFieldController('Fraction d\'éjection (%)', '60', _ejectionController),
                  const SizedBox(height: 10),
                  _inputFieldController('Créatinine sérique (mg/dL)', '1.1', _creatinineController),
                  const SizedBox(height: 14),
                  _toggleField('Anémie', _anaemia, (v) => setState(() => _anaemia = v)),
                  const SizedBox(height: 10),
                  _toggleField('Diabète', _diabetes, (v) => setState(() => _diabetes = v)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isPredicting ? null : _runPrediction,
                      icon: _isPredicting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.calculate_outlined, color: Colors.white),
                      label: Text(
                          _isPredicting ? 'Analyse en cours...' : 'Calculer les risques',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: _resultGrossesse == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_outlined, size: 64, color: Color(0xFFE91E8C)),
                        const SizedBox(height: 16),
                        Text('Remplissez les paramètres\net lancez l\'analyse',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Résultats IA',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
                        const SizedBox(height: 20),
                        _resultCard(
                          '🤰 Risque grossesse',
                          _resultGrossesse!['prediction'],
                          _resultGrossesse!['confidence'],
                          _riskColor(_resultGrossesse!['prediction']),
                          extra: Column(children: [
                            _riskBar('High risk', (_resultGrossesse!['details']['high risk'] as num) / 100, Colors.red),
                            const SizedBox(height: 8),
                            _riskBar('Mid risk', (_resultGrossesse!['details']['mid risk'] as num) / 100, Colors.orange),
                            const SizedBox(height: 8),
                            _riskBar('Low risk', (_resultGrossesse!['details']['low risk'] as num) / 100, const Color(0xFF4CAF50)),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _resultCard(
                          '💊 Score santé général',
                          _resultSante!['statut'],
                          _resultSante!['confidence'],
                          _resultSante!['statut'].contains('High') ? Colors.red : const Color(0xFF4CAF50),
                          extra: _riskBar('Score santé', (_resultSante!['score_sante'] as num) / 100, const Color(0xFF4CAF50)),
                        ),
                        const SizedBox(height: 16),
                        _resultCard(
                          '❤️ Risque cardiaque',
                          _resultCardiaque!['prediction'],
                          _resultCardiaque!['confidence'],
                          _resultCardiaque!['death_event'] == 1 ? Colors.red : const Color(0xFF4CAF50),
                          extra: _riskBar(
                              'Probabilité décès',
                              (_resultCardiaque!['probabilite_deces'] as num) / 100,
                              Colors.red),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _runPrediction() async {
    setState(() => _isPredicting = true);
    try {
      final age = double.parse(_ageController.text);
      final sys = double.parse(_systolicController.text);
      final dia = double.parse(_diastolicController.text);
      final bs = double.parse(_bsController.text);
      final temp = double.parse(_tempController.text);
      final hr = double.parse(_hrController.text);
      final ejection = double.parse(_ejectionController.text);
      final creatinine = double.parse(_creatinineController.text);

      final r1 = await ApiService.post('/prediction/grossesse', {
        'age': age, 'systolic_bp': sys, 'diastolic_bp': dia,
        'bs': bs, 'body_temp': temp, 'heart_rate': hr,
      });
      final r2 = await ApiService.post('/prediction/sante', {
        'age': age, 'systolic_bp': sys, 'diastolic_bp': dia,
        'bs': bs, 'body_temp': temp, 'heart_rate': hr,
      });
      final r3 = await ApiService.post('/prediction/cardiaque', {
        'age': age,
        'anaemia': _anaemia ? 1 : 0,
        'creatinine_phosphokinase': 250.0,
        'diabetes': _diabetes ? 1 : 0,
        'ejection_fraction': ejection,
        'high_blood_pressure': sys > 140 ? 1 : 0,
        'platelets': 250000.0,
        'serum_creatinine': creatinine,
        'serum_sodium': 137.0,
        'sex': 0,
        'smoking': 0,
        'time': 200.0,
      });

      setState(() {
        _resultGrossesse = r1;
        _resultSante = r2;
        _resultCardiaque = r3;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isPredicting = false);
    }
  }

  // ─────────────────────────────────────────────
  // DICTÉE VOCALE
  // ─────────────────────────────────────────────

  Widget _buildVoiceDictation() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E8C).withOpacity(0.3),
                    blurRadius: 20, spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Dictée vocale',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.construction_outlined, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text('Fonctionnalité en cours de développement',
                      style: GoogleFonts.poppins(color: Colors.orange, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'La transcription vocale via Whisper AI\nsera disponible dans une prochaine version.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ANALYSE D'IMAGE
  // ─────────────────────────────────────────────

  Widget _buildImageAnalysis() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Importer une image médicale',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
                  const SizedBox(height: 20),

                  // Zone sélection image
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BBD9).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE91E8C).withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_upload_outlined,
                                    color: Color(0xFFE91E8C), size: 48),
                                const SizedBox(height: 12),
                                Text('Cliquer pour sélectionner',
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFFE91E8C),
                                        fontWeight: FontWeight.w500)),
                                Text('JPG, PNG supportés',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),

                  if (_selectedImageName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.image_outlined, size: 16, color: Color(0xFFE91E8C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(_selectedImageName!,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Type d'analyse
                  DropdownButtonFormField<String>(
                    value: _selectedAnalysisType,
                    decoration: InputDecoration(
                      labelText: 'Type d\'analyse',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E8C))),
                    ),
                    items: ['Échographie sein', 'Mammographie', 'IRM', 'Histologie']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAnalysisType = v!),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedImagePath == null || _isAnalyzing)
                          ? null
                          : _analyzeImage,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.analytics_outlined, color: Colors.white),
                      label: Text(
                          _isAnalyzing ? 'Analyse en cours...' : 'Analyser l\'image',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A237E), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _imageResult == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_search_outlined,
                            size: 64, color: Colors.white38),
                        const SizedBox(height: 16),
                        Text('Importez une image\net lancez l\'analyse',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Résultats IA',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 20),

                        // Résultat principal
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _imageResult!['prediction'] == 'normal'
                                    ? Icons.check_circle_outline
                                    : Icons.warning_amber_outlined,
                                color: _imageResult!['prediction'] == 'normal'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.orange,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Diagnostic',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white70, fontSize: 12)),
                                  Text(
                                    _imageResult!['prediction']
                                        .toString()
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confiance
                        _resultItem('Confiance',
                            '${_imageResult!['confidence']}%', Colors.white),
                        _resultItem('Type d\'analyse',
                            _selectedAnalysisType, Colors.white70),

                        const SizedBox(height: 16),

                        // Barres de probabilité
                        Text('Probabilités',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 10),
                        ...(_imageResult!['details'] as Map<String, dynamic>)
                            .entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.key,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 12)),
                                          Text('${e.value}%',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (e.value as num) / 100,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.1),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            e.key == 'normal'
                                                ? const Color(0xFF4CAF50)
                                                : e.key == 'benign'
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                        const SizedBox(height: 16),

                        // Recommandation
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _imageResult!['prediction'] == 'normal'
                                ? '✅ Aucune anomalie détectée. Suivi standard recommandé dans 12 mois.'
                                : _imageResult!['prediction'] == 'benign'
                                    ? '⚠️ Lésion bénigne détectée. Surveillance rapprochée recommandée.'
                                    : '🔴 Lésion suspecte détectée. Consultation urgente recommandée.',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
        _selectedImageName = result.files.single.name;
        _imageResult = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImagePath == null) return;
    setState(() => _isAnalyzing = true);
    try {
      final token = await ApiService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/image/analyze'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
          await http.MultipartFile.fromPath('file', _selectedImagePath!));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      setState(() => _imageResult = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  // ─────────────────────────────────────────────
  // WIDGETS UTILITAIRES
  // ─────────────────────────────────────────────

  Color _riskColor(String prediction) {
    if (prediction.contains('high')) return Colors.red;
    if (prediction.contains('mid')) return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  Widget _resultCard(String title, String result, dynamic confidence, Color color, {Widget? extra}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('$confidence% confiance',
                    style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(result, style: GoogleFonts.poppins(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
          if (extra != null) ...[const SizedBox(height: 12), extra],
        ],
      ),
    );
  }

  Widget _inputFieldController(String label, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE91E8C))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _toggleField(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A237E))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E8C),
          ),
        ],
      ),
    );
  }

  Widget _resultItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          Text(value, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _riskBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%',
                style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}