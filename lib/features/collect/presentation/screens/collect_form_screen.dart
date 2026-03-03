import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/collect.dart';
import '../providers/collect_provider.dart';
import '../widgets/image_picker_field.dart';

class CollectFormScreen extends ConsumerStatefulWidget {
  const CollectFormScreen({super.key});

  @override
  ConsumerState<CollectFormScreen> createState() => _CollectFormScreenState();
}

class _CollectFormScreenState extends ConsumerState<CollectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers texte
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _tel2Ctrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _immatCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();
  final _assuranceCtrl = TextEditingController();
  final _dateEcheanceCtrl = TextEditingController();

  // Dropdowns
  String? _categorie;
  String _canal = 'normal';
  String _clientAsap = 'NON';

  // Fichiers
  String? _carteGrisePath;
  String? _attestationPath;

  // Géolocalisation
  double? _latitude;
  double? _longitude;
  bool _geoLoading = false;

  static const _categories = [
    'Particulier',
    'Entreprise',
    'Professionnel',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    for (final c in [
      _nomCtrl, _prenomCtrl, _telCtrl, _tel2Ctrl, _obsCtrl,
      _immatCtrl, _lieuCtrl, _assuranceCtrl, _dateEcheanceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Géolocalisation ──────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _geoLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Service de localisation désactivé');

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Localisation : ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _geoLoading = false);
    }
  }

  // ── Image picker ─────────────────────────────────────────────────────────

  Future<void> _pickImage({
    required ImageSource source,
    required void Function(String path) onPicked,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file != null) onPicked(file.path);
  }

  // ── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateEcheanceCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // ── Soumission ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categorie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final data = CollectFormData(
      nomClient: _nomCtrl.text.trim(),
      prenomClient: _prenomCtrl.text.trim(),
      telephone: _telCtrl.text.trim(),
      telephoneSecondaire:
          _tel2Ctrl.text.trim().isEmpty ? null : _tel2Ctrl.text.trim(),
      observation: _obsCtrl.text.trim(),
      categorie: _categorie!,
      canal: _canal,
      clientAsap: _clientAsap,
      immatriculation: _immatCtrl.text.trim(),
      lieuProspection: _lieuCtrl.text.trim(),
      assuranceActuel: _assuranceCtrl.text.trim(),
      dateEcheance: _dateEcheanceCtrl.text.trim(),
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      carteGrisePath: _carteGrisePath,
      attestationAssurancePath: _attestationPath,
    );

    await ref.read(collectProvider.notifier).submit(data);
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(collectProvider);
    final isLoading = submitState is CollectSubmitLoading;

    ref.listen<CollectSubmitState>(collectProvider, (_, state) {
      if (state is CollectSubmitSuccess) {
        final msg = state.offline
            ? 'Collecte sauvegardée hors ligne. Sera synchronisée dès connexion.'
            : 'Collecte envoyée avec succès !';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor:
                state.offline ? AppColors.warning : AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        ref.read(collectProvider.notifier).reset();
        Navigator.of(context).pop();
      }
      if (state is CollectSubmitError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(collectProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle collecte'),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── SECTION : Informations client ────────────────────────────
            _SectionHeader(title: 'Informations client', icon: Icons.person_outline),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _nomCtrl,
              label: 'Nom du client',
              validator: _required,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _prenomCtrl,
              label: 'Prénom du client',
              validator: _required,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _telCtrl,
              label: 'Téléphone',
              validator: _required,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _tel2Ctrl,
              label: 'Téléphone secondaire (optionnel)',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),

            // Catégorie
            DropdownButtonFormField<String>(
              value: _categorie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categorie = v),
              validator: (v) => v == null ? 'Champ requis' : null,
            ),
            const SizedBox(height: 14),

            // Canal
            DropdownButtonFormField<String>(
              value: _canal,
              decoration: const InputDecoration(labelText: 'Canal'),
              items: const [
                DropdownMenuItem(value: 'campagne', child: Text('Campagne')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
              ],
              onChanged: (v) => setState(() => _canal = v!),
            ),
            const SizedBox(height: 14),

            // Client ASAP
            DropdownButtonFormField<String>(
              value: _clientAsap,
              decoration: const InputDecoration(labelText: 'Client ASAP'),
              items: const [
                DropdownMenuItem(value: 'OUI', child: Text('OUI')),
                DropdownMenuItem(value: 'NON', child: Text('NON')),
              ],
              onChanged: (v) => setState(() => _clientAsap = v!),
            ),
            const SizedBox(height: 14),

            _buildTextField(
              controller: _obsCtrl,
              label: 'Observation',
              validator: _required,
              maxLines: 3,
            ),

            const SizedBox(height: 28),

            // ── SECTION : Véhicule & Assurance ───────────────────────────
            _SectionHeader(
                title: 'Véhicule & Assurance',
                icon: Icons.directions_car_outlined),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _lieuCtrl,
              label: 'Lieu de prospection',
              validator: _required,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _immatCtrl,
              label: "Immatriculation du véhicule",
              validator: _required,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _assuranceCtrl,
              label: 'Assurance actuelle',
              validator: _required,
            ),
            const SizedBox(height: 14),

            // Date échéance
            TextFormField(
              controller: _dateEcheanceCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: "Date d'échéance de l'assurance",
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
              ),
              validator: _required,
            ),

            const SizedBox(height: 28),

            // ── SECTION : Documents ──────────────────────────────────────
            _SectionHeader(
                title: 'Documents', icon: Icons.file_copy_outlined),
            const SizedBox(height: 12),

            ImagePickerField(
              label: 'Carte grise',
              imagePath: _carteGrisePath,
              onCamera: () => _pickImage(
                source: ImageSource.camera,
                onPicked: (p) => setState(() => _carteGrisePath = p),
              ),
              onGallery: () => _pickImage(
                source: ImageSource.gallery,
                onPicked: (p) => setState(() => _carteGrisePath = p),
              ),
              onRemove: () => setState(() => _carteGrisePath = null),
            ),
            const SizedBox(height: 20),

            ImagePickerField(
              label: "Attestation d'assurance",
              imagePath: _attestationPath,
              onCamera: () => _pickImage(
                source: ImageSource.camera,
                onPicked: (p) => setState(() => _attestationPath = p),
              ),
              onGallery: () => _pickImage(
                source: ImageSource.gallery,
                onPicked: (p) => setState(() => _attestationPath = p),
              ),
              onRemove: () => setState(() => _attestationPath = null),
            ),

            const SizedBox(height: 28),

            // ── SECTION : Localisation ───────────────────────────────────
            _SectionHeader(
                title: 'Localisation', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _latitude != null
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_not_fixed_rounded,
                    color: _latitude != null
                        ? AppColors.success
                        : AppColors.textHint,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _geoLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blue,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Localisation en cours...'),
                            ],
                          )
                        : Text(
                            _latitude != null
                                ? 'Lat: ${_latitude!.toStringAsFixed(6)}'
                                    '  Lng: ${_longitude!.toStringAsFixed(6)}'
                                : 'Position non disponible',
                            style: TextStyle(
                              color: _latitude != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  TextButton.icon(
                    onPressed: _geoLoading ? null : _fetchLocation,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Actualiser'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Bouton soumission ────────────────────────────────────────
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Envoyer la collecte'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
