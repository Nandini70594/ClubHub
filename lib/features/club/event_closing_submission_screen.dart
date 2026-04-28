import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/router/app_router.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'shared_widgets.dart';

class EventClosingSubmissionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventClosingSubmissionScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventClosingSubmissionScreen> createState() => _EventClosingSubmissionScreenState();
}

class _EventClosingSubmissionScreenState extends ConsumerState<EventClosingSubmissionScreen> {
  final _approvalNumberController = TextEditingController();
  final _summaryController = TextEditingController();

  bool _googleFormSubmitted = false;
  bool _vendorAuthorized = true;
  bool _isSubmitting = false;

  final List<String> _fileTypes = const ['PHOTO', 'CLOSING_FILE', 'REQUISITION', 'BANK_DETAILS', 'OTHER'];
  final Map<String, Uint8List?> _fileBytes = {};
  final Map<String, String?> _fileNames = {};

  @override
  void initState() {
    super.initState();
    for (final type in _fileTypes) {
      _fileBytes[type] = null;
      _fileNames[type] = null;
    }
  }

  @override
  void dispose() {
    _approvalNumberController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  String _label(String type) {
    switch (type) {
      case 'PHOTO': return 'Event Photos';
      case 'CLOSING_FILE': return 'Final Closing File';
      case 'REQUISITION': return 'Requisition Form';
      case 'BANK_DETAILS': return 'Reimbursement Bank Details';
      case 'OTHER': return 'Other Document';
      default: return type;
    }
  }

  bool _isRequired(String type) => type == 'CLOSING_FILE' || (!_vendorAuthorized && (type == 'REQUISITION' || type == 'BANK_DETAILS'));

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to read file')));
      return;
    }
    setState(() {
      _fileBytes[type] = file.bytes;
      _fileNames[type] = file.name;
    });
  }

  Future<void> _submit() async {
    final approvalNumber = _approvalNumberController.text.trim();
    if (approvalNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter approval number')));
      return;
    }
    if (!_googleFormSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirm Google Form submission')));
      return;
    }
    if (_fileBytes['CLOSING_FILE'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload final closing file')));
      return;
    }
    if (!_vendorAuthorized) {
      if (_fileBytes['REQUISITION'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload requisition form for unauthorized vendor')));
        return;
      }
      if (_fileBytes['BANK_DETAILS'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload reimbursement bank details')));
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final storageService = ref.read(storageServiceProvider);
      final postEventService = ref.read(postEventServiceProvider);
      final files = <Map<String, dynamic>>[];

      for (final type in _fileTypes) {
        if (_vendorAuthorized && (type == 'REQUISITION' || type == 'BANK_DETAILS')) continue;
        if (_fileBytes[type] != null && _fileNames[type] != null) {
          final uploaded = await storageService.uploadClosingFile(
            eventId: widget.eventId,
            fileType: type,
            fileName: _fileNames[type]!,
            bytes: _fileBytes[type]!,
          );
          files.add({'file_type': type, 'file_name': uploaded['file_name'], 'storage_path': uploaded['storage_path']});
        }
      }

      await postEventService.submitClosingReport(
        eventId: widget.eventId,
        approvalNumber: approvalNumber,
        googleFormSubmitted: _googleFormSubmitted,
        vendorAuthorized: _vendorAuthorized,
        summary: _summaryController.text.trim(),
        files: files,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Submit Closing File',
      currentRoute: AppRoutes.eventClosing,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.close, size: 20, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: FutureBuilder<EventModel>(
        future: ref.read(eventServiceProvider).getEventById(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626))));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Event not found'));
          }
          final event = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event details info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.event_outlined, color: Color(0xFF3B5BDB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                            const SizedBox(height: 3),
                            Text('${event.eventDate} • ${event.venue ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionLabel(label: 'Closing Details'),
                const SizedBox(height: 12),
                FormCard(
                  children: [
                    FieldGroup(
                      label: 'Approval Number',
                      child: StyledTextField(
                        controller: _approvalNumberController,
                        hint: 'Enter approval number',
                        icon: Icons.tag_outlined,
                      ),
                    ),
                    const FieldDivider(),
                    FieldGroup(
                      label: 'Closing Summary / Remarks',
                      child: StyledTextField(
                        controller: _summaryController,
                        hint: 'Summarise the event outcome...',
                        icon: Icons.notes_outlined,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionLabel(label: 'Checklist'),
                const SizedBox(height: 12),
                ChecklistCard(
                  children: [
                    ChecklistItem(
                      label: 'Google Form Submitted',
                      subtitle: 'Confirm the Google Form has been submitted',
                      value: _googleFormSubmitted,
                      onChanged: (v) => setState(() => _googleFormSubmitted = v ?? false),
                      isCheckbox: true,
                    ),
                    const FieldDivider(),
                    ChecklistItem(
                      label: 'Vendor Authorized',
                      subtitle: _vendorAuthorized
                          ? 'Requisition and bank details not required'
                          : 'Requisition and bank details required',
                      value: _vendorAuthorized,
                      onChanged: (v) => setState(() => _vendorAuthorized = v ?? true),
                      isCheckbox: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionLabel(label: 'Closing Documents'),
                const SizedBox(height: 12),
                FileUploadCard(
                  fileName: _fileNames['CLOSING_FILE'],
                  fileSize: null,
                  onTap: () => _pickFile('CLOSING_FILE'),
                  buttonLabel: 'Upload',
                  label: _label('CLOSING_FILE'),
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                FileUploadCard(
                  fileName: _fileNames['PHOTO'],
                  fileSize: null,
                  onTap: () => _pickFile('PHOTO'),
                  buttonLabel: 'Upload',
                  label: _label('PHOTO'),
                ),
                if (!_vendorAuthorized) ...[
                  const SizedBox(height: 8),
                  FileUploadCard(
                    fileName: _fileNames['REQUISITION'],
                    fileSize: null,
                    onTap: () => _pickFile('REQUISITION'),
                    buttonLabel: 'Upload',
                    label: _label('REQUISITION'),
                    isRequired: true,
                  ),
                  const SizedBox(height: 8),
                  FileUploadCard(
                    fileName: _fileNames['BANK_DETAILS'],
                    fileSize: null,
                    onTap: () => _pickFile('BANK_DETAILS'),
                    buttonLabel: 'Upload',
                    label: _label('BANK_DETAILS'),
                    isRequired: true,
                  ),
                ],
                const SizedBox(height: 8),
                FileUploadCard(
                  fileName: _fileNames['OTHER'],
                  fileSize: null,
                  onTap: () => _pickFile('OTHER'),
                  buttonLabel: 'Upload',
                  label: _label('OTHER'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit & Close Event', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}