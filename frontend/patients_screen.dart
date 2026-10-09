import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'dossier_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final data = await ApiService.getPatients();
    setState(() {
      _patients = data.map((p) => {
        'id': p['id'],
        'nom': '${p['prenom']} ${p['nom']}',
        'age': p['date_naissance'] != null
            ? '${DateTime.now().year - DateTime.parse(p['date_naissance']).year} ans'
            : 'N/A',
        'blood': p['groupe_sanguin'] ?? 'N/A',
        'status': 'Actif',
        'last': 'N/A',
        'motif': p['antecedents'] ?? 'Consultation',
      }).toList().cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Actif': return const Color(0xFF4CAF50);
      case 'Urgent': return Colors.red;
      case 'Post-op': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'Tous'
        ? _patients
        : _patients.where((p) => p['status'] == _selectedFilter).toList();

    final searched = _searchController.text.isEmpty
        ? filtered
        : filtered.where((p) =>
            p['nom'].toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Patients',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const AddPatientDialog(),
                  );
                  if (result == true) _loadPatients();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text('Nouveau patient',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un patient...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFE91E8C)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ...[' Tous', 'Actif', 'Urgent', 'Archivé'].map((filter) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(filter.trim(),
                      style: GoogleFonts.poppins(
                          color: _selectedFilter == filter.trim()
                              ? Colors.white
                              : const Color(0xFF1A237E))),
                  selected: _selectedFilter == filter.trim(),
                  onSelected: (_) => setState(() => _selectedFilter = filter.trim()),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFE91E8C),
                  checkmarkColor: Colors.white,
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8BBD9).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Nom', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 1, child: Text('Âge', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 1, child: Text('Groupe', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 2, child: Text('Motif', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 2, child: Text('Dernière visite', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 1, child: Text('Statut', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
                : searched.isEmpty
                    ? Center(
                        child: Text('Aucun patient trouvé',
                            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        itemCount: searched.length,
                        itemBuilder: (context, index) {
                          final p = searched[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFF8BBD9),
                                        radius: 18,
                                        child: Text(p['nom'][0],
                                            style: const TextStyle(color: Color(0xFFE91E8C), fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(p['nom'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                Expanded(flex: 1, child: Text(p['age'], style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF8BBD9), borderRadius: BorderRadius.circular(20)),
                                    child: Text(p['blood'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(color: const Color(0xFFE91E8C), fontSize: 12)),
                                  ),
                                ),
                                Expanded(flex: 2, child: Text(p['motif'], style: GoogleFonts.poppins(fontSize: 13))),
                                Expanded(flex: 2, child: Text(p['last'], style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: _statusColor(p['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Text(p['status'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(color: _statusColor(p['status']), fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, color: Color(0xFF9C27B0), size: 20),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (_) => DossierDetailScreen(patient: p)));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A237E), size: 20),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
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

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateController = TextEditingController();
  final _antecedentsController = TextEditingController();
  String _sexe = 'F';
  String _groupe = 'A+';
  bool _isLoading = false;

  final List<String> _groupes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nouveau patient',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E))),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E8C))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E8C))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date de naissance (YYYY-MM-DD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E8C))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _groupe,
                    decoration: InputDecoration(
                      labelText: 'Groupe sanguin',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _groupes.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => _groupe = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Sexe :', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(width: 16),
                Radio(value: 'F', groupValue: _sexe, activeColor: const Color(0xFFE91E8C), onChanged: (v) => setState(() => _sexe = v!)),
                Text('Femme', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(width: 16),
                Radio(value: 'M', groupValue: _sexe, activeColor: const Color(0xFFE91E8C), onChanged: (v) => setState(() => _sexe = v!)),
                Text('Homme', style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _antecedentsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Antécédents médicaux',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE91E8C))),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        final result = await ApiService.createPatient({
                          'nom': _nomController.text,
                          'prenom': _prenomController.text,
                          'date_naissance': _dateController.text.isEmpty ? null : _dateController.text,
                          'sexe': _sexe,
                          'groupe_sanguin': _groupe,
                          'antecedents': _antecedentsController.text,
                        });
                        setState(() => _isLoading = false);
                        if (result != null) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Erreur lors de la création'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Enregistrer',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}