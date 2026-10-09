import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class DossiersScreen extends StatefulWidget {
  const DossiersScreen({super.key});

  @override
  State<DossiersScreen> createState() => _DossiersScreenState();
}

class _DossiersScreenState extends State<DossiersScreen> {
  List<Map<String, dynamic>> _dossiers = [];
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dossiers = await ApiService.getDossiers();
    final patients = await ApiService.getPatients();
    setState(() {
      _dossiers = dossiers.cast<Map<String, dynamic>>();
      _patients = patients.map((p) => {
        'id': p['id'].toString(),
        'nom': p['nom'],
        'prenom': p['prenom'],
      }).toList();
      _isLoading = false;
    });
  }

  void _showNewDossierDialog() {
    String? selectedPatientId;
    String selectedStatut = 'actif';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_outlined, color: Color(0xFF9C27B0)),
              ),
              const SizedBox(width: 12),
              Text('Nouveau dossier',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _patients.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Aucun patient disponible.',
                            style: GoogleFonts.poppins(color: Colors.orange, fontSize: 13)),
                      )
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Patient *',
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFE91E8C)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE91E8C))),
                        ),
                        items: _patients.map((p) => DropdownMenuItem<String>(
                          value: p['id'],
                          child: Text('${p['prenom']} ${p['nom']}',
                              style: GoogleFonts.poppins()),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedPatientId = val),
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatut,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF9C27B0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF9C27B0))),
                  ),
                  items: ['actif', 'fermé', 'urgent'].map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: GoogleFonts.poppins()),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => selectedStatut = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: selectedPatientId == null ? null : () async {
                final medecins = await ApiService.getMedecins();
                if (medecins.isEmpty) return;
                final result = await ApiService.createDossier({
                  'patient_id': selectedPatientId,
                  'medecin_id': medecins[0]['id'].toString(),
                  'statut': selectedStatut,
                });
                if (result != null) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dossier créé avec succès !'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Créer',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'actif': return const Color(0xFF4CAF50);
      case 'fermé': return Colors.grey;
      case 'urgent': return Colors.red;
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dossiers médicaux',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
              ElevatedButton.icon(
                onPressed: _showNewDossierDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text('Nouveau dossier',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('ID Dossier', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 2, child: Text('Patient', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 2, child: Text('Ouvert le', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 2, child: Text('Mis à jour', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                Expanded(flex: 1, child: Text('Statut', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)))),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C27B0)))
                : _dossiers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open, color: Colors.grey, size: 64),
                            const SizedBox(height: 16),
                            Text('Aucun dossier trouvé',
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _dossiers.length,
                        itemBuilder: (context, index) {
                          final d = _dossiers[index];
                          final ouvertLe = DateTime.parse(d['ouvert_le']);
                          final misAJour = DateTime.parse(d['mis_a_jour_le']);
                          final patient = _patients.firstWhere(
                            (p) => p['id'] == d['patient_id'].toString(),
                            orElse: () => {'prenom': 'Inconnu', 'nom': ''},
                          );
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
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.folder_outlined, color: Color(0xFF9C27B0), size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          d['id'].toString().substring(0, 8) + '...',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${patient['prenom']} ${patient['nom']}',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${ouvertLe.day}/${ouvertLe.month}/${ouvertLe.year}',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${misAJour.day}/${misAJour.month}/${misAJour.year}',
                                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statutColor(d['statut']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(d['statut'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            color: _statutColor(d['statut']), fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: Color(0xFF9C27B0), size: 20),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () {},
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