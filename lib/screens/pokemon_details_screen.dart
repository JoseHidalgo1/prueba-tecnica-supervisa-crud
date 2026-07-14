import 'package:flutter/material.dart';
import 'package:supervisa_task_manager/database/pokemon_api_services.dart';
import 'package:supervisa_task_manager/models/pokemon.dart';

class PokemonDetailsScreen extends StatefulWidget {
  const PokemonDetailsScreen({super.key});

  @override
  State<PokemonDetailsScreen> createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState extends State<PokemonDetailsScreen> {
  final _controller = TextEditingController(text: 'ditto');
  final _service = PokeApiServices();

  Pokemon? _pokemon;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _controller.text.trim().toLowerCase();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
      _pokemon = null;
      _error = null;
    });

    try {
      final pokemon = await _service.getPokemon(name);
      if (!mounted) return;
      setState(() {
        _pokemon = pokemon;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Pokemon not found: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PokeAPI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter Pokemon name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_pokemon == null) {
      return const Center(
        child: Text('Busca un Pokémon por nombre.'),
      );
    }

    final pokemon = _pokemon!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pokemon.imageUrl.isNotEmpty)
            Image.network(
              pokemon.imageUrl,
              height: 150,
              fit: BoxFit.contain,
            ),
          const SizedBox(height: 16),
          Text(
            pokemon.name.toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '#${pokemon.id}',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: pokemon.types
                .map((type) => Chip(label: Text(type.toUpperCase())))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoCard(label: 'Height', value: '${pokemon.height / 10} m'),
              _InfoCard(label: 'Weight', value: '${pokemon.weight / 10} kg'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Stats', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...pokemon.stats.map(
            (stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(stat.name.toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: stat.baseStat / 255,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Abilities', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: pokemon.abilities
                .map((ability) => Chip(label: Text(ability.toUpperCase())))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}



