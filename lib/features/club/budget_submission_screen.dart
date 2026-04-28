import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/router/app_router.dart';
import '../../models/budget_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'shared_widgets.dart';

class BudgetSubmissionScreen extends ConsumerStatefulWidget {
  final String eventId;
  final BudgetModel? existingBudget;
  const BudgetSubmissionScreen({super.key, required this.eventId, this.existingBudget});

  @override
  ConsumerState<BudgetSubmissionScreen> createState() => _BudgetSubmissionScreenState();
}

class _BudgetSubmissionScreenState extends ConsumerState<BudgetSubmissionScreen> {
  late final TextEditingController _totalController;
  late final TextEditingController _summaryController;

  bool _loading = false;
  String? _error;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  int? _selectedFileSize;

  bool get isResubmitMode =>
      widget.existingBudget != null && widget.existingBudget!.status == 'changes_requested';

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(text: widget.existingBudget?.totalRequested.toString() ?? '');
    _summaryController = TextEditingController(text: widget.existingBudget?.summaryNote ?? '');
    _selectedFileName = widget.existingBudget?.fileName;
    _selectedFileSize = widget.existingBudget?.fileSizeBytes;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      setState(() { _error = 'Could not read selected file.'; });
      return;
    }
    setState(() {
      _selectedFileName = file.name;
      _selectedFileBytes = file.bytes;
      _selectedFileSize = file.size;
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final totalRequested = double.parse(_totalController.text.trim());
      String? storagePath = widget.existingBudget?.storagePath;
      String? fileName = widget.existingBudget?.fileName;
      int? fileSizeBytes = widget.existingBudget?.fileSizeBytes;

      if (_selectedFileBytes != null && _selectedFileName != null) {
        final uploadResult = await ref.read(storageServiceProvider).uploadBudgetFile(
          eventId: widget.eventId,
          fileName: _selectedFileName!,
          bytes: _selectedFileBytes!,
        );
        storagePath = uploadResult['storage_path'] as String?;
        fileName = uploadResult['file_name'] as String?;
        fileSizeBytes = uploadResult['file_size_bytes'] as int?;
      }

      if (isResubmitMode) {
        await ref.read(eventServiceProvider).resubmitBudget(
          budgetId: widget.existingBudget!.id,
          eventId: widget.eventId,
          totalRequested: totalRequested,
          summaryNote: _summaryController.text.trim(),
          fileName: fileName,
          storagePath: storagePath,
          fileSizeBytes: fileSizeBytes,
        );
      } else {
        await ref.read(eventServiceProvider).submitBudget(
          eventId: widget.eventId,
          totalRequested: totalRequested,
          summaryNote: _summaryController.text.trim(),
          fileName: fileName,
          storagePath: storagePath,
          fileSizeBytes: fileSizeBytes,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isResubmitMode ? 'Resubmit Budget' : 'Submit Budget',
      currentRoute: AppRoutes.eventBudget,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.close, size: 20, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isResubmitMode) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Changes were requested. Please update and resubmit.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SectionLabel(label: 'Budget Details'),
            const SizedBox(height: 12),
            FormCard(
              children: [
                FieldGroup(
                  label: 'Total Requested Amount (₹)',
                  child: StyledTextField(
                    controller: _totalController,
                    hint: 'e.g. 25000',
                    icon: Icons.currency_rupee_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const FieldDivider(),
                FieldGroup(
                  label: 'Budget Note / Justification',
                  child: StyledTextField(
                    controller: _summaryController,
                    hint: 'Explain the budget breakdown...',
                    icon: Icons.notes_outlined,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionLabel(label: 'Supporting Document'),
            const SizedBox(height: 12),
            FileUploadCard(
              fileName: _selectedFileName,
              fileSize: _selectedFileSize != null ? _formatBytes(_selectedFileSize!) : null,
              onTap: _pickFile,
              buttonLabel: isResubmitMode ? 'Replace File' : 'Upload File',
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        isResubmitMode ? 'Resubmit Budget' : 'Submit Budget',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}