import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class Sidebar extends StatelessWidget {
  final String currentTab;
  final Function(String) onTabSelected;
  final bool isOpen;
  final VoidCallback onClose;

  const Sidebar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.isOpen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check_box, color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Todo App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  tab: 'dashboard',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'dashboard'),
                ),
                _NavItem(
                  icon: Icons.list_alt,
                  label: 'Todos',
                  tab: 'todos',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'todos'),
                ),
                _NavItem(
                  icon: Icons.note_alt,
                  label: 'Notes',
                  tab: 'notes',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'notes'),
                ),
                _NavItem(
                  icon: Icons.history,
                  label: 'Activity',
                  tab: 'activity',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'activity'),
                ),
                _NavItem(
                  icon: Icons.wb_sunny,
                  label: 'Weather',
                  tab: 'weather',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'weather'),
                ),
                _NavItem(
                  icon: Icons.map,
                  label: 'Maps',
                  tab: 'maps',
                  currentTab: currentTab,
                  onTap: () => _handleTap(context, 'maps'),
                ),
              ],
            ),
          ),
          if (currentTab == 'todos' || currentTab == 'notes')
            Consumer<TaskProvider>(
              builder: (context, taskProvider, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatRow(label: 'Total', value: taskProvider.totalCount, color: Colors.blue),
                    _StatRow(label: 'Active', value: taskProvider.activeCount, color: Colors.orange),
                    _StatRow(label: 'Completed', value: taskProvider.completedCount, color: Colors.green),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, String tab) {
    onTabSelected(tab);
    onClose();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tab;
  final String currentTab;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.tab,
    required this.currentTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTab == tab;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.purple : Colors.grey.shade600),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.purple : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
