import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_data.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = AppDataController.instance.currentUserProfile;
    _nameController = TextEditingController(text: profile['name']);
    _emailController = TextEditingController(text: profile['email']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);

    final newUrl = await ProfileService.uploadAvatar(
      userId: user.id,
      imageFile: pickedFile,
    );

    if (!mounted) return;
    setState(() => _isUploadingPhoto = false);

    if (newUrl != null) {
      AppDataController.instance.updateLocalProfile(avatarUrl: newUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mengupload foto profil. Pastikan bucket "avatars" ada dan bersifat public.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final success = await ProfileService.updateProfileName(user.id, newName);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppDataController.instance.updateLocalProfile(name: newName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan nama profil berhasil disimpan'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan nama. Periksa koneksi internet Anda.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAvatarPreview(Map profile, Color avatarColor, String? avatarUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Close di kanan atas
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(height: 12),
              // Avatar Preview Besar
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColor.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Center(
                        child: Text(
                          profile['initials'],
                          style: TextStyle(
                            fontSize: 84,
                            fontWeight: FontWeight.bold,
                            color: avatarColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              // Nama & Email Info
              Text(
                profile['name'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                profile['email'] ?? '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Tombol Aksi Ubah Foto
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Ganti Foto Profil',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController newPassCtrl = TextEditingController();
    final TextEditingController confirmPassCtrl = TextEditingController();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Ubah Kata Sandi',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    style: AppTextStyles.inputText,
                    decoration: InputDecoration(
                      hintText: 'Kata Sandi Baru (min. 6 karakter)',
                      hintStyle: AppTextStyles.cardSubtitle,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    style: AppTextStyles.inputText,
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Kata Sandi Baru',
                      hintStyle: AppTextStyles.cardSubtitle,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: isUpdating
                      ? null
                      : () async {
                          final pass = newPassCtrl.text.trim();
                          final confirm = confirmPassCtrl.text.trim();

                          if (pass.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kata sandi minimal 6 karakter'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          if (pass != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Konfirmasi kata sandi tidak cocok',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isUpdating = true);
                          try {
                            await ProfileService.updatePassword(pass);
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kata sandi berhasil diperbarui!',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isUpdating = false);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal update sandi: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final profile = AppDataController.instance.currentUserProfile;
        final Color avatarColor = Color(profile['avatarColor']);
        final String? avatarUrl = profile['avatarUrl'];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Account Settings',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarPreview(profile, avatarColor, avatarUrl),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarColor.withOpacity(0.15),
                            border: Border.all(
                              color: avatarColor.withOpacity(0.4),
                              width: 3,
                            ),
                            image: avatarUrl != null && avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _isUploadingPhoto
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColors.primary,
                                  ),
                                )
                              : (avatarUrl == null || avatarUrl.isEmpty)
                              ? Center(
                                  child: Text(
                                    profile['initials'],
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: avatarColor,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Personal Information', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'Email Address (Terikat Akun)',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // Button Ubah Kata Sandi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showChangePasswordDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '••••••••••••',
                                style: AppTextStyles.inputText.copyWith(
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Text(
                              'Ubah Sandi',
                              style: AppTextStyles.linkText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.cardSubtitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: AppTextStyles.inputText.copyWith(
            fontSize: 15,
            color: readOnly ? AppColors.textMuted : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: readOnly ? AppColors.surfaceMuted : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? AppColors.borderLight : AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
