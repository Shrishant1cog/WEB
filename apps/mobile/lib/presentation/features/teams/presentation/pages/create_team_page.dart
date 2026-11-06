/// Team creation form.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/team_models.dart';
import '../../../../../injection_container.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _tag = TextEditingController();
  final _description = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _tag.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final result = await teamRepository.createTeam(
      TeamInput(
        name: _name.text.trim(),
        tag: _tag.text.trim().isEmpty ? null : _tag.text.trim().toUpperCase(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);

    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (teamId) {
        showMessage(context, "Team created.");
        context.pushReplacement("/teams/$teamId");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create team")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: "Team name",
                helperText: "3-50 characters, unique for the season",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? "";
                if (text.length < 3 || text.length > 50) {
                  return "Team name must be between 3 and 50 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tag,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9]")),
              ],
              decoration: const InputDecoration(
                labelText: "Tag (optional)",
                helperText: "2-6 letters or digits",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? "";
                if (text.isEmpty) return null;
                if (text.length < 2 || text.length > 6) {
                  return "Team tag must be 2-6 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: "Description (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.group_add),
              label: const Text("Create team"),
            ),
            const SizedBox(height: 12),
            Text(
              "You become the owner and captain. Invite players from the team "
              "page, then register the team for squad tournaments.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
