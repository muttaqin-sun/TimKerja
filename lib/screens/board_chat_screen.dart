import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';

class BoardChatScreen extends StatefulWidget {
  final String boardTitle;

  const BoardChatScreen({super.key, required this.boardTitle});

  @override
  State<BoardChatScreen> createState() => _BoardChatScreenState();
}

class _BoardChatScreenState extends State<BoardChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // PERUBAHAN 1: Urutan data dibalik (Pesan terbaru ditaruh di paling atas / index 0)
  final List _messages = [
    {
      'sender': 'Ilham',
      'initial': 'I',
      'color': const Color(0xFF00A896),
      'time': '09.32',
      'text': 'Oke, makasih semuanya 🙏',
      'isMe': true,
    },
    {
      'sender': 'Budi',
      'initial': 'B',
      'color': const Color(0xFF10B981), // Hijau
      'time': '09.20',
      'text': 'Baik, nanti saya bantu cek materinya.',
      'isMe': false,
    },
    {
      'sender': 'Ilham',
      'initial': 'I',
      'color': const Color(0xFF00A896), // Tosca
      'time': '09.18',
      'text': 'Materinya sudah saya susun, tinggal bagian desain slide.',
      'isMe': true,
    },
    {
      'sender': 'Sari',
      'initial': 'S',
      'color': const Color(0xFF3B82F6), // Biru
      'time': '09.15',
      'text': 'Teman-teman, untuk tugas presentasi sudah sampai mana?',
      'isMe': false,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        // PERUBAHAN 2: Gunakan insert(0) agar pesan baru masuk ke index 0 (paling bawah di layar)
        _messages.insert(0, {
          'sender': 'Ilham',
          'initial': 'I',
          'color': const Color(0xFF00A896),
          'time': '09.35', // Dummy waktu terbaru
          'text': _messageController.text.trim(),
          'isMe': true,
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // 2. INFO ANGGOTA & WAKTU (Pill info)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
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
                            _buildMiniAvatar('I', const Color(0xFF00A896)),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: _buildMiniAvatar(
                                'S',
                                const Color(0xFF3B82F6),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-16, 0),
                              child: _buildMiniAvatar(
                                'B',
                                const Color(0xFF10B981),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-24, 0),
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
                                    '+1',
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
                              '4 anggota dalam Board',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
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
                  child: ListView.builder(
                    // PERUBAHAN 3: Aktifkan reverse agar list menempel di bawah dan ikut naik saat keyboard muncul
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length + 1, // +1 untuk badge tanggal
                    itemBuilder: (context, index) {
                      // PERUBAHAN 4: Karena reverse=true, index terakhir adalah posisi paling atas layar
                      if (index == _messages.length) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24, top: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted.withOpacity(0.6),
                              borderRadius: AppRadius.roundedPill,
                            ),
                            child: Text(
                              'Hari ini, 1 November 2026',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      return _buildChatBubble(
                        text: msg['text'],
                        sender: msg['sender'],
                        initial: msg['initial'],
                        time: msg['time'],
                        color: msg['color'],
                        isMe: msg['isMe'],
                      );
                    },
                  ),
                ),

                // 4. INPUT AREA
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderLight),
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
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
    // Sedikit penyesuaian padding karena reverse: true membalik arah render
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
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
                    ),
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
