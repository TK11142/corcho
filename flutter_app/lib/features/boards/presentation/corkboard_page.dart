import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note.dart';

final notesProvider = StateNotifierProvider<NotesController, List<Note>>(
  (ref) => NotesController(),
);

class NotesController extends StateNotifier<List<Note>> {
  NotesController()
      : super([
          Note(id: '1', boardId: 'personal', text: 'Toda gran idea merece un lugar.', position: const Offset(62, 90), color: const Color(0xfffff0a8), pin: PinKind.idea, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          Note(id: '2', boardId: 'personal', text: 'Proyecto: hacer que escribir se sienta tan fácil como pensar.', position: const Offset(270, 180), color: const Color(0xffc6e5ef), pin: PinKind.progress, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        ]);

  void add(String text, Offset position) {
    final now = DateTime.now();
    state = [...state, Note(id: now.microsecondsSinceEpoch.toString(), boardId: 'personal', text: text, position: position, color: const Color(0xfffff0a8), pin: PinKind.idea, createdAt: now, updatedAt: now)];
  }

  void move(String id, Offset position) => state = [for (final note in state) if (note.id == id) note.copyWith(position: position, updatedAt: DateTime.now()) else note];

  void remove(String id) => state = state.where((note) => note.id != id).toList();
}

class CorkboardPage extends ConsumerWidget {
  const CorkboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 720;
          return Row(children: [
            if (desktop) const _BoardsRail(),
            Expanded(child: Column(children: [
              _Header(compact: !desktop),
              Expanded(child: _CorkSurface(notes: notes)),
            ])),
          ]);
        }),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 720 ? const _MobileBoards() : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(children: [const Text('🏠', style: TextStyle(fontSize: 25)), const SizedBox(width: 8), Text('Personal', style: Theme.of(context).textTheme.headlineSmall), const Spacer(), if (!compact) const SizedBox(width: 210, child: SearchBar(leading: Icon(Icons.search), hintText: 'Buscar en el corcho')), const SizedBox(width: 8), IconButton(onPressed: () {}, icon: const Icon(Icons.dark_mode_outlined))]),
      );
}

class _CorkSurface extends ConsumerWidget {
  const _CorkSurface({required this.notes});
  final List<Note> notes;
  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(builder: (context, constraints) => GestureDetector(
        onTapUp: (details) => _edit(context, ref, details.localPosition),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xffc88a4d)),
          child: Stack(children: [
            for (final note in notes) _PaperNote(note: note, onMove: (offset) => ref.read(notesProvider.notifier).move(note.id, offset), onDelete: () => ref.read(notesProvider.notifier).remove(note.id)),
            const Positioned(right: 16, bottom: 16, child: Icon(Icons.delete_outline, size: 36, color: Colors.white70)),
          ]),
        ),
      ));

  void _edit(BuildContext context, WidgetRef ref, Offset position) {
    final controller = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: controller, autofocus: true, maxLines: 5, decoration: const InputDecoration(hintText: '¿Qué está pasando por tu cabeza?')), const SizedBox(height: 12), FilledButton.icon(onPressed: () { if (controller.text.trim().isNotEmpty) ref.read(notesProvider.notifier).add(controller.text.trim(), position); Navigator.pop(context); }, icon: const Icon(Icons.push_pin), label: const Text('Pegar en el corcho'))])));
  }
}

class _PaperNote extends StatelessWidget {
  const _PaperNote({required this.note, required this.onMove, required this.onDelete});
  final Note note;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Positioned(left: note.position.dx, top: note.position.dy, child: Draggable<Note>(data: note, feedback: Material(color: Colors.transparent, child: _paper(opacity: .9)), childWhenDragging: const SizedBox.shrink(), onDragEnd: (details) => onMove(details.offset), child: _paper()));
  Widget _paper({double opacity = 1}) => Opacity(opacity: opacity, child: Transform.rotate(angle: (note.id.hashCode % 9 - 4) * pi / 180, child: Container(width: 190, constraints: const BoxConstraints(minHeight: 128), padding: const EdgeInsets.fromLTRB(16, 24, 16, 14), decoration: BoxDecoration(color: note.color, boxShadow: const [BoxShadow(blurRadius: 9, offset: Offset(3, 6), color: Color(0x55000000))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Align(alignment: Alignment.topCenter, child: Icon(Icons.push_pin, color: Color(0xffc94b37), size: 22)), Text(note.text, style: const TextStyle(fontSize: 18)), const Spacer(), Text('Creado · hoy', style: const TextStyle(fontSize: 9, color: Colors.black45))])));
}

class _BoardsRail extends StatelessWidget { const _BoardsRail(); @override Widget build(BuildContext context) => NavigationRail(selectedIndex: 0, labelType: NavigationRailLabelType.all, destinations: const [NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Personal')), NavigationRailDestination(icon: Icon(Icons.school_outlined), label: Text('Universidad')), NavigationRailDestination(icon: Icon(Icons.work_outline), label: Text('Trabajo'))]); }
class _MobileBoards extends StatelessWidget { const _MobileBoards(); @override Widget build(BuildContext context) => const NavigationBar(selectedIndex: 0, destinations: [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Personal'), NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Estudio'), NavigationDestination(icon: Icon(Icons.work_outline), label: 'Trabajo')]); }
