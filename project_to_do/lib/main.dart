import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/task_remote_datasource.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/usecases/task_usecases.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar variables de entorno desde .env
  await dotenv.load(fileName: '.env');

  // 2. Inicializar Supabase con las credenciales del .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Inyección de dependencias en orden:
    //    datasource → repository → usecases → provider

    final client = Supabase.instance.client;

    // Capa data
    final remote = TaskRemoteDataSource(client);
    final repository = TaskRepositoryImpl(remote);

    // Casos de uso
    final getTodayTasks = GetTodayTasksUseCase(repository);
    final getAllTasks = GetAllTasksUseCase(repository);
    final createTask = CreateTaskUseCase(repository);
    final toggleDone = ToggleDoneUseCase(repository);
    final deleteTask = DeleteTaskUseCase(repository);
    final getFiles = GetFilesForTaskUseCase(repository);
    final uploadFile = UploadFileUseCase(repository);

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(
        getTodayTasks: getTodayTasks,
        getAllTasks: getAllTasks,
        createTask: createTask,
        toggleDone: toggleDone,
        deleteTask: deleteTask,
        getFiles: getFiles,
        uploadFile: uploadFile,
      ),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
      ),
    );
  }
}