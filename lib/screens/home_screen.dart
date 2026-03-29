import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/sidebar.dart';
import '../screens/dashboard_screen.dart';
import '../screens/todos_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/weather_screen.dart';
import '../screens/maps_screen.dart';
import '../screens/task_modal.dart';
import '../screens/note_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final taskProvider = context.read<TaskProvider>();
    final noteProvider = context.read<NoteProvider>();
    await taskProvider.loadData();
    await noteProvider.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
        isOpen: true,
        onClose: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Desktop Sidebar
            if (MediaQuery.of(context).size.width >= 768)
              SizedBox(
                width: 250,
                child: Sidebar(
                  currentTab: _currentTab,
                  onTabSelected: (tab) => setState(() => _currentTab = tab),
                  isOpen: true,
                  onClose: () {},
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (_currentTab == 'todos' || _currentTab == 'notes')
          ? FloatingActionButton(
              onPressed: _showAddModal,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width < 768)
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          Text(
            _getTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_currentTab == 'todos' || _currentTab == 'notes')
            _buildSearchBar(),
          if (_currentTab == 'todos') _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 250,
      child: TextField(
        onChanged: (value) {
          if (_currentTab == 'todos') {
            context.read<TaskProvider>().setSearchQuery(value);
          } else if (_currentTab == 'notes') {
            context.read<NoteProvider>().setSearchQuery(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) => PopupMenuButton<FilterType>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list, size: 18),
              const SizedBox(width: 4),
              Text(_getFilterLabel(provider.filter)),
            ],
          ),
        ),
        onSelected: (filter) => provider.setFilter(filter),
        itemBuilder: (context) => [
          const PopupMenuItem(value: FilterType.all, child: Text('All')),
          const PopupMenuItem(value: FilterType.active, child: Text('Active')),
          const PopupMenuItem(value: FilterType.completed, child: Text('Completed')),
        ],
      ),
    );
  }

  String _getFilterLabel(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return 'All';
      case FilterType.active:
        return 'Active';
      case FilterType.completed:
        return 'Completed';
    }
  }

  String _getTitle() {
    switch (_currentTab) {
      case 'dashboard':
        return 'Dashboard';
      case 'todos':
        return 'Todos';
      case 'notes':
        return 'Notes';
      case 'activity':
        return 'Activity';
      case 'weather':
        return 'Weather';
      case 'maps':
        return 'Maps';
      default:
        return 'Todo App';
    }
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case 'dashboard':
        return const DashboardScreen();
      case 'todos':
        return const TodosScreen();
      case 'notes':
        return const NotesScreen();
      case 'activity':
        return const ActivityScreen();
      case 'weather':
        return const WeatherScreen();
      case 'maps':
        return const MapsScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _showAddModal() {
    if (_currentTab == 'todos') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const TaskModal(),
      );
    } else if (_currentTab == 'notes') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const NoteModal(),
      );
    } else {
      // Default to task modal for other tabs
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const TaskModal(),
      );
    }
  }
}
