import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_mngmt/data/models/user_adapter.dart';
import 'package:task_mngmt/data/models/task_adapter.dart';
import 'package:task_mngmt/data/models/token_adapter.dart';
import 'package:task_mngmt/domain/entities/user.dart';
import 'package:task_mngmt/domain/entities/task.dart';
import 'package:task_mngmt/presentation/blocs/auth/auth_bloc.dart';
import 'package:task_mngmt/di/injection.dart';
import 'package:task_mngmt/presentation/blocs/task/task_bloc.dart';
import 'package:task_mngmt/presentation/blocs/user/user_bloc.dart';
import 'package:task_mngmt/presentation/screens/loading_screen.dart';
import 'package:task_mngmt/presentation/screens/login_screen.dart';
import 'package:task_mngmt/presentation/screens/error_screen.dart';
import 'package:task_mngmt/presentation/screens/task_list_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TokenAdapter());

  // Open Hive boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<String>('tokens');

  // Initialize HydratedBloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<TaskBloc>()),
        BlocProvider(create: (context) => getIt<UserBloc>()),
      ],
      child: MaterialApp(
        title: 'Task Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Color(0xFF89CFF0), // Baby blue
            secondary: Color(0xFF89CFF0).withOpacity(0.7),
            surface: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return state.when(
              initial: () {
                context.read<AuthBloc>().add(const AuthEvent.started());
                return const LoadingScreen();
              },
              loading: () => const LoadingScreen(),
              authenticated: (_) => const TaskListScreen(),
              unauthenticated: () => const LoginScreen(),
              error: (message) => ErrorScreen(message: message),
            );
          },
        ),
      ),
    );
  }
}
