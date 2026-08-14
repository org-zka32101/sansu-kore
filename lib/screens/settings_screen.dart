import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show CrossPromoSection;
import '../providers/profile_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/daily_login_provider.dart';
import '../providers/adaptive_provider.dart';
import '../providers/logout_provider.dart';
import '../providers/sansu_profile_provider.dart';
import '../providers/tts_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).currentProfile;
    final premium = ref.watch(premiumProvider);
    final daily = ref.watch(dailyLoginProvider);
    final sansuProfile = ref.watch(sansuProfileProvider);
    final tts = ref.watch(ttsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('縺帙▲縺ｦ縺・),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 繝励Ο繝輔ぅ繝ｼ繝ｫ
            if (profile != null) ...[
              _SectionHeader('繝励Ο繝輔ぅ繝ｼ繝ｫ'),
              _SettingCard(
                emoji: '側',
                title: profile.name,
                subtitle: '蟆丞ｭｦ${profile.grade}蟷ｴ逕・,
                onTap: () => Navigator.of(context).pushNamed('/profile-selection'),
              ),
            ],

            const SizedBox(height: 16),

            // 荳ｻ莠ｺ蜈ｬ縺ｮ險ｭ螳夲ｼ遺贈荳ｻ莠ｺ蜈ｬ譁・ｫ鬘鯉ｼ・
            _SectionHeader('譁・ｫ鬘後・荳ｻ莠ｺ蜈ｬ'),
            _SettingCard(
              emoji: '賜',
              title: '螂ｽ縺阪↑繧ゅ・: ${sansuProfile.favoriteItem}',
              subtitle: '譁・ｫ鬘後↓逋ｻ蝣ｴ縺吶ｋ繧ゅ・繧帝∈縺ｹ繧九ｈ',
              onTap: () => _showFavoriteItemDialog(context, ref, sansuProfile.favoriteItem),
            ),

            const SizedBox(height: 16),

            // 繝・う繝ｪ繝ｼ繝ｭ繧ｰ繧､繝ｳ諠・ｱ
            _SectionHeader('繝・う繝ｪ繝ｼ繝ｭ繧ｰ繧､繝ｳ'),
            _InfoCard(
              children: [
                _InfoRow('騾｣邯壹Ο繧ｰ繧､繝ｳ', '${daily.loginStreak}譌･'),
                _InfoRow('邏ｯ險医Ο繧ｰ繧､繝ｳ', '${daily.totalLoginDays}譌･'),
                _InfoRow('莉頑律縺ｮ蜿励￠蜿悶ｊ', daily.todayClaimed ? '笨・蜿励￠蜿悶ｊ貂医∩' : '氏 譛ｪ蜿励￠蜿悶ｊ'),
              ],
            ),

            const SizedBox(height: 16),

            // 繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ
            _SectionHeader('繝励Λ繝ｳ'),
            _SettingCard(
              emoji: premium.isPremium ? '箝・ : '箔',
              title: premium.isPremium
                  ? '繝励Ξ繝溘い繝莨壼藤'
                  : premium.isTrialActive
                      ? '繝医Λ繧､繧｢繝ｫ荳ｭ・医≠縺ｨ${premium.trialDaysLeft}譌･・・
                      : '辟｡譁吶・繝ｩ繝ｳ',
              subtitle: premium.isPremium ? '蜈ｨ繧ｹ繝・・繧ｸ蛻ｩ逕ｨ蜿ｯ閭ｽ' : '繧｢繝・・繧ｰ繝ｬ繝ｼ繝峨〒蜈ｨ讖溯・隗｣謾ｾ',
              onTap: () => Navigator.of(context).pushNamed('/upgrade'),
            ),

            const SizedBox(height: 16),

            // 隕ｪ縺ｮ縺ｻ繧√Γ繝・そ繝ｼ繧ｸ
            _SectionHeader('菫晁ｭｷ閠・∈縺ｮ繝｡繝・そ繝ｼ繧ｸ'),
            FutureBuilder<List<PraiseMessage>>(
              future: NotificationService.getPraiseQueue(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('隱ｭ縺ｿ霎ｼ縺ｿ繧ｨ繝ｩ繝ｼ: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('縺ｾ縺繝｡繝・そ繝ｼ繧ｸ縺ｯ縺ゅｊ縺ｾ縺帙ｓ', style: TextStyle(color: kTextMuted, fontSize: 14)),
                  );
                }
                return Column(
                  children: messages.reversed.take(5).map((msg) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isRead ? Colors.white : const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('捉窶昨汨ｩ窶昨汨ｧ', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.achievement, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(
                                '${msg.timestamp.month}/${msg.timestamp.day} ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: kTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 16),

            // 痔 髻ｳ螢ｰ隱ｭ縺ｿ荳翫￡險ｭ螳夲ｼ・TS・・
            _SectionHeader('痔 髻ｳ螢ｰ隱ｭ縺ｿ荳翫￡'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 髻ｳ驥上せ繝ｩ繧､繝繝ｼ
                  Row(
                    children: [
                      const Icon(Icons.volume_down, size: 20, color: kTextMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: tts.volume,
                          onChanged: (val) => ref.read(ttsProvider.notifier).setVolume(val),
                          min: 0,
                          max: 1,
                          activeColor: kPrimaryColor,
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.volume_up, size: 20, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${(tts.volume * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 騾溷ｺｦ繧ｹ繝ｩ繧､繝繝ｼ
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 20, color: kTextMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: tts.rate,
                          onChanged: (val) => ref.read(ttsProvider.notifier).setRate(val),
                          min: 0,
                          max: 1,
                          activeColor: kPrimaryColor,
                          inactiveColor: Colors.grey.shade300,
                          divisions: 10,
                          label: tts.rate < 0.5 ? '繧・▲縺上ｊ' : tts.rate < 0.8 ? '騾壼ｸｸ' : '騾溘＞',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(tts.rate * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 繝・せ繝郁ｪｭ縺ｿ荳翫￡繝懊ち繝ｳ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (tts.isSpeaking && tts.currentSource == TtsSource.question) {
                          await ref.read(ttsProvider.notifier).stop();
                        } else {
                          try {
                            await ref.read(ttsProvider.notifier).speak(
                              '縺薙ｌ縺ｯ繝・せ繝医〒縺吶る浹螢ｰ縺ｮ隱ｿ蟄舌ｒ縺顔｢ｺ縺九ａ縺上□縺輔＞縲・,
                              source: TtsSource.question,
                            ).timeout(
                              const Duration(seconds: 5),
                              onTimeout: () => throw Exception('髻ｳ螢ｰ蜀咲函縺後ち繧､繝繧｢繧ｦ繝医＠縺ｾ縺励◆'),
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('繧ｨ繝ｩ繝ｼ: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: Icon(
                        tts.isSpeaking ? Icons.stop : Icons.play_arrow,
                        size: 20,
                      ),
                      label: Text(
                        tts.isSpeaking ? '蜀咲函蛛懈ｭ｢' : '繝・せ繝亥・逕・,
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 縺昴・莉・
            _SectionHeader('縺昴・莉・),
            _SettingCard(
              emoji: '闘',
              title: '謌宣聞繧ｿ繧､繝繧ｫ繝励そ繝ｫ',
              subtitle: '譛蛻昴・險倬鹸縺ｨ莉翫ｒ豈斐∋繧医≧',
              onTap: () => Navigator.of(context).pushNamed('/growth'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '足',
              title: '縺ｨ繧ゅさ繝ｬ・∝暑驕疲魚蠕・,
              subtitle: '縺雁暑驕斐ｒ諡帛ｾ・＠縺ｦ30繧ｳ繧､繝ｳ繧ｲ繝・ヨ',
              onTap: () => Navigator.of(context).pushNamed('/invite'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '塘',
              title: '繝励Λ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ',
              subtitle: null,
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '卵・・,
              title: '蟄ｦ鄙偵ョ繝ｼ繧ｿ繧偵Μ繧ｻ繝・ヨ',
              subtitle: '騾ｲ謐励・繧ｳ繧､繝ｳ縺悟・縺ｦ蜑企勁縺輔ｌ縺ｾ縺・,
              onTap: () => _showResetDialog(context, ref),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '坎',
              title: '繝ｭ繧ｰ繧｢繧ｦ繝・,
              subtitle: '蛻･縺ｮ繝励Ο繝輔ぅ繝ｼ繝ｫ縺ｫ蛻・ｊ譖ｿ縺医ｋ',
              onTap: () => _showLogoutDialog(context, ref),
            ),

            const CrossPromoSection(
              currentAppId: 'com.apps.shougakukore.sansu',
              currentCategory: '蟆丞ｭｦ繧ｳ繝ｬ',
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text(
                '邂玲焚繧ｳ繝ｬ・・v2.0.0',
                style: TextStyle(color: kTextMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('繝ｪ繧ｻ繝・ヨ縺励∪縺吶°・・),
        content: const Text('蟄ｦ鄙貞ｱ･豁ｴ繝ｻ繧ｳ繧､繝ｳ繝ｻ繝舌ャ繧ｸ縺悟・縺ｦ蜑企勁縺輔ｌ縺ｾ縺吶ゅ％縺ｮ謫堺ｽ懊・蜿悶ｊ豸医○縺ｾ縺帙ｓ縲・),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              await ref.read(progressProvider.notifier).reset();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('繝ｪ繧ｻ繝・ヨ'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('繝ｭ繧ｰ繧｢繧ｦ繝医＠縺ｾ縺吶°・・),
        content: const Text(
          '迴ｾ蝨ｨ縺ｮ繝励Ο繝輔ぅ繝ｼ繝ｫ縺九ｉ繝ｭ繧ｰ繧｢繧ｦ繝医＠縺ｾ縺吶・n\n'
          '縺吶∋縺ｦ縺ｮ繝・・繧ｿ・亥ｭｦ鄙貞ｱ･豁ｴ繝ｻ繧ｳ繧､繝ｳ繝ｻ繝舌ャ繧ｸ遲会ｼ峨・菫晄戟縺輔ｌ縺ｾ縺吶・,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 繝ｭ繧ｰ繧｢繧ｦ繝亥・逅・ｒ螳溯｡・
              final notifier = ref.read(logoutWithUIProvider.notifier);
              final success = await notifier.logout();

              if (success && ctx.mounted) {
                // 繝ｭ繧ｰ繧｢繧ｦ繝域・蜉・竊・繝ｭ繧ｰ繧､繝ｳ逕ｻ髱｢縺ｸ
                Navigator.pop(ctx); // 繝繧､繧｢繝ｭ繧ｰ繧帝哩縺倥ｋ
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/splash', // 縺ｾ縺溘・繝ｭ繧ｰ繧､繝ｳ逕ｻ髱｢縺ｮ繝ｫ繝ｼ繝・
                  (route) => false,
                );

                // 繧ｹ繝翫ャ繧ｯ繝舌・陦ｨ遉ｺ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('繝ｭ繧ｰ繧｢繧ｦ繝医＠縺ｾ縺励◆'),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              } else if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('繝ｭ繧ｰ繧｢繧ｦ繝医↓螟ｱ謨励＠縺ｾ縺励◆'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              '繝ｭ繧ｰ繧｢繧ｦ繝・,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.bold)),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingCard({required this.emoji, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: kTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }
}

// 笏笏笏 螂ｽ縺阪↑繧ゅ・驕ｸ謚槭ム繧､繧｢繝ｭ繧ｰ・遺贈荳ｻ莠ｺ蜈ｬ譁・ｫ鬘鯉ｼ・笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏笏
void _showFavoriteItemDialog(
    BuildContext context, WidgetRef ref, String currentItem) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('賜 螂ｽ縺阪↑繧ゅ・繧帝∈繧薙〒縺ｭ'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kFavoriteItemOptions.map((item) {
          final isSelected = item == currentItem;
          return GestureDetector(
            onTap: () {
              ref.read(sansuProfileProvider.notifier).setFavoriteItem(item);
              Navigator.pop(ctx);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : kTextDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('縺ｨ縺倥ｋ'))
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: kTextMuted)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

