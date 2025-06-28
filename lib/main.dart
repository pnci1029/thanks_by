import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/diary_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/write/write_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'core/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thanks Diary',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/write': (_) => const WriteScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/stats': (_) => const StatsScreen(),
      },
    );
  }
}