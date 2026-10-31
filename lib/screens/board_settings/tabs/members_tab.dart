import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class MembersTab extends StatelessWidget {
  final String boardId;
  final bool isManager;

  const MembersTab({super.key, required this.boardId, required this.isManager});

  // Data dummy statis sesuai desain (Pengelola dihapus, Ahmad Fauzi dijadikan Admin)
  final List<Map<String, dynamic>> _dummyMembers = const [
    {
      'name': 'Ilham Muttaqin',
      'email': 'ilham@email.com',
      'role': 'Admin',
      'initial': 'I',
      'textColor': Color(0xFF00A896), // Primary Tosca
      'bgColor': Color(0xFFE6F7F5),
    },
    {
      'name': 'Ana Nurfiatin',
      'email': 'ana@email.com',
      'role': 'Admin',
      'initial': 'A',
      'textColor': Color(0xFF0284C7), // Blue
      'bgColor': Color(0xFFE0F2FE),
    },
    {
      'name': 'Shoffi Dhiya Nawangsari',
      'email': 'Shoffi@email.com',
      'role': 'Anggota',
      'initial': 'R',
      'textColor': Color(0xFFD97706), // Orange
      'bgColor': Color(0xFFFEF3C7),
    },
    {
      'name': 'Alfindi Edo Kurnia',
      'email': 'Alfindi@email.com',
      'role': 'Anggota',
      'initial': 'S',
      'textColor': Color(0xFF16A34A), // Green
      'bgColor': Color(0xFFDCFCE7),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Ringkasan Anggota',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        // 1. KARTU RINGKASAN
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
            boxShadow: const [AppShadows.card],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  Icons.groups_outlined,
                  '4',
                  'Total Anggota',
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.borderLight),
              Expanded(
                child: _buildSummaryStat(
                  Icons.workspace_premium_outlined,
                  '2',
                  'Admin',
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.borderLight),
              Expanded(
                child: _buildSummaryStat(
                  Icons.person_outline_rounded,
                  '2',
                  'Anggota',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. HEADER DAFTAR ANGGOTA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Anggota',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 16),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Undang Anggota',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. KARTU LIST ANGGOTA
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
            boxShadow: const [AppShadows.card],
          ),
          child: Column(
            children: [
              ...List.generate(_dummyMembers.length, (index) {
                final member = _dummyMembers[index];
                return Column(
                  children: [
                    _buildMemberRow(
                      name: member['name'],
                      email: member['email'],
                      role: member['role'],
                      initial: member['initial'],
                      textColor: member['textColor'],
                      bgColor: member['bgColor'],
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),
              // Tombol Lihat Semua di Bawah
              InkWell(
                onTap: () {},
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lihat semua anggota',
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // WIDGET BANTUAN 1: Statistik Ringkasan
  Widget _buildSummaryStat(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18, height: 1),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10)),
      ],
    );
  }

  // WIDGET BANTUAN 2: Baris Anggota
  Widget _buildMemberRow({
    required String name,
    required String email,
    required String role,
    required String initial,
    required Color textColor,
    required Color bgColor,
  }) {
    final bool isAdmin = role == 'Admin';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bgColor,
            radius: 20,
            child: Text(
              initial,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                ),
                Text(
                  email,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin
                  ? const Color(0xFFE6F7F5)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAdmin ? AppColors.primary : const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
