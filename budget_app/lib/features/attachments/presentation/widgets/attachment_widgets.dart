import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/attachments_bloc.dart';
import '../bloc/attachments_event.dart';
import '../bloc/attachments_state.dart';
import '../../domain/entities/attachment.dart';

class AttachmentSection extends StatelessWidget {
  final String transactionId;
  final String transactionType;

  const AttachmentSection({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttachmentsBloc, AttachmentsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16),
                const SizedBox(width: 4),
                const Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate, size: 20),
                  tooltip: 'Add Receipt',
                  onPressed: () => _pickFile(context),
                ),
              ],
            ),
            if (state is AttachmentsLoaded && state.attachments.isNotEmpty)
              ...state.attachments.map((Attachment a) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.receipt_long),
                    title: Text(a.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_formatSize(a.fileSize)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        context.read<AttachmentsBloc>().add(DeleteAttachmentEvent(a.id));
                      },
                    ),
                    onTap: () => _viewAttachment(context, a.filePath),
                  )),
            if (state is AttachmentsLoaded && state.attachments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No receipts attached', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        if (!context.mounted) return;
        context.read<AttachmentsBloc>().add(AddAttachmentEvent(
          transactionId: transactionId,
          transactionType: transactionType,
          filePath: file.path!,
          fileName: file.name,
          fileSize: file.size,
          mimeType: file.extension,
        ));
      }
    }
  }

  void _viewAttachment(BuildContext context, String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: Center(child: Image.file(file)),
      ),
    ));
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
