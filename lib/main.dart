import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kAccent = Color(0xFF4968F5);
const kBg = Color(0xFFF4F6FB);
const kInk = Color(0xFF1B2140);

void main() => runApp(const MarkTrackApp());

class MarkTrackApp extends StatelessWidget {
  const MarkTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarkTrack | Marks Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent),
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

// ---------------------------------------------------------------- model

class Subject {
  String name;
  double obtained;
  double max;
  double credits;
  Subject(this.name, this.obtained, this.max, this.credits);

  double get percent => max == 0 ? 0 : obtained / max * 100;
  String get grade => gradeFor(percent).letter;
  int get point => gradeFor(percent).point;
}

({String letter, int point}) gradeFor(double p) {
  if (p >= 90) return (letter: 'O', point: 10);
  if (p >= 80) return (letter: 'A+', point: 9);
  if (p >= 70) return (letter: 'A', point: 8);
  if (p >= 60) return (letter: 'B+', point: 7);
  if (p >= 50) return (letter: 'B', point: 6);
  if (p >= 40) return (letter: 'C', point: 5);
  return (letter: 'F', point: 0);
}

class Summary {
  final double total, maxTotal, percent, gpa, credits;
  final bool passed;
  Summary._(this.total, this.maxTotal, this.percent, this.gpa, this.credits,
      this.passed);

  factory Summary.of(List<Subject> s) {
    final total = s.fold<double>(0, (a, e) => a + e.obtained);
    final maxTotal = s.fold<double>(0, (a, e) => a + e.max);
    final credits = s.fold<double>(0, (a, e) => a + e.credits);
    final weighted = s.fold<double>(0, (a, e) => a + e.point * e.credits);
    return Summary._(
      total,
      maxTotal,
      maxTotal == 0 ? 0 : total / maxTotal * 100,
      credits == 0 ? 0 : weighted / credits,
      credits,
      s.isNotEmpty && s.every((e) => e.percent >= 40),
    );
  }
}

// ---------------------------------------------------------------- shell

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final List<Subject> _subjects = [
    Subject('Mathematics', 86, 100, 4),
    Subject('Physics', 72, 100, 3),
    Subject('Data Structures', 91, 100, 4),
    Subject('English', 64, 100, 2),
    Subject('Mobile App Development', 78, 100, 3),
  ];

  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Subjects'),
    (Icons.track_changes_outlined, Icons.track_changes, 'Target'),
  ];

  void _save(Subject? old, Subject s) => setState(() {
        if (old == null) {
          _subjects.add(s);
        } else {
          _subjects[_subjects.indexOf(old)] = s;
        }
      });

  void _delete(Subject s) => setState(() => _subjects.remove(s));

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final pages = [
      DashboardPage(subjects: _subjects),
      SubjectsPage(subjects: _subjects, onSave: _save, onDelete: _delete),
      const TargetPage(),
    ];
    return Scaffold(
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final it in _items)
                  NavigationDestination(
                      icon: Icon(it.$1),
                      selectedIcon: Icon(it.$2),
                      label: it.$3),
              ],
            ),
      body: SafeArea(
        child: Row(children: [
          if (wide)
            NavigationRail(
              extended: true,
              backgroundColor: Colors.white,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Row(children: [
                  Icon(Icons.school, color: kAccent, size: 30),
                  SizedBox(width: 8),
                  Text('MarkTrack',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kInk)),
                ]),
              ),
              destinations: [
                for (final it in _items)
                  NavigationRailDestination(
                      icon: Icon(it.$1),
                      selectedIcon: Icon(it.$2),
                      label: Text(it.$3)),
              ],
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: pages[_index],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- shared UI

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E7F3)),
        ),
        child: child,
      );
}

class PageTitle extends StatelessWidget {
  final String title, subtitle;
  final Widget? action;
  const PageTitle(this.title, this.subtitle, {super.key, this.action});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: kInk)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          if (action != null) action!,
        ]),
      );
}

Color gradeColor(double p) {
  if (p >= 80) return const Color(0xFF1E9E63);
  if (p >= 60) return kAccent;
  if (p >= 40) return const Color(0xFFE09A1A);
  return const Color(0xFFD64545);
}

// ---------------------------------------------------------------- dashboard

class DashboardPage extends StatelessWidget {
  final List<Subject> subjects;
  const DashboardPage({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final s = Summary.of(subjects);
    final cards = [
      ('GPA (10-point)', s.gpa.toStringAsFixed(2), Icons.stars, kAccent),
      ('Percentage', '${s.percent.toStringAsFixed(1)}%', Icons.percent,
          const Color(0xFF1E9E63)),
      ('Total marks',
          '${s.total.toStringAsFixed(0)} / ${s.maxTotal.toStringAsFixed(0)}',
          Icons.functions, const Color(0xFFE09A1A)),
      ('Result', subjects.isEmpty ? '-' : (s.passed ? 'PASS' : 'FAIL'),
          Icons.verified,
          s.passed ? const Color(0xFF1E9E63) : const Color(0xFFD64545)),
    ];
    final dist = <String, int>{};
    for (final e in subjects) {
      dist[e.grade] = (dist[e.grade] ?? 0) + 1;
    }

    return ListView(padding: const EdgeInsets.all(20), children: [
      const PageTitle('Dashboard', 'Your academic performance at a glance'),
      LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth >= 700 ? (c.maxWidth - 36) / 4 : (c.maxWidth - 12) / 2;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final k in cards)
            SizedBox(
              width: w,
              child: Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(k.$3, color: k.$4),
                  const SizedBox(height: 10),
                  Text(k.$1, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(k.$2,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800, color: k.$4)),
                ]),
              ),
            ),
        ]);
      }),
      const SizedBox(height: 16),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Subject performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (subjects.isEmpty)
            const Text('No subjects yet. Open Subjects and add your first one.'),
          for (final e in subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                SizedBox(
                    width: 130,
                    child: Text(e.name, overflow: TextOverflow.ellipsis)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (e.percent / 100).clamp(0, 1),
                      minHeight: 14,
                      color: gradeColor(e.percent),
                      backgroundColor: const Color(0xFFE9ECF6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text('${e.percent.toStringAsFixed(1)}%  ${e.grade}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Grade distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final g in ['O', 'A+', 'A', 'B+', 'B', 'C', 'F'])
              Chip(
                label: Text('$g: ${dist[g] ?? 0}'),
                backgroundColor: (dist[g] ?? 0) > 0
                    ? kAccent.withOpacity(0.12)
                    : Colors.grey.shade100,
              ),
          ]),
          const SizedBox(height: 10),
          const Text(
            'Scale: 90+ O, 80+ A+, 70+ A, 60+ B+, 50+ B, 40+ C, below 40 F. '
            'Pass means at least 40% in every subject.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- subjects

class SubjectsPage extends StatelessWidget {
  final List<Subject> subjects;
  final void Function(Subject? old, Subject updated) onSave;
  final void Function(Subject) onDelete;
  const SubjectsPage(
      {super.key,
      required this.subjects,
      required this.onSave,
      required this.onDelete});

  Future<void> _edit(BuildContext context, Subject? old) async {
    final name = TextEditingController(text: old?.name ?? '');
    final marks = TextEditingController(text: old == null ? '' : '${old.obtained}');
    final max = TextEditingController(text: old == null ? '100' : '${old.max}');
    final credits =
        TextEditingController(text: old == null ? '3' : '${old.credits}');
    final fmt = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(old == null ? 'Add subject' : 'Edit subject'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Subject name')),
              TextField(
                  controller: marks,
                  keyboardType: TextInputType.number,
                  inputFormatters: fmt,
                  decoration: const InputDecoration(labelText: 'Marks obtained')),
              TextField(
                  controller: max,
                  keyboardType: TextInputType.number,
                  inputFormatters: fmt,
                  decoration: const InputDecoration(labelText: 'Maximum marks')),
              TextField(
                  controller: credits,
                  keyboardType: TextInputType.number,
                  inputFormatters: fmt,
                  decoration: const InputDecoration(labelText: 'Credits')),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final m = double.tryParse(marks.text);
                final mx = double.tryParse(max.text);
                final cr = double.tryParse(credits.text);
                if (name.text.trim().isEmpty ||
                    m == null ||
                    mx == null ||
                    cr == null ||
                    mx <= 0) {
                  setD(() => error = 'Fill in every field with valid numbers.');
                } else if (m > mx) {
                  setD(() => error = 'Marks cannot be more than the maximum.');
                } else {
                  onSave(old, Subject(name.text.trim(), m, mx, cr));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      PageTitle(
        'Subjects',
        '${subjects.length} subjects added',
        action: FilledButton.icon(
          onPressed: () => _edit(context, null),
          icon: const Icon(Icons.add),
          label: const Text('Add subject'),
        ),
      ),
      if (subjects.isEmpty)
        const Panel(child: Text('Nothing here yet. Tap Add subject to begin.')),
      for (final s in subjects)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: gradeColor(s.percent).withOpacity(0.15),
                child: Text(s.grade,
                    style: TextStyle(
                        color: gradeColor(s.percent),
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                      '${s.obtained.toStringAsFixed(0)} / ${s.max.toStringAsFixed(0)}  |  '
                      '${s.percent.toStringAsFixed(1)}%  |  ${s.credits.toStringAsFixed(0)} credits',
                      style: const TextStyle(color: Colors.black54)),
                ]),
              ),
              IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _edit(context, s),
                  icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  tooltip: 'Delete',
                  onPressed: () => onDelete(s),
                  icon: const Icon(Icons.delete_outline)),
            ]),
          ),
        ),
    ]);
  }
}

// ---------------------------------------------------------------- target

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});
  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  final target = TextEditingController(text: '75');
  final doneObtained = TextEditingController();
  final doneMax = TextEditingController();
  final remainMax = TextEditingController();
  String? message;
  bool? possible;

  void _compute() {
    final t = double.tryParse(target.text);
    final d = double.tryParse(doneObtained.text);
    final dm = double.tryParse(doneMax.text);
    final rm = double.tryParse(remainMax.text);
    if (t == null || d == null || dm == null || rm == null || rm <= 0 || d > dm) {
      setState(() {
        possible = null;
        message = 'Enter valid numbers. Marks scored cannot exceed their maximum.';
      });
      return;
    }
    final need = t / 100 * (dm + rm) - d;
    setState(() {
      if (need <= 0) {
        possible = true;
        message = 'You have already reached your target. Any score will do.';
      } else if (need > rm) {
        possible = false;
        message =
            'You would need ${need.toStringAsFixed(1)} out of ${rm.toStringAsFixed(0)}, which is not possible. Try a lower target.';
      } else {
        possible = true;
        message =
            'You need ${need.toStringAsFixed(1)} out of ${rm.toStringAsFixed(0)} '
            '(${(need / rm * 100).toStringAsFixed(1)}%) in the remaining exams.';
      }
    });
  }

  Widget _field(String label, TextEditingController c) => SizedBox(
        width: 220,
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const PageTitle('Target', 'Find out what you need to score in the remaining exams'),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 14, runSpacing: 14, children: [
            _field('Target percentage', target),
            _field('Marks scored so far', doneObtained),
            _field('Maximum of those exams', doneMax),
            _field('Maximum of remaining exams', remainMax),
          ]),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (possible == true
                        ? const Color(0xFF1E9E63)
                        : const Color(0xFFD64545))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(message!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ),
    ]);
  }
}
