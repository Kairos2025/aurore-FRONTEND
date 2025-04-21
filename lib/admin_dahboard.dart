class _AdminDashboardState extends State<AdminDashboard> {
  final _timetableController = TimetableController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Admin Dashboard',
        actions: [_buildGenerationButton()],
      ),
      body: Column(
        children: [
          _buildSubjectInput(),
          Expanded(child: _buildTimetablePreview()),
        ],
      ),
    );
  }

  Widget _buildSubjectInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _subjectController,
        decoration: const InputDecoration(
          labelText: 'Subjects (comma-separated)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenerationButton() {
    return IconButton(
      icon: const Icon(Icons.auto_awesome_mosaic),
      onPressed: () => _generateTimetable(context), // Pass context
      tooltip: 'Generate with AI',
    );
  }

  void _generateTimetable(BuildContext context) {
    if (_subjectController.text.isNotEmpty) {
      _timetableController.generateTimetable(
        {
          'subjects': _subjectController.text.split(',').map((s) => s.trim()).toList(),
          'constraints': {
            'working_hours': {'start': '08:00', 'end': '18:00'},
          },
        },
        context, // Pass context
      );
    }
  }
}
// TODO Implement this library.
