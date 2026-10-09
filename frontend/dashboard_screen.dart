import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'patients_screen.dart';
import 'ai_screen.dart';
import 'dossiers_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A237E), Color(0xFF9C27B0)],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.favorite, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text('MedAssist AI',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _navItem(Icons.dashboard_outlined, 'Dashboard', 0),
                _navItem(Icons.people_outlined, 'Patients', 1),
                _navItem(Icons.folder_outlined, 'Dossiers', 2),
                _navItem(Icons.psychology_outlined, 'IA', 3),
                const Spacer(),
                _navItem(Icons.logout, 'Déconnexion', 4),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Main content
         Expanded(
  child: _selectedIndex == 0
      ? _buildDashboard()
      : _selectedIndex == 1
          ? const PatientsScreen()
          : _selectedIndex == 2
              ? const DossiersScreen()
              : _selectedIndex == 3
                  ? const AIScreen()
                  : _buildDashboard(),
),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour, Dr. Benali 👋',
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                  Text('Lundi, 22 Juin 2026',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFFE91E8C), size: 10),
                    const SizedBox(width: 8),
                    Text('En ligne',
                        style: GoogleFonts.poppins(color: const Color(0xFFE91E8C), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Stats cards
          Row(
            children: [
              _statCard('Patients total', '124', Icons.people, const Color(0xFFE91E8C)),
              const SizedBox(width: 16),
              _statCard('RDV aujourd\'hui', '8', Icons.calendar_today, const Color(0xFF9C27B0)),
              const SizedBox(width: 16),
              _statCard('Dossiers ouverts', '37', Icons.folder_open, const Color(0xFF1A237E)),
              const SizedBox(width: 16),
              _statCard('Alertes IA', '3', Icons.warning_amber, Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          // Recent patients
          Text('Patients récents',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
          const SizedBox(height: 16),
          _patientRow('Amina Benali', '34 ans', 'A+', 'Suivi grossesse', const Color(0xFF4CAF50)),
          _patientRow('Sara Meziane', '28 ans', 'O-', 'Consultation', const Color(0xFFE91E8C)),
          _patientRow('Nadia Khelifi', '42 ans', 'B+', 'Post-op', Colors.orange),
          _patientRow('Fatima Hadj', '31 ans', 'AB+', 'Urgence IA ⚠️', Colors.red),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
            Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _patientRow(String name, String age, String blood, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF8BBD9),
            child: Text(name[0], style: const TextStyle(color: Color(0xFFE91E8C))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(age, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFF8BBD9), borderRadius: BorderRadius.circular(20)),
            child: Text(blood,
                style: GoogleFonts.poppins(color: const Color(0xFFE91E8C), fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status,
                style: GoogleFonts.poppins(color: statusColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}