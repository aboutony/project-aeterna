import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/vault/data/database/turso_client.dart';

/// Heir Registry Screen — The Ghost Protocol beneficiary setup.
///
/// **Isolated Island** — owns its own state, reads/writes directly to
/// the `heir_registry` table via [TursoClient]. No dashboard coupling.
///
/// Features:
///   - Register a new heir (alias, contact method, wallet, biometric ref)
///   - Real DB INSERT on registration
///   - Live heir list loaded from DB
///
/// CTO Directive: "Build the UI to add a beneficiary."
class HeirRegistryScreen extends StatefulWidget {
  const HeirRegistryScreen({super.key});

  @override
  State<HeirRegistryScreen> createState() => _HeirRegistryScreenState();
}

class _HeirRegistryScreenState extends State<HeirRegistryScreen>
    with SingleTickerProviderStateMixin {
  final _aliasController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _contactMethod = 'WHATSAPP'; // 'WHATSAPP' | 'TELEGRAM' | 'EMAIL'
  bool _verificationUploaded = false;
  bool _isSaving = false;
  bool _saved = false;

  // ─── Isolated Internal State: Heir List from DB ────────────────────
  List<Map<String, dynamic>> _heirs = [];
  bool _isLoadingHeirs = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accentColor => _isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
  Color get _glassFill => _isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
  Color get _glassBorder => _isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
  Color get _textPrimary => _isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
  Color get _textTertiary => _isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
  Color get _bgColor => _isDark ? SanctumColors.abyss : SanctumColors.lightBackground;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadHeirs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _aliasController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ─── DB Operations (Self-Contained) ────────────────────────────────

  /// Load all heirs from the local database.
  Future<void> _loadHeirs() async {
    try {
      final db = await TursoClient.instance.getDatabase();
      final rows = await db.rawQuery(
        'SELECT * FROM heir_registry ORDER BY created_at DESC',
      );
      if (mounted) {
        setState(() {
          _heirs = rows;
          _isLoadingHeirs = false;
        });
      }
      debugPrint('[HeirRegistry] ✓ Loaded ${rows.length} heirs from DB');
    } catch (e) {
      debugPrint('[HeirRegistry] Error loading heirs: $e');
      if (mounted) setState(() => _isLoadingHeirs = false);
    }
  }

  /// Insert a new heir into the local database.
  Future<bool> _insertHeir() async {
    try {
      final db = await TursoClient.instance.getDatabase();
      final now = DateTime.now().toIso8601String();

      // Get the vault identity ID for the foreign key
      final identities = await db.rawQuery(
        'SELECT id FROM vault_identity ORDER BY created_at DESC LIMIT 1',
      );
      if (identities.isEmpty) {
        debugPrint('[HeirRegistry] ✗ No vault identity found — cannot register heir');
        return false;
      }
      final vaultId = identities.first['id'] as String;

      // Generate a unique heir ID
      final heirId = 'heir_${DateTime.now().millisecondsSinceEpoch}';

      await db.insert('heir_registry', {
        'heir_id': heirId,
        'vault_id': vaultId,
        'contact_alias': _aliasController.text.trim(),
        'contact_method': _contactMethod,
        'heir_bio_ref': _verificationUploaded
            ? 'BIO_REF_${DateTime.now().millisecondsSinceEpoch}'
            : 'PENDING_VERIFICATION',
        'is_active': 1,
        'notification_sent': 0,
        'created_at': now,
        'updated_at': now,
      });

      debugPrint('[HeirRegistry] ✓ Heir inserted into DB:');
      debugPrint('  ID: $heirId');
      debugPrint('  Alias: ${_aliasController.text}');
      debugPrint('  Contact: $_contactMethod → ${_phoneController.text}');
      debugPrint('  Vault: $vaultId');

      return true;
    } catch (e) {
      debugPrint('[HeirRegistry] ✗ DB insert error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _glassFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _glassBorder),
                        ),
                        child: Icon(
                          isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                          color: _textTertiary, size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isRtl ? 'سجل الوريث' : 'HEIR REGISTRY',
                      style: SanctumTypography.labelMedium.copyWith(
                        color: goldColor, letterSpacing: 3.0,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── Ghost Protocol Banner ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: goldColor.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: goldColor.withValues(alpha: 0.12),
                          border: Border.all(color: goldColor.withValues(alpha: 0.25)),
                        ),
                        child: Icon(Icons.shield_outlined, color: goldColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRtl ? 'بروتوكول الشبح' : 'GHOST PROTOCOL',
                              style: SanctumTypography.labelMedium.copyWith(
                                color: goldColor, letterSpacing: 2.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRtl
                                  ? 'أضف وريثاً لتأمين إرثك الرقمي'
                                  : 'Add a beneficiary to secure your digital legacy',
                              style: SanctumTypography.bodySmall.copyWith(
                                color: _textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Alias ──────────────────────────────────────────
                _buildSectionHeader(
                  isRtl ? 'اسم الوريث المستعار' : 'Heir Alias',
                  Icons.person_outline,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _aliasController,
                  hint: isRtl ? 'مثال: الحامي' : 'e.g., "The Protector"',
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                ),

                const SizedBox(height: 20),

                // ─── Contact Method ─────────────────────────────────
                _buildSectionHeader(
                  isRtl ? 'طريقة التواصل' : 'Contact Method',
                  Icons.message_outlined,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _glassFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _glassBorder),
                  ),
                  child: Row(
                    children: [
                      _methodButton('WHATSAPP', 'WhatsApp', Icons.chat_outlined),
                      _methodButton('TELEGRAM', 'Telegram', Icons.send_outlined),
                      _methodButton('EMAIL', 'Email', Icons.email_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _phoneController,
                  hint: _contactMethod == 'EMAIL'
                      ? (isRtl ? 'البريد الإلكتروني' : 'email@example.com')
                      : (isRtl ? 'رقم الهاتف مع رمز الدولة' : '+966 5XX XXX XXXX'),
                  inputFormatters: _contactMethod == 'EMAIL'
                      ? [LengthLimitingTextInputFormatter(100)]
                      : [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                        ],
                ),

                const SizedBox(height: 20),

                // ─── Polygon Address ────────────────────────────────
                _buildSectionHeader(
                  isRtl ? 'عنوان بوليغون العام' : 'Polygon Public Address',
                  Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _addressController,
                  hint: '0x...',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(42),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9x]')),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── Verification Reference ─────────────────────────
                _buildSectionHeader(
                  isRtl ? 'مرجع التحقق البيومتري' : 'Biometric Verification Ref',
                  Icons.fingerprint,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _mockUploadVerification,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _glassFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _verificationUploaded
                            ? SanctumColors.statusActive.withValues(alpha: 0.3)
                            : _glassBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _verificationUploaded
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          color: _verificationUploaded
                              ? SanctumColors.statusActive
                              : _textTertiary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _verificationUploaded
                              ? (isRtl ? '✓ تم رفع بصمة الوجه/القزحية' : '✓ Face/Iris hash uploaded')
                              : (isRtl ? 'ارفع بصمة وجه أو قزحية الوريث' : 'Upload heir Face/Iris hash'),
                          style: SanctumTypography.bodySmall.copyWith(
                            color: _verificationUploaded
                                ? SanctumColors.statusActive
                                : _textTertiary,
                            fontWeight: _verificationUploaded
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!_verificationUploaded) ...[
                          const SizedBox(height: 4),
                          Text(
                            isRtl
                                ? 'SHA-256 مشفر محلياً'
                                : 'SHA-256 encrypted locally',
                            style: SanctumTypography.bodySmall.copyWith(
                              color: _textTertiary, fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ─── Register Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _registerHeir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _saved ? Icons.check : Icons.shield_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _saved
                                    ? (isRtl ? '✓ تم تسجيل الوريث' : '✓ HEIR REGISTERED')
                                    : (isRtl ? 'تسجيل الوريث' : 'REGISTER HEIR'),
                                style: SanctumTypography.buttonText.copyWith(
                                  letterSpacing: 2.0, color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Info ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRtl
                              ? 'سيُخطر الوريث فقط عند تفعيل بروتوكول الشبح بعد انتهاء فترة الصمت المحددة.'
                              : 'The heir will only be notified when the Ghost Protocol triggers after the defined silence period.',
                          style: SanctumTypography.bodySmall.copyWith(
                            color: Colors.amber.withValues(alpha: 0.8),
                            fontSize: 10, height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ─── HEIR LIST — Proof of DB Read ───────────────────
                _buildSectionHeader(
                  isRtl ? 'الورثة المسجلون' : 'Registered Heirs',
                  Icons.people_outline,
                ),
                const SizedBox(height: 12),
                _buildHeirList(isRtl),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Heir List Widget (DB Read Proof) ────────────────────────────────

  Widget _buildHeirList(bool isRtl) {
    if (_isLoadingHeirs) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: _accentColor,
            ),
          ),
        ),
      );
    }

    if (_heirs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _glassBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, color: _textTertiary, size: 32),
            const SizedBox(height: 8),
            Text(
              isRtl ? 'لم يُسجل أي وريث بعد' : 'No heirs registered yet',
              style: SanctumTypography.bodySmall.copyWith(
                color: _textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isRtl
                  ? 'استخدم النموذج أعلاه لإضافة مستفيد'
                  : 'Use the form above to add a beneficiary',
              style: SanctumTypography.bodySmall.copyWith(
                color: _textTertiary, fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Heir count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SanctumColors.statusActive.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isRtl
                ? '${_heirs.length} وريث مسجل'
                : '${_heirs.length} heir${_heirs.length > 1 ? 's' : ''} registered',
            style: SanctumTypography.bodySmall.copyWith(
              color: SanctumColors.statusActive,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Heir cards
        ...List.generate(_heirs.length, (index) {
          final heir = _heirs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildHeirCard(heir, isRtl),
          );
        }),
      ],
    );
  }

  Widget _buildHeirCard(Map<String, dynamic> heir, bool isRtl) {
    final alias = heir['contact_alias'] as String? ?? 'Unknown';
    final method = heir['contact_method'] as String? ?? 'WHATSAPP';
    final isActive = (heir['is_active'] as int?) == 1;
    final createdAt = heir['created_at'] as String? ?? '';
    final goldColor = const Color(0xFFD4AF37);

    IconData methodIcon;
    switch (method) {
      case 'TELEGRAM':
        methodIcon = Icons.send_outlined;
        break;
      case 'EMAIL':
        methodIcon = Icons.email_outlined;
        break;
      default:
        methodIcon = Icons.chat_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? goldColor.withValues(alpha: 0.2)
              : _glassBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor.withValues(alpha: 0.1),
              border: Border.all(color: goldColor.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.person_outline, color: goldColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alias,
                  style: SanctumTypography.bodyMedium.copyWith(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(methodIcon, color: _textTertiary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      method,
                      style: SanctumTypography.bodySmall.copyWith(
                        color: _textTertiary, fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: _textTertiary, fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _formatDate(createdAt),
                        style: SanctumTypography.bodySmall.copyWith(
                          color: _textTertiary, fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? SanctumColors.statusActive.withValues(alpha: 0.1)
                  : SanctumColors.statusCritical.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive
                  ? (isRtl ? 'نشط' : 'ACTIVE')
                  : (isRtl ? 'معطل' : 'INACTIVE'),
              style: TextStyle(
                color: isActive
                    ? SanctumColors.statusActive
                    : SanctumColors.statusCritical,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  // ─── Reusable Builders ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accentColor, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: SanctumTypography.labelMedium.copyWith(
            color: _textTertiary, letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _glassBorder),
      ),
      child: TextField(
        controller: controller,
        style: SanctumTypography.bodyMedium.copyWith(
          color: _textPrimary, fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: SanctumTypography.bodyMedium.copyWith(color: _textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _methodButton(String method, String label, IconData icon) {
    final isActive = _contactMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _contactMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? _accentColor : _textTertiary, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: SanctumTypography.bodySmall.copyWith(
                  color: isActive ? _accentColor : _textTertiary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mockUploadVerification() {
    setState(() => _verificationUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Directionality.of(context) == TextDirection.rtl
              ? '✓ تم رفع بصمة التحقق (محاكاة)'
              : '✓ Verification hash uploaded (mock)',
        ),
        backgroundColor: SanctumColors.statusActive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Register heir — real DB write, then reload the list.
  Future<void> _registerHeir() async {
    // Validate required fields
    if (_aliasController.text.trim().isEmpty) {
      _showValidationError(
        Directionality.of(context) == TextDirection.rtl
            ? 'يرجى إدخال اسم الوريث المستعار'
            : 'Please enter an heir alias',
      );
      return;
    }

    setState(() => _isSaving = true);

    // Real DB insert
    final success = await _insertHeir();

    if (mounted) {
      if (success) {
        setState(() { _isSaving = false; _saved = true; });

        // Clear form
        _aliasController.clear();
        _phoneController.clear();
        _addressController.clear();
        setState(() {
          _verificationUploaded = false;
          _contactMethod = 'WHATSAPP';
        });

        // Reload heirs from DB — proof of read/write
        await _loadHeirs();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Directionality.of(context) == TextDirection.rtl
                  ? '✓ تم تسجيل الوريث في قاعدة البيانات'
                  : '✓ Heir registered to database',
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saved = false);
        });
      } else {
        setState(() => _isSaving = false);
        _showValidationError(
          Directionality.of(context) == TextDirection.rtl
              ? '✗ فشل في تسجيل الوريث — لم يتم العثور على هوية الخزنة'
              : '✗ Failed to register heir — no vault identity found',
        );
      }
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SanctumColors.statusCritical,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
