import 'package:flutter/material.dart';
import '../../managers/save_state_manager.dart';

class PhoneSaveLoadPopup extends StatefulWidget {
  final String encounterId;
  final Map<String, dynamic> progress;
  final void Function(Map<String, dynamic>? loadedState)? onLoad;
  final Future<void> Function(String saveId)? onDelete;
  const PhoneSaveLoadPopup({
    required this.encounterId,
    required this.progress,
    this.onLoad,
    this.onDelete,
    super.key,
  });

  @override
  State<PhoneSaveLoadPopup> createState() => _PhoneSaveLoadPopupState();
}

class _PhoneSaveLoadPopupState extends State<PhoneSaveLoadPopup> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _saveStates = [];
  bool _showLoadDialog = false;

  Future<void> _saveState() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SaveStateManager().saveState(
        encounter: widget.encounterId,
        progress: widget.progress,
      );
      if (mounted) print('DEBUG: Save called for ${widget.encounterId}');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Game saved!')));
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Save failed.';
      });
      print('DEBUG: Save error: $e');
    }
  }

  Future<void> _loadStates() async {
    setState(() {
      _showLoadDialog = true;
      _loading = true;
      _error = null;
    });
    try {
      final states = await SaveStateManager().loadStates();
      print('DEBUG: Loaded states: $states');
      setState(() {
        _saveStates = states;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Load failed.';
      });
      print('DEBUG: Load error: $e');
    }
  }

  void _onSelectState(Map<String, dynamic> state) {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 100), () {
      final encounter = state['encounter'] ?? 'ShopScreen';
      final progress = state['progress'] ?? {};
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SaveStateManager.loadEncounterScreen(encounter, progress),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: const Color(0xFF222831),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380,
          
          maxHeight: screenHeight * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Save/Load',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[200],
                        letterSpacing: 1.2,
                        fontFamily: 'RobotoMono',
                      )),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.amber),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(color: Colors.amber[200]),

              // Content Scrollable Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),

                      // Save / Load buttons
                      if (!_showLoadDialog)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                              onPressed: _loading ? null : _saveState,
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.download),
                              label: const Text('Load'),
                              onPressed: _loading ? null : _loadStates,
                            ),
                          ],
                        ),

                      // Load Dialog with Scrollable List
                      if (_showLoadDialog)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Load Save State',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[200],
                                      fontFamily: 'RobotoMono',
                                    )),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.amber),
                                  onPressed: () => setState(() {
                                    _showLoadDialog = false;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _saveStates.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No save states found.',
                                          style: TextStyle(
                                              color: Colors.white70)),
                                    ),
                                  )
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      // dynamically sized list area
                                      maxHeight: screenHeight * 0.45,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _saveStates.length,
                                      itemBuilder: (context, idx) {
                                        final state = _saveStates[idx];
                                        return Card(
                                          color: Colors.grey[900],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: ListTile(
                                            title: Text(
                                              'Encounter: ${state['encounter'] ?? 'Unknown'}',
                                              style: const TextStyle(
                                                  color: Colors.amber),
                                            ),
                                            subtitle: Text(
                                              'Saved: ${state['timestamp'] ?? ''}',
                                              style: const TextStyle(
                                                  color: Colors.white70),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              tooltip: 'Delete save',
                                              onPressed: () async {
                                                final saveId =
                                                    state['id']?.toString();
                                                if (saveId != null) {
                                                  if (widget.onDelete != null) {
                                                    await widget
                                                        .onDelete!(saveId);
                                                  } else {
                                                    await SaveStateManager()
                                                        .deleteState(saveId);
                                                  }
                                                  setState(() {
                                                    _saveStates.removeAt(idx);
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Save deleted!')),
                                                  );
                                                }
                                              },
                                            ),
                                            onTap: () => _onSelectState(state),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
