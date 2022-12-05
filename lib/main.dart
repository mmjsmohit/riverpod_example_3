import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

final currentDate = Provider<DateTime>((ref) => DateTime.now());

enum City {
  stockholm,
  paris,
  tokyo,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.stockholm: '❄️',
      City.paris: '🌧️',
      City.tokyo: '☀️',
    }[city]!,
  );
}

//UI Writes to this and reads from this.
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
const unknownWeatherEmoji = '🤷‍♂️';
final weatherProvider = FutureProvider<WeatherEmoji>(((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
}));

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          currentWeather.when(
              data: (data) => Text(
                    data,
                    style: const TextStyle(fontSize: 40),
                  ),
              loading: () {
                return CircularProgressIndicator();
              },
              error: (Object error, StackTrace stackTrace) {
                return const Text('Error 😢');
              }),
          Expanded(
              child: ListView.builder(
            itemCount: City.values.length,
            itemBuilder: ((context, index) {
              final city = City.values[index];
              final isSelected = city == ref.watch(currentCityProvider);
              return ListTile(
                title: Text(city.toString()),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () =>
                    ref.read(currentCityProvider.notifier).state = city,
              );
            }),
          ))
        ],
      ),
    );
  }
}
