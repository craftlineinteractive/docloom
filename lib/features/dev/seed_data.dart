import 'package:flutter/material.dart';
import '../../core/ids/id_generator.dart';
import '../../core/storage/document_file_store.dart';
import '../../core/theme/app_colors.dart';
import '../documents/domain/document.dart';
import '../documents/domain/document_repository.dart';
import '../documents/domain/new_page.dart';
import '../folders/domain/folder_repository.dart';
import '../trash/application/trash_service.dart';
import 'seed_image_generator.dart';

class SeedResult {
  const SeedResult({required this.foldersCount, required this.docsCount, required this.trashedCount});
  final int foldersCount;
  final int docsCount;
  final int trashedCount;
}

Future<Document> _seedDoc({
  required DocumentRepository docRepo,
  required DocumentFileStore fileStore,
  required IdGenerator idGen,
  required String name,
  required int pageCount,
  String? folderId,
  Color headerColor = AppColors.primary,
}) async {
  final docId = idGen();
  final pages = <NewPage>[];
  try {
    for (var i = 1; i <= pageCount; i++) {
      final pageId = idGen();
      final bytes = await generatePagePng(label: '$name - Page $i', headerColor: headerColor);
      final rel = await fileStore.importOriginalBytes(documentId: docId, pageId: pageId, bytes: bytes);
      pages.add(NewPage(id: pageId, originalPath: rel));
    }
    return await docRepo.createWithPages(id: docId, name: name, folderId: folderId, pages: pages);
  } catch (_) {
    await fileStore.deleteDocumentDir(docId);
    rethrow;
  }
}

Future<SeedResult> seedSampleData({
  required FolderRepository folderRepo,
  required DocumentRepository docRepo,
  required TrashService trashService,
  required DocumentFileStore fileStore,
  IdGenerator idGen = newId,
}) async {
  final f1 = await folderRepo.create(name: 'Client Files', colorIndex: 0);
  final f2 = await folderRepo.create(name: 'Property Documents', colorIndex: 1);
  final f3 = await folderRepo.create(name: 'Personal IDs', colorIndex: 2);

  const rootSpecs = [
    ('sunilkumar_prajapati', 5, AppColors.folderIndigo),
    ('DocLoom 17 Sept 2026 12-02', 1, AppColors.primary),
    ('kunjbhai', 3, AppColors.folderOrange),
    ('pravinaben', 2, AppColors.folderGreen),
    ('Tax_Filing_FY25_Receipt', 4, AppColors.charcoal),
    ('Invoice_Oct_2026', 1, AppColors.folderIndigo),
  ];
  for (final spec in rootSpecs) {
    await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: spec.$1, pageCount: spec.$2, headerColor: spec.$3);
  }

  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Agreement_Draft_A', pageCount: 2, folderId: f1.id, headerColor: AppColors.folderIndigo);
  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Client_ID_Proof', pageCount: 1, folderId: f1.id, headerColor: AppColors.folderIndigo);

  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Deed_Registry_Final', pageCount: 3, folderId: f2.id, headerColor: AppColors.folderOrange);
  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Tax_Assessment_2026', pageCount: 2, folderId: f2.id, headerColor: AppColors.folderOrange);

  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Passport_Copy', pageCount: 2, folderId: f3.id, headerColor: AppColors.folderGreen);
  await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Drivers_License', pageCount: 1, folderId: f3.id, headerColor: AppColors.folderGreen);

  final trashed = await _seedDoc(docRepo: docRepo, fileStore: fileStore, idGen: idGen, name: 'Old_Draft_Trash', pageCount: 1);
  await docRepo.moveToTrash(trashed.id);

  return const SeedResult(foldersCount: 3, docsCount: 12, trashedCount: 1);
}

Future<void> clearAllData({
  required FolderRepository folderRepo,
  required DocumentRepository docRepo,
  required TrashService trashService,
}) async {
  final folders = await folderRepo.listActive();
  for (final f in folders) {
    await folderRepo.moveToTrash(f.folder.id);
  }
  final docs = await docRepo.listInFolder();
  for (final d in docs) {
    await docRepo.moveToTrash(d.document.id);
  }
  await trashService.emptyTrash();
  await trashService.cleanOrphanDirectories();
}
