import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/app_data.dart';
import '../../../../main.dart';
import '../../../../theme/app_theme.dart';
import '../create_poll_screen.dart';

class PollingTab extends StatefulWidget {
  final String boardId;
  final bool isManager;

  const PollingTab({super.key, required this.boardId, required this.isManager});

  @override
  State<PollingTab> createState() => _PollingTabState();
}

class _PollingTabState extends State<PollingTab> {
  RealtimeChannel? _pollChannel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPolls();
  }

  Future<void> _initPolls() async {
    await AppDataController.instance.loadPollsForBoard(widget.boardId);
    if (mounted) setState(() => _isLoading = false);

    _pollChannel = supabase
        .channel('public:polls_${widget.boardId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'polls',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'board_id',
            value: widget.boardId,
          ),
          callback: (_) =>
              AppDataController.instance.loadPollsForBoard(widget.boardId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'poll_options',
          callback: (_) =>
              AppDataController.instance.loadPollsForBoard(widget.boardId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'poll_votes',
          callback: (_) =>
              AppDataController.instance.loadPollsForBoard(widget.boardId),
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_pollChannel != null) {
      supabase.removeChannel(_pollChannel!);
    }
    super.dispose();
  }

  String _formatDateTime(
    DateTime? dt, {
    String fallback = 'Tanpa batas waktu',
  }) {
    if (dt == null) return fallback;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hh:$mm';
  }

  void _showQuickPollModal(BuildContext context, String pollId) {
    final currentUserId =
        AppDataController.instance.currentUserProfile['id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: AppDataController.instance,
          builder: (context, _) {
            final board = AppDataController.instance.boards.firstWhere(
              (b) => b['id'].toString() == widget.boardId,
              orElse: () => <String, dynamic>{},
            );
            final List polls = (board['polls'] as List?) ?? [];
            final poll = polls.firstWhere(
              (p) => p['id'].toString() == pollId,
              orElse: () => <String, dynamic>{},
            );

            if (poll.isEmpty) return const SizedBox.shrink();

            final String question = poll['question']?.toString() ?? 'Polling';
            final String creator = poll['creator']?.toString() ?? 'Anggota';
            final DateTime? createdAt = poll['createdAt'] != null
                ? DateTime.tryParse(poll['createdAt'].toString())
                : null;
            final DateTime? dueDate = poll['dueDate'] as DateTime?;
            final bool isExpired =
                dueDate != null && DateTime.now().isAfter(dueDate);
            final bool isActive = poll['isClosed'] != true;
            final bool showBeforeVote = poll['showResultBeforeVote'] ?? true;
            final List options = (poll['options'] as List?) ?? [];

            int totalVotes = 0;
            bool hasUserVoted = false;
            for (var opt in options) {
              final votes = (opt['votes'] as List?) ?? [];
              totalVotes += votes.length;
              if (votes.contains(currentUserId)) {
                hasUserVoted = true;
              }
            }

            final bool canSeeResults =
                showBeforeVote || hasUserVoted || !isActive;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F7F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question,
                                style: AppTextStyles.screenTitle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dibuat oleh $creator • ${_formatDateTime(createdAt, fallback: 'Baru saja')}',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (poll['createdBy'] == currentUserId ||
                            widget.isManager)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 22,
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await AppDataController.instance.deletePoll(
                                widget.boardId,
                                pollId,
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE6F7F5)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isActive ? 'Aktif' : 'Selesai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people_alt_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$totalVotes suara',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isActive
                          ? 'Ketuk opsi untuk memilih suara'
                          : 'Hasil Akhir Polling',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                    if (dueDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFFDBA74)
                                : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.schedule_rounded
                                  : Icons.lock_clock_rounded,
                              size: 16,
                              color: isActive
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isActive
                                    ? 'Batas waktu: ${_formatDateTime(dueDate)}'
                                    : 'Polling ditutup pada ${_formatDateTime(dueDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? const Color(0xFFC2410C)
                                      : const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ...options.map((opt) {
                      final String optId = opt['id'].toString();
                      final String optTitle = opt['title']?.toString() ?? '';
                      final List votes = (opt['votes'] as List?) ?? [];
                      final bool isSelected = votes.contains(currentUserId);
                      final double percent = totalVotes == 0
                          ? 0.0
                          : (votes.length / totalVotes);

                      return _buildInteractiveOptionTile(
                        title: optTitle,
                        votes: votes.length,
                        percent: percent,
                        isSelected: isSelected,
                        showResult: canSeeResults,
                        enabled: isActive,
                        onTap: () => AppDataController.instance.votePoll(
                          widget.boardId,
                          pollId,
                          optId,
                        ),
                      );
                    }),
                    if (!canSeeResults)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Hasil suara disembunyikan hingga Anda memberikan suara.',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F7F5),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveOptionTile({
    required String title,
    required int votes,
    required double percent,
    required bool isSelected,
    required bool showResult,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final String percentStr = (percent * 100)
        .toStringAsFixed(1)
        .replaceAll('.0', '');

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F7F5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (showResult)
                  Text(
                    '$percentStr% ($votes)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            if (showResult) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 7,
                  backgroundColor: Colors.white,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'].toString() == widget.boardId,
          orElse: () => <String, dynamic>{'title': 'Board'},
        );

        final String boardTitle = board['title']?.toString() ?? 'Board';
        final List dynamicPolls = (board['polls'] is List)
            ? board['polls']
            : [];

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              AppDataController.instance.loadPollsForBoard(widget.boardId),
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Polling',
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreatePollScreen(
                            boardId: widget.boardId,
                            boardTitle: boardTitle,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Buat Polling',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (dynamicPolls.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.poll_outlined,
                        size: 44,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada polling di board ini',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tekan tombol "Buat Polling" untuk memulai voting tim.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...dynamicPolls.map((poll) {
                  if (poll is! Map) return const SizedBox.shrink();
                  final pollMap = Map<String, dynamic>.from(poll);

                  int totalRespondents = 0;
                  if (pollMap['options'] is List) {
                    for (var opt in (pollMap['options'] as List)) {
                      if (opt is Map && opt['votes'] is List) {
                        totalRespondents += (opt['votes'] as List).length;
                      }
                    }
                  }

                  final DateTime? dueDate = pollMap['dueDate'] as DateTime?;
                  final bool isExpired =
                      dueDate != null && DateTime.now().isAfter(dueDate);
                  final bool isCardActive =
                      (pollMap['isClosed'] != true) && !isExpired;
                  final String dateLabel = dueDate != null
                      ? 'Batas: ${_formatDateTime(dueDate)}'
                      : 'Aktif terus';

                  return _buildPollCard(
                    title: pollMap['question']?.toString() ?? 'Tanpa Judul',
                    creator: pollMap['creator']?.toString() ?? 'Anggota',
                    date: dateLabel,
                    respondents: totalRespondents,
                    isActive: isCardActive,
                    onTap: () =>
                        _showQuickPollModal(context, pollMap['id'].toString()),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollCard({
    required String title,
    required String creator,
    required String date,
    required int respondents,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibuat oleh $creator',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                date,
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFF0FAF8)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Aktif' : 'Selesai',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$respondents responden',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
