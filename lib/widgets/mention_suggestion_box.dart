import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MentionHelper {
  /// Mengembalikan kata kunci setelah '@' pada posisi kursor saat ini,
  /// atau null jika kursor tidak sedang mengetik mention.
  static String? getActiveMentionQuery(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid || selection.baseOffset <= 0) return null;

    final cursor = selection.baseOffset;
    final beforeCursor = text.substring(0, cursor);
    final lastAtIndex = beforeCursor.lastIndexOf('@');

    if (lastAtIndex == -1) return null;

    // Pastikan '@' berada di awal teks atau didahului spasi/baris baru (bukan email)
    if (lastAtIndex > 0) {
      final charBefore = beforeCursor[lastAtIndex - 1];
      if (charBefore != ' ' && charBefore != '\n') return null;
    }

    final query = beforeCursor.substring(lastAtIndex + 1);
    // Jika sudah ada spasi ganda atau baris baru, anggap mention selesai
    if (query.contains('\n')) return null;

    return query;
  }

  /// Menyisipkan '@Nama ' menggantikan '@query' pada posisi kursor
  static void insertMention(
    TextEditingController controller,
    String memberName,
  ) {
    final text = controller.text;
    final cursor = controller.selection.baseOffset;
    if (cursor <= 0) return;

    final beforeCursor = text.substring(0, cursor);
    final lastAtIndex = beforeCursor.lastIndexOf('@');
    if (lastAtIndex == -1) return;

    final afterCursor = text.substring(cursor);
    final inserted = '@$memberName ';
    final newText = text.substring(0, lastAtIndex) + inserted + afterCursor;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: lastAtIndex + inserted.length),
    );
  }

  /// Mencocokkan '@Nama' di dalam teks dengan daftar anggota board
  static List<String> extractMentionedUserIds({
    required String text,
    required List<dynamic> boardMembers,
    required String excludeUserId,
  }) {
    final lowerText = text.toLowerCase();
    final Set<String> targetIds = {};

    for (final m in boardMembers) {
      if (m is! Map) continue;
      final uid = m['userId']?.toString() ?? '';
      final name = m['name']?.toString().trim() ?? '';
      if (uid.isEmpty || uid == excludeUserId || name.isEmpty) continue;

      if (lowerText.contains('@${name.toLowerCase()}')) {
        targetIds.add(uid);
      }
    }

    return targetIds.toList();
  }
}

class MentionSuggestionBox extends StatelessWidget {
  final List<dynamic> members;
  final String query;
  final String currentUserId;
  final Function(String memberName) onSelectMember;

  const MentionSuggestionBox({
    super.key,
    required this.members,
    required this.query,
    required this.currentUserId,
    required this.onSelectMember,
  });

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final filtered = members.where((m) {
      if (m is! Map) return false;
      final uid = m['userId']?.toString() ?? '';
      final name = m['name']?.toString() ?? '';
      if (uid == currentUserId || name.isEmpty) return false;
      return name.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: const [AppShadows.card],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: filtered.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final member = filtered[index] as Map;
          final name = member['name']?.toString() ?? 'Anggota';
          final role = member['role']?.toString() ?? 'Member';

          return InkWell(
            onTap: () => onSelectMember(name),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role,
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
