import 'package:flutter/material.dart';
import '../../models/league_format.dart';
import '../../utils/league_code.dart';

/// Screen to create a new league with 3 format options.
class CreateLeagueScreen extends StatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  State<CreateLeagueScreen> createState() => _CreateLeagueScreenState();
}

class _CreateLeagueScreenState extends State<CreateLeagueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  LeagueFormat _selectedFormat = LeagueFormat.classic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create eSportlyic League'),
        backgroundColor: _selectedFormat == LeagueFormat.classic ? Colors.green : Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'League Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 24),
              const Text('Select Format:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              // Option 1: Classic
              RadioListTile<LeagueFormat>(
                title: Text(LeagueFormat.classic.displayName),
                subtitle: Text(LeagueFormat.classic.description),
                value: LeagueFormat.classic,
                groupValue: _selectedFormat,
                onChanged: (val) => setState(() => _selectedFormat = val!),
              ),
              
              // Option 2: UCL Group Stage
              RadioListTile<LeagueFormat>(
                title: Text(LeagueFormat.uclGroup.displayName),
                subtitle: Text(LeagueFormat.uclGroup.description),
                value: LeagueFormat.uclGroup,
                groupValue: _selectedFormat,
                onChanged: (val) => setState(() => _selectedFormat = val!),
              ),

              // Option 3: UCL Swiss Model
              RadioListTile<LeagueFormat>(
                title: Text(LeagueFormat.uclSwiss.displayName),
                subtitle: Text(LeagueFormat.uclSwiss.description),
                value: LeagueFormat.uclSwiss,
                groupValue: _selectedFormat,
                onChanged: (val) => setState(() => _selectedFormat = val!),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final code = LeagueCode.generate();
                    // Navigation logic here
                    Navigator.pop(context);
                  }
                },
                child: const Text('GENERATE LEAGUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
