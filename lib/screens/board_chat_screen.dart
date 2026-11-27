import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/app_data.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';
import '../widgets/mention_suggestion_box.dart';

class BoardChatScreen extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const BoardChatScreen({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<BoardChatScreen> createState() => _BoardChatScreenState();
}

class _BoardChatScreenState extends State<BoardChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  RealtimeChannel? _chatChannel;

  String? _mentionQuery;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtimeSubscription();
    _messageController.addListener(() {
      final q = MentionHelper.getActiveMentionQuery(_messageController);
      if (q != _mentionQuery && mounted) {
        setState(() => _mentionQuery = q);
      }
    });
  }

  @override
  void dispose() {
    _chatChannel?.unsubscribe();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final fetched = await ChatService.fetchMessages(widget.boardId);
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(fetched);
        _isLoading = false;
      });
    }
  }

  void _setupRealtimeSubscription() {
    _chatChannel = ChatService.subscribeToBoardMessages(
      boardId: widget.boardId,
      onInsert: (newRecord) async {
        // Cek jika pesan sudah ada di list untuk menghindari duplikasi
        final messageId = newRecord['id'];
        if (_messages.any((m) => m['id'] == messageId)) return;

        // Ambil info profil pengirim jika belum ada di payload realtime
        Map<String, dynamic> completeMessage = Map<String, dynamic>.from(
          newRecord,
        );
        if (completeMessage['profiles'] == null) {
          final senderId = completeMessage['sender_id'];
          // Cek dari members di board controller atau fetch
          final dynamic foundBoard = AppDataController.instance.boards
              .firstWhere(
                (b) => b['id'].toString() == widget.boardId,
                orElse: () => <String, dynamic>{},
              );
          final board = foundBoard is Map ? foundBoard : {};
          final members = (board['members'] as List?) ?? [];
          final dynamic foundMember = members.firstWhere(
            (m) => m is Map && m['userId'].toString() == senderId.toString(),
            orElse: () => <String, dynamic>{},
          );
          final member = foundMember is Map ? foundMember : null;

          if (member != null) {
            completeMessage['profiles'] = {
              'name': member['name'],
              'avatar_color': member['color'],
            };
          } else {
            completeMessage['profiles'] = {
              'name': 'Anggota',
              'avatar_color': 0xFF00A896,
            };
          }
        }

        if (mounted) {
          setState(() {
            _messages.insert(0, completeMessage);
          });
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentProfile = AppDataController.instance.currentUserProfile;
    final userId = currentUser?.id ?? currentProfile['id']?.toString() ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Anda belum login')));
      return;
    }

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final sentMessage = await ChatService.sendMessage(
        boardId: widget.boardId,
        senderId: userId,
        text: text,
      );

      if (sentMessage != null && mounted) {
        // Jika belum ada di list (belum masuk dari stream), tambahkan langsung
        if (!_messages.any((m) => m['id'] == sentMessage['id'])) {
          setState(() {
            _messages.insert(0, sentMessage);
          });
        }
        // Deteksi @mention dan kirim notifikasi ke anggota yang disebut
        await AppDataController.instance.processMentionsAndNotify(
          boardId: widget.boardId,
          contentText: text,
          contextLabel: 'Ruang Diskusi',
          referenceId: widget.boardId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString()).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour.$minute';
    } catch (_) {
      return '';
    }
  }

  String _formatDateHeader(dynamic createdAt) {
    if (createdAt == null) return 'Hari ini';
    try {
      final dt = DateTime.parse(createdAt.toString()).toLocal();
      const monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Hari ini, ${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
      }
      return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Riwayat Chat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ??
        AppDataController.instance.currentUserProfile['id']?.toString() ??
        '';

    final dynamic foundBoard = AppDataController.instance.boards.firstWhere(
      (b) => b['id'].toString() == widget.boardId,
      orElse: () => <String, dynamic>{},
    );
    final board = foundBoard is Map ? foundBoard : {};
    final List members = List.from(board['members'] ?? []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Latar blob khas aplikasi
          const TopDecorBlob(size: 160),
          Positioned(
            bottom: 0,
            left: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/leaves_decor.png',
                width: 140,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. HEADER (App Bar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'Chat Board',
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.boardTitle,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48), // Spacer untuk keseimbangan
                    ],
                  ),
                ),

                // 2. INFO ANGGOTA & JUMLAH (Pill info)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (members.isNotEmpty)
                              ...members.take(3).toList().asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final m = entry.value as Map;
                                final name = m['name']?.toString() ?? 'U';
                                final initial = name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : 'U';
                                final colorVal = m['color'] is int
                                    ? m['color'] as int
                                    : 0xFF00A896;

                                return Transform.translate(
                                  offset: Offset(-8.0 * index, 0),
                                  child: _buildMiniAvatar(
                                    initial,
                                    Color(colorVal),
                                  ),
                                );
                              })
                            else
                              _buildMiniAvatar('U', const Color(0xFF00A896)),
                            if (members.length > 3)
                              Transform.translate(
                                offset: Offset(-8.0 * 3, 0),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${members.length - 3}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 1,
                              height: 16,
                              color: AppColors.border,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${members.length > 0 ? members.length : 1} anggota dalam Board',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. DAFTAR CHAT (List)
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: AppColors.textMuted.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada percakapan di board ini.',
                                style: AppTextStyles.cardSubtitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mulai kirim pesan pertama Anda!',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              _messages.length + 1, // +1 untuk badge tanggal
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              final oldestMsg = _messages.isNotEmpty
                                  ? _messages.last['created_at']
                                  : null;
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 24,
                                    top: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted.withOpacity(
                                      0.6,
                                    ),
                                    borderRadius: AppRadius.roundedPill,
                                  ),
                                  child: Text(
                                    _formatDateHeader(oldestMsg),
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final msg = _messages[index];
                            final senderId = msg['sender_id']?.toString() ?? '';
                            final isMe =
                                senderId.isNotEmpty &&
                                senderId == currentUserId;

                            final profile = msg['profiles'] as Map? ?? {};
                            final senderName =
                                profile['name']?.toString() ??
                                (isMe ? 'Saya' : 'Anggota');
                            final initial = senderName.isNotEmpty
                                ? senderName[0].toUpperCase()
                                : 'A';

                            final colorVal = profile['avatar_color'] is int
                                ? profile['avatar_color'] as int
                                : (isMe ? 0xFF00A896 : 0xFF3B82F6);

                            final timeStr = _formatTime(msg['created_at']);

                            return _buildChatBubble(
                              text: msg['text']?.toString() ?? '',
                              sender: isMe ? 'Saya' : senderName,
                              initial: initial,
                              time: timeStr,
                              color: Color(colorVal),
                              isMe: isMe,
                            );
                          },
                        ),
                ),

                // 4. INPUT AREA
                // 4. INPUT AREA
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_mentionQuery != null)
                        MentionSuggestionBox(
                          members: members,
                          query: _mentionQuery!,
                          currentUserId: currentUserId,
                          onSelectMember: (name) {
                            MentionHelper.insertMention(
                              _messageController,
                              name,
                            );
                            setState(() => _mentionQuery = null);
                          },
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_file_rounded,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Ketik pesan...',
                                        hintStyle: AppTextStyles.cardSubtitle
                                            .copyWith(fontSize: 13),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                      ),
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 13,
                                      ),
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _isSending ? null : _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isSending
                                    ? AppColors.primary.withOpacity(0.5)
                                    : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String initial, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required String text,
    required String sender,
    required String initial,
    required String time,
    required Color color,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sender,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 11),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primarySurface : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isMe
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
