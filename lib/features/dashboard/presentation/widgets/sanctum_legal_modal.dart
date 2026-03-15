import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Sanctum Legal Modal — elegant glassmorphic scrollable overlay.
///
/// Displays legal text (Disclaimer, Privacy Policy, Terms of Sovereignty)
/// as a full-screen overlay without navigating away from the Dashboard.
///
/// CTO Directive: "These must open as elegant, scrollable glassmorphic
/// overlays. Do not take the user away from the Dashboard."
class SanctumLegalModal {
  SanctumLegalModal._();

  /// Show a legal modal overlay.
  static void show(
    BuildContext context, {
    required String title,
    required String titleAr,
    required String body,
    required String bodyAr,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        final bgColor = isDark
            ? SanctumColors.obsidian.withValues(alpha: 0.95)
            : SanctumColors.lightSurface.withValues(alpha: 0.95);
        final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
        final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
        final textSecondary = isDark ? SanctumColors.textSecondary : SanctumColors.lightTextSecondary;
        final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ─── Header ─────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.gavel_outlined,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isRtl ? titleAr : title,
                                    style: SanctumTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    color: textTertiary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ─── Divider ────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Container(
                              height: 1,
                              color: accentColor.withValues(alpha: 0.1),
                            ),
                          ),

                          // ─── Scrollable body ────────────────────────
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Text(
                                isRtl ? bodyAr : body,
                                style: SanctumTypography.bodyMedium.copyWith(
                                  color: textSecondary,
                                  height: 1.7,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Pre-built Legal Content ──────────────────────────────────────────

  static void showDisclaimer(BuildContext context) {
    show(
      context,
      title: 'Disclaimer',
      titleAr: 'إخلاء المسؤولية',
      body: '''Project Aeterna is a sovereign digital vault designed for personal asset management and estate planning.

IMPORTANT NOTICES:

1. NOT FINANCIAL ADVICE — Project Aeterna does not provide financial, legal, or tax advice. All asset management decisions are the sole responsibility of the vault owner.

2. LOCAL-FIRST ARCHITECTURE — All data is stored locally on your device. Project Aeterna does not transmit, store, or process your data on external servers during Sprint 1.

3. ENCRYPTION — While we employ military-grade encryption standards (AES-256-GCM with Argon2id key derivation), no system is immune to all threats. Users are responsible for maintaining the physical security of their devices.

4. BIOMETRIC DATA — Biometric templates are processed locally and never stored in persistent storage. They exist only in volatile memory during active sessions.

5. BETA SOFTWARE — This is a development build. Features, interfaces, and security implementations may change without notice.

6. ZERO-KNOWLEDGE — Project Aeterna operates on a zero-knowledge principle. We cannot recover your data if you lose access to your biometric credentials or PIN.

By using this application, you acknowledge and accept these terms.

© 2024 Project Aeterna. All rights reserved.''',
      bodyAr: '''مشروع إيتيرنا هو خزنة رقمية سيادية مصممة لإدارة الأصول الشخصية والتخطيط العقاري.

إشعارات مهمة:

١. ليس نصيحة مالية — لا يقدم مشروع إيتيرنا نصائح مالية أو قانونية أو ضريبية. جميع قرارات إدارة الأصول هي مسؤولية مالك الخزنة وحده.

٢. بنية محلية أولاً — يتم تخزين جميع البيانات محلياً على جهازك. لا ينقل مشروع إيتيرنا بياناتك أو يخزنها أو يعالجها على خوادم خارجية خلال السبرنت الأول.

٣. التشفير — بينما نستخدم معايير تشفير عسكرية (AES-256-GCM مع اشتقاق مفتاح Argon2id)، لا يوجد نظام محصن ضد جميع التهديدات.

٤. البيانات البيومترية — تُعالج القوالب البيومترية محلياً ولا تُخزن أبداً. تتواجد فقط في الذاكرة المتطايرة أثناء الجلسات النشطة.

٥. برنامج تجريبي — هذا إصدار تطوير. قد تتغير الميزات والواجهات بدون إشعار مسبق.

٦. معرفة صفرية — يعمل مشروع إيتيرنا على مبدأ المعرفة الصفرية. لا يمكننا استرجاع بياناتك إذا فقدت الوصول.

باستخدام هذا التطبيق، فإنك تقر وتقبل هذه الشروط.

© ٢٠٢٤ مشروع إيتيرنا. جميع الحقوق محفوظة.''',
    );
  }

  static void showPrivacyPolicy(BuildContext context) {
    show(
      context,
      title: 'Privacy Policy',
      titleAr: 'سياسة الخصوصية',
      body: '''PROJECT AETERNA — PRIVACY POLICY

Effective Date: Sprint 1 Release

1. DATA COLLECTION
We collect ZERO personal data externally. All information you enter into Project Aeterna remains exclusively on your device.

2. LOCAL-FIRST PRINCIPLE
• Your vault data is stored in a local SQLite database
• Biometric data exists only in volatile memory (RAM)
• No telemetry, analytics, or tracking is implemented
• No internet connection is required for core functionality

3. ENCRYPTION
• All vault entries are encrypted using AES-256-GCM
• Encryption keys are derived from your biometric data via Argon2id
• Keys never touch persistent storage

4. DATA SHARING
Project Aeterna does NOT share, sell, or transmit any user data to third parties. Period.

5. HEIR ACCESS PROTOCOL
The Ghost Protocol feature enables controlled asset transfer. Heir access keys are generated locally and must be physically shared by the vault owner.

6. DATA DELETION
Uninstalling the application permanently deletes all vault data. This action is irreversible due to our zero-knowledge architecture.

7. UPDATES TO THIS POLICY
We may update this privacy policy as the product evolves. Users will be notified of material changes through in-app notifications.

Contact: sovereignty@aeterna.vault''',
      bodyAr: '''مشروع إيتيرنا — سياسة الخصوصية

تاريخ السريان: إصدار السبرنت الأول

١. جمع البيانات
لا نجمع أي بيانات شخصية خارجياً. جميع المعلومات التي تدخلها تبقى حصرياً على جهازك.

٢. مبدأ المحلية أولاً
• بيانات خزنتك مخزنة في قاعدة بيانات SQLite محلية
• البيانات البيومترية توجد فقط في الذاكرة المتطايرة
• لا يوجد تحليلات أو تتبع
• لا حاجة لاتصال بالإنترنت للوظائف الأساسية

٣. التشفير
• جميع إدخالات الخزنة مشفرة باستخدام AES-256-GCM
• مفاتيح التشفير مشتقة من بياناتك البيومترية عبر Argon2id
• المفاتيح لا تلمس أبداً التخزين الدائم

٤. مشاركة البيانات
مشروع إيتيرنا لا يشارك أو يبيع أو ينقل أي بيانات مستخدم لأطراف ثالثة. نقطة.

٥. بروتوكول وصول الورثة
ميزة بروتوكول الشبح تتيح نقل الأصول بشكل مُحكم. مفاتيح وصول الورثة تُنشأ محلياً ويجب مشاركتها فعلياً.

٦. حذف البيانات
إلغاء تثبيت التطبيق يحذف جميع بيانات الخزنة نهائياً. هذا الإجراء لا رجعة فيه.

للتواصل: sovereignty@aeterna.vault''',
    );
  }

  static void showTermsOfSovereignty(BuildContext context) {
    show(
      context,
      title: 'Terms of Sovereignty',
      titleAr: 'شروط السيادة',
      body: '''TERMS OF SOVEREIGNTY

By activating your Digital Sanctum, you enter into a sovereign agreement with yourself.

ARTICLE I — OWNERSHIP
You are the sole sovereign of your Digital Vault. No entity, corporation, government, or individual may access, modify, or claim ownership of your vault contents without your explicit biometric authorization.

ARTICLE II — RESPONSIBILITY
As sovereign owner, you bear full responsibility for:
• The accuracy of asset declarations within your vault
• The security of your biometric credentials
• The designation and authorization of heir access
• Compliance with your jurisdiction's legal requirements

ARTICLE III — THE GHOST PROTOCOL
The Ghost Protocol is a sovereign dead-man's switch. If your Active Pulse ceases for the configured threshold period, designated heirs will receive their access keys. This is irrevocable once triggered.

ARTICLE IV — ZERO KNOWLEDGE
Project Aeterna operates under a strict zero-knowledge covenant:
• We cannot see your data
• We cannot recover your data
• We cannot interfere with your Ghost Protocol
• We cannot identify you from your vault

ARTICLE V — DIGITAL SOVEREIGNTY
Your vault exists as a self-contained sovereign entity. It does not depend on external servers, cloud services, or third-party infrastructure. Your sovereignty is absolute.

ARTICLE VI — AMENDMENTS
These terms may only be amended with the vault owner's explicit consent through biometric authorization.

DECLARED SOVEREIGN: [Vault Owner]
WITNESS: The Iris of Aeterna''',
      bodyAr: '''شروط السيادة

بتفعيل مقدسك الرقمي، تدخل في اتفاقية سيادية مع نفسك.

المادة الأولى — الملكية
أنت السيد الوحيد لخزنتك الرقمية. لا يجوز لأي كيان أو شركة أو حكومة أو فرد الوصول إلى محتويات خزنتك أو تعديلها بدون إذنك البيومتري الصريح.

المادة الثانية — المسؤولية
بصفتك المالك السيد، تتحمل المسؤولية الكاملة عن:
• دقة إعلانات الأصول في خزنتك
• أمان بيانات اعتمادك البيومترية
• تعيين وتفويض وصول الورثة
• الامتثال للمتطلبات القانونية في ولايتك

المادة الثالثة — بروتوكول الشبح
بروتوكول الشبح هو مفتاح أمان سيادي. إذا توقف نبضك النشط للفترة المهيأة، سيتلقى الورثة المعينون مفاتيح وصولهم. هذا لا رجعة فيه بمجرد تفعيله.

المادة الرابعة — المعرفة الصفرية
يعمل مشروع إيتيرنا تحت ميثاق المعرفة الصفرية الصارم:
• لا يمكننا رؤية بياناتك
• لا يمكننا استرجاع بياناتك
• لا يمكننا التدخل في بروتوكول الشبح
• لا يمكننا التعرف عليك من خزنتك

المادة الخامسة — السيادة الرقمية
خزنتك موجودة ككيان سيادي مستقل. لا تعتمد على خوادم خارجية أو خدمات سحابية. سيادتك مطلقة.

أُعلن سيداً: [مالك الخزنة]
شاهد: عين إيتيرنا''',
    );
  }
}
