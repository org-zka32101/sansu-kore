import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/grade_provider.dart';
import '../theme/app_theme.dart';

class ProfileSelectionScreen extends ConsumerStatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  ConsumerState<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends ConsumerState<ProfileSelectionScreen> {
  late TextEditingController _nameController;
  int _selectedGrade = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddProfileDialog() {
    _nameController.clear();
    _selectedGrade = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('プロフィールを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'お名前', hintText: 'たろう'),
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: _selectedGrade,
                isExpanded: true,
                items: List.generate(6, (i) => i + 1).map((g) {
                  return DropdownMenuItem(value: g, child: Text('小学$g年生'));
                }).toList(),
                onChanged: (val) => setDialogState(() => _selectedGrade = val ?? 1),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await ref.read(profileProvider.notifier).addProfile(
                    _nameController.text,
                    _selectedGrade,
                  );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profiles = profileState.profiles;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F5), Color(0xFFFFE8E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('🔴', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              const Text(
                '算数コレ！',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
              const SizedBox(height: 8),
              const Text(
                'だれが使う？',
                style: TextStyle(fontSize: 18, color: kTextMuted),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: profiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('プロフィールがありません', style: TextStyle(color: kTextMuted)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddProfileDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('プロフィールを追加'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: profiles.length + 1,
                        itemBuilder: (_, i) {
                          if (i == profiles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: OutlinedButton.icon(
                                onPressed: _showAddProfileDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('別のプロフィールを追加'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: kPrimaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            );
                          }
                          final profile = profiles[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () async {
                                await ref.read(profileProvider.notifier).setCurrentProfile(profile.id);
                                await ref.read(gradeProvider.notifier).setGrade(profile.grade);
                                if (mounted) {
                                  Navigator.of(context).pushReplacementNamed('/home');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: kPrimaryColor.withAlpha(30),
                                      radius: 28,
                                      child: Text(
                                        profile.name.isNotEmpty ? profile.name[0] : '？',
                                        style: const TextStyle(fontSize: 24, color: kPrimaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.name,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '小学${profile.grade}年生',
                                            style: const TextStyle(fontSize: 14, color: kTextMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: kTextMuted, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
