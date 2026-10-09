import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DossierDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  const DossierDetailScreen({super.key, required this.patient});

  @override
  State<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends State<DossierDetailScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Informations', 'Traitements', 'Images', 'Prédiction IA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF9C27B0)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: const Color(0xFFE91E8C),
                  radius: 24,
                  child: Text(widget.patient['nom'][0],
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.patient['nom'],
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${widget.patient['age']} • ${widget.patient['blood']} • ${widget.patient['motif']}',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(widget.patient['status'],
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: List.generate(_tabs.length, (i) => GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == i ? const Color(0xFFE91E8C) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(_tabs[i],
                      style: GoogleFonts.poppins(
                          color: _selectedTab == i ? const Color(0xFFE91E8C) : Colors.grey,
                          fontWeight: _selectedTab == i ? FontWeight.w600 : FontWeight.normal)),
                ),
              )),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: [
                _buildInfos(),
                _buildTraitements(),
                _buildImages(),
                _buildIA(),
              ][_selectedTab],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informations personnelles'),
        const SizedBox(height: 16),
        Row(
          children: [
            _infoCard('Nom complet', widget.patient['nom'], Icons.person_outline),
            const SizedBox(width: 16),
            _infoCard('Âge', widget.patient['age'], Icons.cake_outlined),
            const SizedBox(width: 16),
            _infoCard('Groupe sanguin', widget.patient['blood'], Icons.bloodtype_outlined),
            const SizedBox(width: 16),
            _infoCard('Dernière visite', widget.patient['last'], Icons.calendar_today_outlined),
          ],
        ),
        const SizedBox(height: 32),
        _sectionTitle('Antécédents médicaux'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Text('Diabète type 2 — Hypertension légère — Antécédents familiaux de cancer du sein',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildTraitements() {
    final traitements = [
      {'med': 'Metformine 500mg', 'posologie': '2x/jour', 'debut': '01/01/2026', 'fin': '01/07/2026', 'statut': 'En cours'},
      {'med': 'Acide folique 400µg', 'posologie': '1x/jour', 'debut': '15/03/2026', 'fin': '15/09/2026', 'statut': 'En cours'},
      {'med': 'Fer 80mg', 'posologie': '1x/jour', 'debut': '01/04/2026', 'fin': '01/06/2026', 'statut': 'Terminé'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Traitements'),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: Text('Ajouter', style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...traitements.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8BBD9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined, color: Color(0xFFE91E8C)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['med']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    Text(t['posologie']!, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Text('${t['debut']} → ${t['fin']}',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: t['statut'] == 'En cours'
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(t['statut']!,
                    style: GoogleFonts.poppins(
                        color: t['statut'] == 'En cours' ? const Color(0xFF4CAF50) : Colors.grey,
                        fontSize: 12)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Images médicales'),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_outlined, color: Colors.white, size: 16),
              label: Text('Importer', style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _imageCard('Échographie T1', '15/01/2026'),
            _imageCard('Échographie T2', '20/03/2026'),
            _imageCard('Mammographie', '10/05/2026'),
          ],
        ),
      ],
    );
  }

  Widget _buildIA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Prédiction IA'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF1A237E)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text('Analyse IA — Risque grossesse',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _iaStat('Risque global', '23%', Colors.green),
                  const SizedBox(width: 24),
                  _iaStat('Risque diabète', '67%', Colors.orange),
                  const SizedBox(width: 24),
                  _iaStat('Risque HTA', '41%', Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚠️ Recommandation : Suivi rapproché conseillé. Contrôle glycémique à renforcer. Prochain RDV dans 2 semaines.',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)));
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE91E8C), size: 20),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _imageCard(String title, String date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF8BBD9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: Color(0xFFE91E8C), size: 32),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(date, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _iaStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }
}