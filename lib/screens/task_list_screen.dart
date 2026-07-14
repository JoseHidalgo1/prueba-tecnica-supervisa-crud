import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supervisa_task_manager/models/task.dart';
import 'package:supervisa_task_manager/providers/task_provider.dart';
import 'package:supervisa_task_manager/screens/task_form_screen.dart';
import 'package:supervisa_task_manager/widgets/task_card.dart';

import 'package:supervisa_task_manager/screens/pokemon_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.catching_pokemon),
            tooltip: 'PokemonAPI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PokemonDetailsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(provider.hasActiveFilters
                ? Icons.filter_alt_off
                : Icons.filter_alt),
            onPressed: () => _showFilterSheet(context),
          )
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (provider.hasActiveFilters)
          _FilterBanner(provider: provider),
        Expanded(
          child: provider.hasTasks
              ? RefreshIndicator(
                  onRefresh: () => provider.loadTasks(),
                  child: ListView.builder(
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => _navigateToEdit(context, task),
                        onDelete: () => _confirmDelete(context, task),
                      );
                    },
                  ),
                )
              : const Center(child: Text('No hay tareas pendientes')),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      builder: (_) => _FilterSheet(
        priorityFilter: provider.priorityFilter,
        statusFilter: provider.statusFilter,
        onPriorityChanged: (priority) {
          provider.setPriorityFilter(priority);
          Navigator.pop(context);
        },
        onStatusChanged: (status) {
          provider.setStatusFilter(status);
          Navigator.pop(context);
        },
        onClear: () {
          provider.clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<TaskProvider>().deleteTask(task.id!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarea eliminada')),
                );
              } on ValidationException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );

    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea creada')),
      );
    }
  }

  Future<void> _navigateToEdit(BuildContext context, Task task) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );

    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea actualizada')),
      );
    }
  }
}

class _FilterBanner extends StatelessWidget {
  const _FilterBanner({required this.provider});

  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];

    if (provider.priorityFilter != null) {
      parts.add('Prioridad: ${provider.priorityFilter!.label}');
    }
    if (provider.statusFilter != null) {
      parts.add('Estado: ${provider.statusFilter!.label}');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        parts.isNotEmpty ? parts.join(' • ') : 'Mostrando todas las tareas',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.priorityFilter,
    required this.statusFilter,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  final TaskPriority? priorityFilter;
  final TaskStatus? statusFilter;
  final ValueChanged<TaskPriority?> onPriorityChanged;
  final ValueChanged<TaskStatus?> onStatusChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrar por prioridad', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: priorityFilter == null,
                onSelected: (_) => onPriorityChanged(null),
              ),
              ...TaskPriority.values.map((p) => FilterChip(
                    label: Text(p.label),
                    selected: priorityFilter == p,
                    onSelected: (_) => onPriorityChanged(p),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Text('Filtrar por estado', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: statusFilter == null,
                onSelected: (_) => onStatusChanged(null),
              ),
              ...TaskStatus.values.map((s) => FilterChip(
                    label: Text(s.label),
                    selected: statusFilter == s,
                    onSelected: (_) => onStatusChanged(s),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClear,
              child: const Text('Limpiar filtros'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
