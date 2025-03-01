import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_mngmt/domain/entities/task.dart';
import 'package:task_mngmt/presentation/blocs/task/task_bloc.dart';
import 'package:task_mngmt/presentation/blocs/user/user_bloc.dart';

class TaskCreationScreen extends StatefulWidget {
  final Task? task;

  const TaskCreationScreen({super.key, this.task});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late String _priority;
  late String _status;
  int? _assignedUserId;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    context.read<UserBloc>().add(UserEvent.started(context: context));
  }

  void _initializeFields() {
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate ?? DateTime.now();
      _priority = widget.task!.priority ?? 'Medium';
      _status = widget.task!.status ?? 'To-Do';
      _assignedUserId = widget.task!.userId;
    } else {
      _title = '';
      _description = '';
      _dueDate = DateTime.now();
      _priority = 'Medium';
      _status = 'To-Do';
      _assignedUserId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _formKey.currentState?.reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.task == null ? 'Create Task' : 'Edit Task',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 2,
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _title,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) => _title = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _description,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSaved: (value) => _description = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() => _dueDate = pickedDate);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Due Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _dueDate.toString().split(' ')[0],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            prefixIcon: const Icon(Icons.flag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['High', 'Medium', 'Low'].map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _priority = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: const Icon(Icons.check_circle_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['To-Do', 'In Progress', 'Done'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _status = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        userState.maybeWhen(
                          loaded: (users) => DropdownButtonFormField<int>(
                            value: _assignedUserId,
                            decoration: InputDecoration(
                              labelText: 'Assign To',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: users.map((user) {
                              return DropdownMenuItem(
                                value: user.id,
                                child: Text('${user.firstName} ${user.lastName}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _assignedUserId = value);
                            },
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.task == null ? 'Create Task' : 'Update Task',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _assignedUserId != null) {
      _formKey.currentState!.save();
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        userId: _assignedUserId!,
      );

      if (widget.task == null) {
        context.read<TaskBloc>().add(
          TaskEvent.created(context: context, task: task),
        );
      } else {
        context.read<TaskBloc>().add(
          TaskEvent.updated(context: context, task: task),
        );
      }

      _formKey.currentState?.reset();
      Navigator.pop(context);
    }
  }
}
