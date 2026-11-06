/// Organizer tournament creation form.
///
/// The mobile client sends UTC timestamps; validation is duplicated here for
/// fast feedback and enforced again by the create_tournament RPC.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key, this.tournament});

  /// When provided the page updates the tournament instead of creating one.
  final Tournament? tournament;

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _map = TextEditingController();
  final _capacity = TextEditingController(text: "32");
  final _prize = TextEditingController();
  final _rules = TextEditingController();
  final _contact = TextEditingController();

  String _format = "squad";
  String _mode = "br";
  String _visibility = "public";
  bool _waitlist = true;
  bool _requiresInGameId = false;
  bool _busy = false;

  DateTime _registrationStarts = DateTime.now().add(const Duration(hours: 1));
  DateTime _registrationEnds = DateTime.now().add(const Duration(days: 7));
  DateTime _tournamentStarts = DateTime.now().add(const Duration(days: 8));

  int get _teamSize => switch (_format) {
        "solo" => 1,
        "duo" => 2,
        _ => 4,
      };

  bool get _isEditing => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    final tournament = widget.tournament;
    if (tournament == null) return;
    _title.text = tournament.title;
    _description.text = tournament.description ?? "";
    _map.text = tournament.map ?? "";
    _capacity.text = tournament.maxTeams.toString();
    _prize.text = tournament.prizePool ?? "";
    _rules.text = tournament.rulesText ?? "";
    _contact.text = tournament.contactInfo ?? "";
    _format = tournament.format;
    _mode = tournament.mode;
    _visibility = tournament.visibility;
    _waitlist = tournament.waitlistEnabled;
    _requiresInGameId = tournament.requiresInGameId;
    _registrationStarts = tournament.registrationStartsAt;
    _registrationEnds = tournament.registrationEndsAt;
    _tournamentStarts = tournament.tournamentStartsAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _map.dispose();
    _capacity.dispose();
    _prize.dispose();
    _rules.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _editDate(
    String label,
    DateTime current,
    ValueChanged<DateTime> onChanged,
  ) async {
    final picked = await _pickDateTime(current);
    if (picked != null) setState(() => onChanged(picked));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_registrationStarts.isBefore(_registrationEnds) ||
        _registrationEnds.isAfter(_tournamentStarts)) {
      showMessage(
        context,
        "Registration must open before it closes, and close before the "
        "tournament starts.",
        error: true,
      );
      return;
    }

    setState(() => _busy = true);
    final input = TournamentInput(
      title: _title.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      format: _format,
      mode: _mode,
      map: _map.text.trim().isEmpty ? null : _map.text.trim(),
      maxTeams: int.tryParse(_capacity.text) ?? 32,
      teamSize: _teamSize,
      registrationStartsAt: _registrationStarts,
      registrationEndsAt: _registrationEnds,
      tournamentStartsAt: _tournamentStarts,
      prizePool: _prize.text.trim().isEmpty ? null : _prize.text.trim(),
      rulesText: _rules.text.trim().isEmpty ? null : _rules.text.trim(),
      contactInfo: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
      visibility: _visibility,
      waitlistEnabled: _waitlist,
      requiresInGameId: _requiresInGameId,
    );

    final existingId = widget.tournament?.id;
    if (existingId == null) {
      final result = await tournamentRepository.createTournament(input);
      if (!mounted) return;
      setState(() => _busy = false);
      result.fold(
        (failure) => showMessage(context, failure.message, error: true),
        (id) {
          showMessage(context, "Draft created.");
          context.pushReplacement("/organizer/tournaments/$id");
        },
      );
      return;
    }

    final result = await tournamentRepository.updateTournament(
      existingId,
      input,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (_) {
        showMessage(context, "Tournament updated.");
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit tournament" : "Create tournament"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _isEditing
                  ? "Changes are audited. Times are shown in your local zone "
                      "and stored in UTC."
                  : "Tournaments start as a draft. Publish, then open registration "
                      "from the management page.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value?.trim().length ?? 0) < 3
                  ? "Title must be at least 3 characters."
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _description,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: "Description (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _format,
                    decoration: const InputDecoration(
                      labelText: "Format",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "solo", child: Text("Solo")),
                      DropdownMenuItem(value: "duo", child: Text("Duo")),
                      DropdownMenuItem(value: "squad", child: Text("Squad")),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _format = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(
                      labelText: "Mode",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "br", child: Text("Battle Royale")),
                      DropdownMenuItem(value: "cs", child: Text("Clash Squad")),
                      DropdownMenuItem(value: "tdm", child: Text("TDM")),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _mode = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Roster size: $_teamSize player${_teamSize == 1 ? "" : "s"} per entry.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _map,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: "Map (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Entry capacity",
                helperText: "1-200 entries (solo players or teams)",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = int.tryParse(value ?? "");
                if (parsed == null || parsed < 1 || parsed > 200) {
                  return "Enter a capacity between 1 and 200.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _visibility,
              decoration: const InputDecoration(
                labelText: "Visibility",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "public", child: Text("Public")),
                DropdownMenuItem(value: "private", child: Text("Private")),
                DropdownMenuItem(
                  value: "invite_only",
                  child: Text("Invite only"),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _visibility = value);
              },
            ),
            const SizedBox(height: 16),
            Text("Schedule (shown in your local time)",
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _dateTile(
              "Registration opens",
              _registrationStarts,
              (value) => _registrationStarts = value,
            ),
            _dateTile(
              "Registration closes",
              _registrationEnds,
              (value) => _registrationEnds = value,
            ),
            _dateTile(
              "Tournament starts",
              _tournamentStarts,
              (value) => _tournamentStarts = value,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Waitlist"),
              subtitle: const Text(
                "Accept entries after capacity and promote them automatically "
                "when a slot frees up.",
              ),
              value: _waitlist,
              onChanged: (value) => setState(() => _waitlist = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Require in-game UID"),
              subtitle: const Text(
                "Every roster member must have a Free Fire UID before "
                "registering.",
              ),
              value: _requiresInGameId,
              onChanged: (value) => setState(() => _requiresInGameId = value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _prize,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: "Prize pool (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rules,
              maxLines: 4,
              maxLength: 4000,
              decoration: const InputDecoration(
                labelText: "Rules (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contact,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: "Contact info (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEditing ? "Save changes" : "Create draft"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(
    String label,
    DateTime value,
    ValueChanged<DateTime> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(formatDateTime(value)),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => _editDate(label, value, onChanged),
    );
  }
}
