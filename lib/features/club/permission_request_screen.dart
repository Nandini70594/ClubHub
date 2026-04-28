import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../models/event_model.dart';
import '../../models/permission_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF3B5BDB);
const _kPrimaryBg  = Color(0xFFEEF2FF);
const _kSurface    = Colors.white;
const _kBackground = Color(0xFFF4F6FB);
const _kTextDark   = Color(0xFF1A1F36);
const _kTextMid    = Color(0xFF6B7280);
const _kBorder     = Color(0xFFE5E7EB);
const _kRadius     = 12.0;
// ─────────────────────────────────────────────────────────────────────────────

class PermissionRequestScreen extends ConsumerStatefulWidget {
  final String eventId;
  final PermissionRequestModel? resubmittingRequest;

  const PermissionRequestScreen({
    super.key,
    required this.eventId,
    this.resubmittingRequest,
  });

  @override
  ConsumerState<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState
    extends ConsumerState<PermissionRequestScreen> {
  final _purposeController = TextEditingController();

  final List<String> _resourceTypes = const [
    'CLASSROOM',
    'LABORATORY',
    'AUDITORIUM',
    'CONFERENCE_ROOM',
    'DIGITAL_SCREEN',
    'OTHER',
  ];

  final Map<String, bool> _selected = {};
  final Map<String, TextEditingController> _detailControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};
  final Map<String, Uint8List?> _fileBytes = {};
  final Map<String, String?> _fileNames = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final type in _resourceTypes) {
      _selected[type] = false;
      _detailControllers[type] = TextEditingController();
      _remarksControllers[type] = TextEditingController();
      _fileBytes[type] = null;
      _fileNames[type] = null;
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    for (final c in _detailControllers.values) c.dispose();
    for (final c in _remarksControllers.values) c.dispose();
    super.dispose();
  }

  String _label(String type) {
    switch (type) {
      case 'CLASSROOM':        return 'Classroom';
      case 'LABORATORY':       return 'Laboratory';
      case 'AUDITORIUM':       return 'Auditorium / Seminar Room';
      case 'CONFERENCE_ROOM':  return 'Conference Room';
      case 'DIGITAL_SCREEN':   return 'Digital Screen';
      case 'OTHER':            return 'Other';
      default:                 return type;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'CLASSROOM':        return Icons.door_front_door_outlined;
      case 'LABORATORY':       return Icons.science_outlined;
      case 'AUDITORIUM':       return Icons.theater_comedy_outlined;
      case 'CONFERENCE_ROOM':  return Icons.meeting_room_outlined;
      case 'DIGITAL_SCREEN':   return Icons.monitor_outlined;
      case 'OTHER':            return Icons.category_outlined;
      default:                 return Icons.room_outlined;
    }
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to read file')),
      );
      return;
    }
    setState(() {
      _fileBytes[type] = file.bytes;
      _fileNames[type] = file.name;
    });
  }

  Future<void> _submit() async {
    final selectedTypes =
        _resourceTypes.where((t) => _selected[t] == true).toList();

    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one resource.')),
      );
      return;
    }
    if (_purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter purpose of resource usage.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final storageService    = ref.read(storageServiceProvider);
      final permissionService = ref.read(permissionServiceProvider);
      final items = <Map<String, dynamic>>[];

      for (final type in selectedTypes) {
        String? documentUrl;
        String? documentName;

        if (_fileBytes[type] != null && _fileNames[type] != null) {
          final uploaded = await storageService.uploadPermissionFile(
            eventId:      widget.eventId,
            resourceType: type,
            fileName:     _fileNames[type]!,
            bytes:        _fileBytes[type]!,
          );
          documentUrl  = uploaded['storage_path'] as String?;
          documentName = uploaded['file_name']    as String?;
        }

        items.add({
          'resource_type':   type,
          'resource_detail': _detailControllers[type]!.text.trim().isEmpty
              ? null : _detailControllers[type]!.text.trim(),
          'remarks':         _remarksControllers[type]!.text.trim().isEmpty
              ? null : _remarksControllers[type]!.text.trim(),
          'document_url':    documentUrl,
          'document_name':   documentName,
        });
      }

      if (widget.resubmittingRequest == null) {
        await permissionService.createPermissionRequest(
          eventId: widget.eventId,
          purpose: _purposeController.text.trim(),
          items:   items,
        );
      } else {
        await permissionService.resubmitPermissionRequest(
          oldRequestId: widget.resubmittingRequest!.id,
          eventId:      widget.eventId,
          purpose:      _purposeController.text.trim(),
          items:        items,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final eventService = ref.read(eventServiceProvider);
    final isResubmit   = widget.resubmittingRequest != null;

    return AppScaffold(
      title: isResubmit ? 'Resubmit Permission Request' : 'Request Permissions',
      currentRoute: AppRoutes.permRequest,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.close, size: 20, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: FutureBuilder<EventModel>(
        future: eventService.getEventById(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFDC2626))),
            );
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
                // ── Event details card ───────────────────────────────────
                _SectionLabel(label: 'Request Details'),
                const SizedBox(height: 10),
                _SurfaceCard(
                  child: Column(
                    children: [
                      _EventDetailRow(
                        icon: Icons.event_outlined,
                        label: 'Event Title',
                        value: event.title,
                      ),
                      _Divider(),
                      _EventDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Event Date',
                        value: event.eventDate.toString(),
                      ),
                      _Divider(),
                      _EventDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Venue',
                        value: event.venue ?? '-',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Resources ────────────────────────────────────────────
                _SectionLabel(label: 'Resources Required'),
                const SizedBox(height: 10),

                ..._resourceTypes.map((type) => _ResourceTile(
                  type:              type,
                  label:             _label(type),
                  icon:              _iconFor(type),
                  isSelected:        _selected[type]!,
                  detailController:  _detailControllers[type]!,
                  remarksController: _remarksControllers[type]!,
                  fileName:          _fileNames[type],
                  onToggle: (v) => setState(() => _selected[type] = v ?? false),
                  onPickFile: () => _pickFile(type),
                )),

                const SizedBox(height: 22),

                // ── Purpose ──────────────────────────────────────────────
                _SectionLabel(label: 'Purpose of Resource Usage'),
                const SizedBox(height: 10),
                _SurfaceCard(
                  child: TextField(
                    controller: _purposeController,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 13, color: _kTextDark),
                    decoration: InputDecoration(
                      hintText: 'Describe the purpose of resource usage…',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Submit button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      disabledBackgroundColor: _kPrimary.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kRadius),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isResubmit
                                ? 'Resubmit Permission Request'
                                : 'Submit Permission Request',
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                            ),
                          ),
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

// ── Resource tile ─────────────────────────────────────────────────────────────
class _ResourceTile extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final TextEditingController detailController;
  final TextEditingController remarksController;
  final String? fileName;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onPickFile;

  const _ResourceTile({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.detailController,
    required this.remarksController,
    required this.fileName,
    required this.onToggle,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header row with checkbox
            InkWell(
              onTap: () => onToggle(!isSelected),
              borderRadius: BorderRadius.circular(_kRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: isSelected ? _kPrimary : _kPrimaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                        size: 17,
                        color: isSelected ? Colors.white : _kPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _kPrimary : _kTextDark,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: onToggle,
                      activeColor: _kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded fields when selected
            if (isSelected) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  children: [
                    _FormField(
                      controller: detailController,
                      label: type == 'OTHER' ? 'Specify resource' : 'Resource details',
                      icon: Icons.info_outline,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: remarksController,
                      label: 'Remarks',
                      icon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    // Document upload row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file_outlined,
                            size: 15, color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName ?? 'No document selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: fileName != null
                                    ? _kTextDark : Colors.grey.shade400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onPickFile,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _kPrimaryBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Browse',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kPrimary,
                                )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SurfaceCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EventDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _kTextDark,
              )),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Colors.grey.shade100);
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: _kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade400),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: _kBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
    );
  }
}