import 'dart:async';

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/core/transitions/dissolve_transition.dart';
import 'package:project_aeterna/features/dashboard/data/dashboard_data_service.dart';
import 'package:project_aeterna/features/dashboard/presentation/widgets/active_pulse_header.dart';
import 'package:project_aeterna/features/dashboard/presentation/widgets/asset_card.dart';
import 'package:project_aeterna/features/dashboard/presentation/widgets/sanctum_legal_modal.dart';
import 'package:project_aeterna/features/inheritance/data/oracle_service.dart';
import 'package:project_aeterna/features/inheritance/presentation/claim_portal_screen.dart';
import 'package:project_aeterna/features/inheritance/presentation/heir_registry_screen.dart';
import 'package:project_aeterna/features/profile/presentation/profile_screen.dart';
import 'package:project_aeterna/features/vault/presentation/financial_vault_screen.dart';
import 'package:project_aeterna/features/vault/presentation/placeholder_vault_screen.dart';

/// The Sanctum Dashboard — the heart of Project Aeterna.
///
/// Theme-aware: adapts to Alabaster White (light) and Digital Sanctum (dark).
class SanctumDashboard extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChange;
  final ValueChanged<ThemeMode>? onThemeChange;
  final ThemeMode currentThemeMode;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;
  final String countryCode;
  final String phoneNumber;

  const SanctumDashboard({
    super.key,
    this.onLocaleChange,
    this.onThemeChange,
    this.currentThemeMode = ThemeMode.dark,
    this.onProfileTap,
    this.onLogout,
    this.countryCode = '',
    this.phoneNumber = '',
  });

  @override
  State<SanctumDashboard> createState() => _SanctumDashboardState();
}

class _SanctumDashboardState extends State<SanctumDashboard>
    with SingleTickerProviderStateMixin {
  final DashboardDataService _dataService = DashboardDataService.instance;
  final OracleService _oracleService = OracleService.instance;

  bool _isLoading = true;
  Map<String, int> _assetCounts = {};
  Map<String, dynamic>? _vaultIdentity;
  Map<String, dynamic> _financialData = {};
  Map<String, dynamic> _mediaData = {};
  bool _isArabic = false;

  // Oracle — Live status from DB (no more local override)
  String _currentOracleStatus = 'ACTIVE';

  Timer? _heartbeatTimer;
  late final AnimationController _headerFadeController;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerFade = CurvedAnimation(
      parent: _headerFadeController,
      curve: Curves.easeOut,
    );
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      await _dataService.initialize();
      final counts = await _dataService.getAssetSummary();
      final identity = await _dataService.getVaultIdentity();
      final financial = await _dataService.getFinancialSummary();
      final media = await _dataService.getMediaSummary();
      final oracleStatus = await _oracleService.getVaultStatus();

      if (mounted) {
        setState(() {
          _assetCounts = counts;
          _vaultIdentity = identity;
          _financialData = financial;
          _mediaData = media;
          _currentOracleStatus = oracleStatus ?? 'ACTIVE';
          _isLoading = false;
        });
        _headerFadeController.forward();
        _heartbeatTimer = Timer.periodic(
          const Duration(seconds: 15),
          (_) => _refreshHeartbeat(),
        );
      }
    } catch (e) {
      debugPrint('[SanctumDashboard] Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshHeartbeat() async {
    try {
      await _dataService.recordHeartbeat();
      final identity = await _dataService.getVaultIdentity();
      if (mounted) setState(() => _vaultIdentity = identity);
    } catch (_) {}
  }

   @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _headerFadeController.dispose();
    super.dispose();
  }

  // ─── Oracle — Live DB Identity ──────────────────────────────────
  /// Returns vault identity with real DB status (no local override).
  Map<String, dynamic>? get _liveVaultIdentity {
    if (_vaultIdentity == null) return null;
    final base = Map<String, dynamic>.from(_vaultIdentity!);
    base['status'] = _currentOracleStatus;
    return base;
  }

  // ─── Theme-aware colors ────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
  Color get _textTertiary => _isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
  Color get _glassFill => _isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
  Color get _glassBorder => _isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
  Color get _accentColor => _isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
  Color get _textPrimary => _isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: _bgColor,
      body: _isLoading ? _buildLoadingState() : _buildDashboard(isRtl),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Mounting Vault...',
            style: TextStyle(color: _textTertiary, fontSize: 12, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool isRtl) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ─── Aeterna Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerFade,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AETERNA',
                              style: SanctumTypography.displayMedium.copyWith(
                                letterSpacing: 10, fontSize: 22,
                                color: _accentColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRtl ? 'المقدس الرقمي' : 'Digital Sanctum',
                              style: SanctumTypography.bodySmall.copyWith(
                                letterSpacing: 2.0, color: _textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildSovereignPulseButton(),
                      const SizedBox(width: 6),
                      _buildProfileButton(),
                      const SizedBox(width: 6),
                      _buildThemeToggle(),
                      const SizedBox(width: 6),
                      _buildLanguageToggle(isRtl),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Active Pulse Header ─────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerFade,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ActivePulseHeader(
                  vaultIdentity: _liveVaultIdentity,
                  onPulseTap: _refreshHeartbeat,
                ),
              ),
            ),
          ),

          // ─── Section Title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
              child: Text(
                isRtl ? 'فصول الخزنة' : 'VAULT CHAPTERS',
                style: SanctumTypography.labelMedium.copyWith(
                  letterSpacing: 3.0, color: _textTertiary,
                ),
              ),
            ),
          ),

          // ─── Asset Cards ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: AssetCard(
              category: AssetCategory.financial,
              assetCount: _assetCounts['FINANCIAL'] ?? 0,
              extraData: _financialData,
              onTap: () => _onAssetCardTap('FINANCIAL'),
            ),
          ),
          SliverToBoxAdapter(
            child: AssetCard(
              category: AssetCategory.sentimental,
              assetCount: _assetCounts['SENTIMENTAL'] ?? 0,
              extraData: _mediaData,
              onTap: () => _onAssetCardTap('SENTIMENTAL'),
            ),
          ),
          SliverToBoxAdapter(
            child: AssetCard(
              category: AssetCategory.discrete,
              assetCount: _assetCounts['DISCRETE'] ?? 0,
              onTap: () => _onAssetCardTap('DISCRETE'),
            ),
          ),
          // ─── Ghost Protocol Section ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
              child: Text(
                isRtl ? 'بروتوكول الشبح' : 'GHOST PROTOCOL',
                style: SanctumTypography.labelMedium.copyWith(
                  letterSpacing: 3.0, color: _textTertiary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildGhostProtocolSection(isRtl),
          ),

          // ─── Footer Legal Links ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 40),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _accentColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legal links row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legalLink(
                        isRtl ? 'إخلاء المسؤولية' : 'Disclaimer',
                        () => SanctumLegalModal.showDisclaimer(context),
                      ),
                      _legalDot(),
                      _legalLink(
                        isRtl ? 'الخصوصية' : 'Privacy',
                        () => SanctumLegalModal.showPrivacyPolicy(context),
                      ),
                      _legalDot(),
                      _legalLink(
                        isRtl ? 'شروط السيادة' : 'Terms',
                        () => SanctumLegalModal.showTermsOfSovereignty(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isRtl ? 'مشفر بالكامل • محلي أولاً' : 'Fully Encrypted • Local-First',
                    style: SanctumTypography.bodySmall.copyWith(
                      color: _textTertiary, letterSpacing: 1.5, fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sovereign Pulse Button (Oracle Dev Toggle) ───────────────────
  Widget _buildSovereignPulseButton() {
    final statusColor = _oracleStatusColor(_currentOracleStatus);
    return GestureDetector(
      onTap: _showOracleBottomSheet,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.favorite_outlined,
          color: statusColor,
          size: 18,
        ),
      ),
    );
  }

  Color _oracleStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':   return SanctumColors.statusActive;
      case 'WARNING':  return SanctumColors.statusWarning;
      case 'CRITICAL': return SanctumColors.statusCritical;
      case 'TRIGGERED': return SanctumColors.statusCritical;
      default:         return SanctumColors.statusActive;
    }
  }

  void _showOracleBottomSheet() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OracleSimulationSheet(
        currentStatus: _currentOracleStatus,
        isRtl: isRtl,
        isDark: _isDark,
        onTriggerDecay: () async {
          final newStatus = await _oracleService.triggerDecay();
          if (newStatus != null && mounted) {
            final identity = await _dataService.getVaultIdentity();
            setState(() {
              _currentOracleStatus = newStatus;
              _vaultIdentity = identity;
            });
          }
          return newStatus;
        },
        onReset: () async {
          final newStatus = await _oracleService.resetStatus();
          if (newStatus != null && mounted) {
            final identity = await _dataService.getVaultIdentity();
            setState(() {
              _currentOracleStatus = newStatus;
              _vaultIdentity = identity;
            });
          }
          return newStatus;
        },
      ),
    );
  }

  // ─── Profile Button ────────────────────────────────────────────────
  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          DissolvePageRoute(
            page: ProfileScreen(
              countryCode: widget.countryCode,
              phoneNumber: widget.phoneNumber,
              onLogout: () {
                if (mounted) {
                  widget.onLogout?.call();
                }
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _glassBorder, width: 1),
        ),
        child: Icon(
          Icons.person_outline,
          color: _accentColor,
          size: 18,
        ),
      ),
    );
  }

  // ─── Theme Toggle (Sun/Moon) ──────────────────────────────────────
  Widget _buildThemeToggle() {
    final isDark = widget.currentThemeMode == ThemeMode.dark;
    return GestureDetector(
      onTap: () {
        widget.onThemeChange?.call(isDark ? ThemeMode.light : ThemeMode.dark);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _glassBorder, width: 1),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            key: ValueKey(isDark),
            color: _accentColor,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(bool isRtl) {
    return Container(
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton('EN', !_isArabic, () {
            setState(() => _isArabic = false);
            widget.onLocaleChange?.call(const Locale('en', ''));
          }),
          _langButton('عر', _isArabic, () {
            setState(() => _isArabic = true);
            widget.onLocaleChange?.call(const Locale('ar', ''));
          }),
        ],
      ),
    );
  }

  Widget _langButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? _accentColor : _textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  void _onAssetCardTap(String category) {
    debugPrint('[SanctumDashboard] Tapped: $category chapter');
    switch (category) {
      case 'FINANCIAL':
        Navigator.of(context).push(
          DissolvePageRoute(
            page: FinancialVaultScreen(
              vaultIdentity: _vaultIdentity,
              onPulseTap: _refreshHeartbeat,
            ),
          ),
        );
        break;
      case 'SENTIMENTAL':
        Navigator.of(context).push(
          DissolvePageRoute(
            page: PlaceholderVaultScreen(
              title: 'SENTIMENTAL LEGACY',
              titleAr: 'الإرث العاطفي',
              subtitle: 'Eternal Memories',
              subtitleAr: 'ذكريات خالدة',
              icon: Icons.favorite_outline,
              accentColor: SanctumColors.assetSentimental,
              vaultIdentity: _vaultIdentity,
            ),
          ),
        );
        break;
      case 'DISCRETE':
        Navigator.of(context).push(
          DissolvePageRoute(
            page: PlaceholderVaultScreen(
              title: 'DISCRETE ASSETS',
              titleAr: 'الأصول السرية',
              subtitle: 'Classified Credentials',
              subtitleAr: 'بيانات سرية',
              icon: Icons.lock_outline,
              accentColor: SanctumColors.assetDiscrete,
              vaultIdentity: _vaultIdentity,
            ),
          ),
        );
        break;
    }
  }

  // ─── Ghost Protocol Section ─────────────────────────────────────────
  Widget _buildGhostProtocolSection(bool isRtl) {
    final goldColor = const Color(0xFFD4AF37);
    final oracleColor = _oracleStatusColor(_currentOracleStatus);
    final isCriticalOrTriggered =
        _currentOracleStatus == 'CRITICAL' || _currentOracleStatus == 'TRIGGERED';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ─── Heir Registry ───────────────────────────────────────
          _ghostTile(
            icon: Icons.person_add_outlined,
            label: isRtl ? 'سجل الوريث' : 'Heir Registry',
            subtitle: isRtl ? 'أضف مستفيداً' : 'Add beneficiary',
            color: goldColor,
            onTap: () => Navigator.of(context).push(
              DissolvePageRoute(page: const HeirRegistryScreen()),
            ),
          ),
          const SizedBox(height: 8),

          // ─── Oracle Status (Live from DB) ───────────────────────
          _ghostTile(
            icon: Icons.favorite_outlined,
            label: isRtl ? 'نبض السيادة' : 'Sovereign Pulse',
            subtitle: _currentOracleStatus,
            color: oracleColor,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: oracleColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRtl ? 'تحكم' : 'Control',
                style: TextStyle(
                  color: oracleColor,
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            onTap: _showOracleBottomSheet,
          ),
          const SizedBox(height: 8),

          // ─── Claim Portal ───────────────────────────────────────
          _ghostTile(
            icon: Icons.lock_open_outlined,
            label: isRtl ? 'بوابة الإرث' : 'Claim Portal',
            subtitle: isCriticalOrTriggered
                ? (isRtl ? 'جاهز للاستلام' : 'Ready to claim')
                : (isRtl ? 'يتطلب مرحلة حرجة' : 'Requires CRITICAL stage'),
            color: isCriticalOrTriggered ? SanctumColors.statusCritical : _textTertiary,
            onTap: isCriticalOrTriggered
                ? () => Navigator.of(context).push(
                    DissolvePageRoute(page: const ClaimPortalScreen()),
                  )
                : null,
            disabled: !isCriticalOrTriggered,
          ),
        ],
      ),
    );
  }

  Widget _ghostTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled
                ? _glassBorder
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: disabled ? 0.05 : 0.1),
              ),
              child: Icon(
                icon,
                color: disabled ? _textTertiary.withValues(alpha: 0.4) : color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SanctumTypography.bodyMedium.copyWith(
                      color: disabled ? _textTertiary : _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: SanctumTypography.bodySmall.copyWith(
                      color: disabled ? _textTertiary.withValues(alpha: 0.5) : _textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && !disabled)
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Legal Link Helpers ────────────────────────────────────────────
  Widget _legalLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: SanctumTypography.bodySmall.copyWith(
            color: _accentColor.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 0.5,
            decoration: TextDecoration.underline,
            decorationColor: _accentColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _legalDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3, height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _textTertiary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Oracle Simulation Bottom Sheet — Dev-mode decay control panel.
///
/// Provides Trigger Decay and Reset buttons that write to the real DB
/// via OracleService, then update the parent dashboard state.
class _OracleSimulationSheet extends StatefulWidget {
  final String currentStatus;
  final bool isRtl;
  final bool isDark;
  final Future<String?> Function() onTriggerDecay;
  final Future<String?> Function() onReset;

  const _OracleSimulationSheet({
    required this.currentStatus,
    required this.isRtl,
    required this.isDark,
    required this.onTriggerDecay,
    required this.onReset,
  });

  @override
  State<_OracleSimulationSheet> createState() => _OracleSimulationSheetState();
}

class _OracleSimulationSheetState extends State<_OracleSimulationSheet> {
  late String _status;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':    return SanctumColors.statusActive;
      case 'WARNING':   return SanctumColors.statusWarning;
      case 'CRITICAL':  return SanctumColors.statusCritical;
      case 'TRIGGERED': return SanctumColors.statusCritical;
      default:          return SanctumColors.statusActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(_status);
    final glassFill = widget.isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = widget.isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
    final textPrimary = widget.isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = widget.isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final bgColor = widget.isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F2EC);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: glassBorder),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                children: [
                  Icon(Icons.science_outlined, color: color, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    widget.isRtl ? 'محاكاة الأوراكل' : 'ORACLE SIMULATION',
                    style: SanctumTypography.labelMedium.copyWith(
                      color: color,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.isRtl
                    ? 'وضع المطور — تحكم في انحلال النبض'
                    : 'Developer Mode — Control vitality decay',
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary, fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: glassFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _status,
                      style: SanctumTypography.labelMedium.copyWith(
                        color: textPrimary,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Decay chain visualization
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chainDot('ACTIVE', SanctumColors.statusActive),
                    _chainArrow(),
                    _chainDot('WARNING', SanctumColors.statusWarning),
                    _chainArrow(),
                    _chainDot('CRITICAL', SanctumColors.statusCritical),
                    _chainArrow(),
                    _chainDot('TRIGGERED', SanctumColors.statusCritical),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  // Trigger Decay
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleTriggerDecay,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.trending_down, size: 18),
                        label: Text(
                          widget.isRtl ? 'انحلال' : 'DECAY',
                          style: SanctumTypography.buttonText.copyWith(
                            letterSpacing: 2.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reset
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _handleReset,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(
                          widget.isRtl ? 'إعادة' : 'RESET',
                          style: SanctumTypography.buttonText.copyWith(
                            letterSpacing: 2.0,
                            color: SanctumColors.statusActive,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SanctumColors.statusActive,
                          side: BorderSide(
                            color: SanctumColors.statusActive.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chainDot(String label, Color dotColor) {
    final isActive = _status == label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 14 : 8,
          height: isActive ? 14 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? dotColor : dotColor.withValues(alpha: 0.25),
            boxShadow: isActive
                ? [BoxShadow(color: dotColor.withValues(alpha: 0.5), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.substring(0, 3),
          style: TextStyle(
            fontSize: 7,
            color: isActive ? dotColor : dotColor.withValues(alpha: 0.4),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _chainArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
      child: Icon(
        Icons.chevron_right,
        size: 12,
        color: Colors.white.withValues(alpha: 0.15),
      ),
    );
  }

  Future<void> _handleTriggerDecay() async {
    setState(() => _isProcessing = true);
    final newStatus = await widget.onTriggerDecay();
    if (mounted) {
      setState(() {
        if (newStatus != null) _status = newStatus;
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleReset() async {
    setState(() => _isProcessing = true);
    final newStatus = await widget.onReset();
    if (mounted) {
      setState(() {
        if (newStatus != null) _status = newStatus;
        _isProcessing = false;
      });
    }
  }
}
