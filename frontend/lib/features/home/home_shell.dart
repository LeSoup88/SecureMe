import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../panic/panic_page.dart';
import '../report/report_page.dart';
import '../report/history_page.dart';
import '../education/education_page.dart';
import '../contacts/contacts_page.dart';
import '../portal/portal_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PanicPage(),
    ReportPage(),
    HistoryPage(),
    EducationPage(),
    ContactsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: const [
              Icon(Icons.shield, size: 22),
              SizedBox(width: 8),
              Text(
                'SecureMe',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded),
              tooltip: 'Kembali ke Halaman Awal',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  title: const Text('Kembali ke Halaman Awal',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                  content: const Text(
                    'Apakah Anda yakin ingin kembali ke halaman awal?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                        style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PortalPage()),
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          elevation: 0,
        ),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color(0x1A000000), blurRadius: 12)
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.warning_amber_rounded),
                label: 'Panik'),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                label: 'Lapor'),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'Riwayat'),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Edukasi'),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts_outlined),
                label: 'Kontak'),
            ],
          ),
        ),
      ),
    );
  }
}