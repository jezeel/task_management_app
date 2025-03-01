import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_mngmt/domain/entities/task.dart' show Task;
import 'package:task_mngmt/presentation/blocs/task/task_bloc.dart';
import 'package:task_mngmt/presentation/screens/task_creation_screen.dart';
import 'package:task_mngmt/presentation/widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  List<Task> _displayedTasks = [];
  bool _isLoadingMore = false;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
    _searchAnimationController.value = 0.0;
    context.read<TaskBloc>().add(TaskEvent.started(context));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
      }
    });
  }

  List<Task> _filterTasks(List<Task> tasks, String query) {
    if (query.isEmpty) return tasks;
    return tasks.where((task) {
      final searchLower = query.toLowerCase();
      return task.title.toLowerCase().contains(searchLower) ||
          (task.description?.toLowerCase().contains(searchLower) ?? false) ||
          (task.status?.toLowerCase().contains(searchLower) ?? false) ||
          (task.priority?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await Future.delayed(const Duration(seconds: 2));

      final state = context.read<TaskBloc>().state;
      final nextItems =
          state.tasks
              .skip(_currentPage * _itemsPerPage)
              .take(_itemsPerPage)
              .toList();

      if (nextItems.isNotEmpty) {
        setState(() {
          _displayedTasks.addAll(nextItems);
          _currentPage++;
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          SizeTransition(
            sizeFactor: _searchAnimation,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter task name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: ['All', 'To-Do', 'In Progress', 'Done'].map((status) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: _selectedStatus == status,
                      label: Text(status),
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? status : 'All');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isSearchVisible 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 0;
                  _displayedTasks = [];
                });
                context.read<TaskBloc>().add(TaskEvent.started(context));
              },
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.isLoading && state.tasks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null && state.tasks.isEmpty) {
                    return Center(child: Text(state.error!));
                  }

                  if (_displayedTasks.isEmpty && state.tasks.isNotEmpty) {
                    _displayedTasks = state.tasks.take(_itemsPerPage).toList();
                    _currentPage = 1;
                  }

                  final filteredTasks = _filterTasks(
                    _displayedTasks,
                    _searchController.text,
                  );

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredTasks.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredTasks.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return TaskItem(task: filteredTasks[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          !_isSearchVisible
              ? AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton.extended(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskCreationScreen(),
                        ),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text('New Task'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              )
              : null,
    );
  }
}
