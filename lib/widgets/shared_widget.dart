import 'package:flutter/material.dart';

// ── Section label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

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

// ── White form card wrapper ───────────────────────────────────────────────────
class FormCard extends StatelessWidget {
  final List<Widget> children;
  const FormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

// ── Thin divider inside form cards ───────────────────────────────────────────
class FieldDivider extends StatelessWidget {
  const FieldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100);
  }
}

// ── Label + field group ───────────────────────────────────────────────────────
class FieldGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const FieldGroup({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ── Styled text field ─────────────────────────────────────────────────────────
class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const StyledTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F36)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: Icon(icon, size: 17, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
        ),
      ),
    );
  }
}

// ── File upload card ──────────────────────────────────────────────────────────
class FileUploadCard extends StatelessWidget {
  final String? fileName;
  final String? fileSize;
  final VoidCallback onTap;
  final String buttonLabel;
  final String? label;
  final bool isRequired;

  const FileUploadCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.onTap,
    required this.buttonLabel,
    this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? const Color(0xFF3B5BDB).withOpacity(0.3) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: hasFile ? const Color(0xFFEEF2FF) : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasFile ? Icons.insert_drive_file_outlined : Icons.upload_file_outlined,
              size: 19,
              color: hasFile ? const Color(0xFF3B5BDB) : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Row(
                    children: [
                      Text(label!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                      if (isRequired)
                        const Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                    ],
                  ),
                const SizedBox(height: 2),
                Text(
                  hasFile ? fileName! : 'No file selected',
                  style: TextStyle(fontSize: 12, color: hasFile ? const Color(0xFF3B5BDB) : Colors.grey.shade400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null)
                  Text(fileSize!, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3B5BDB),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: const Color(0xFFEEF2FF),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
        ],
      ),
    );
  }
}

// ── Checklist card ────────────────────────────────────────────────────────────
class ChecklistCard extends StatelessWidget {
  final List<Widget> children;
  const ChecklistCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isCheckbox;

  const ChecklistItem({
    super.key,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isCheckbox,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isCheckbox)
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF3B5BDB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF3B5BDB),
            ),
        ],
      ),
    );
  }
}