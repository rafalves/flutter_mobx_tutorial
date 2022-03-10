import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_mobx_tutorial/data/model/weather.dart';
import 'package:flutter_mobx_tutorial/state/weather_store.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

class WeatherSearchPage extends StatefulWidget {
  const WeatherSearchPage({Key? key}) : super(key: key);

  @override
  _WeatherSearchPageState createState() => _WeatherSearchPageState();
}

class _WeatherSearchPageState extends State<WeatherSearchPage> {
  late WeatherStore _weatherStore;
  List<ReactionDisposer>? _disposers;
  // For showing a SnackBar
  //GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _weatherStore = Provider.of<WeatherStore>(context, listen: false);
    _disposers ??= [
      reaction(
        // Tell the reaction which observable to observe
        (_) => _weatherStore.errorMessage,
        // Run some logic with the content of the observed field
        (String? message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message!),
            ),
          );
          // _scaffoldKey.currentState!.showSnackBar(
          //   SnackBar(
          //     content: Text(message!),
          //   ),
          // );
        },
      ),
    ];
  }

  @override
  void dispose() {
    _disposers?.forEach((d) => d());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Search"),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Observer(builder: (_) {
            switch (_weatherStore.state) {
              case StoreState.initial:
                return buildInitialInput();
              case StoreState.loading:
                return buildLoading();
              case StoreState.loaded:
                return buildColumnWithData(_weatherStore.weather!);
            }
          })),
    );
  }

  Widget buildInitialInput() {
    return const Center(
      child: CityInputField(),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Column buildColumnWithData(Weather weather) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          weather.cityName,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          // Display the temperature with 1 decimal place
          "${weather.temperatureCelsius.toStringAsFixed(1)} °C",
          style: const TextStyle(fontSize: 80),
        ),
        const CityInputField(),
      ],
    );
  }
}

class CityInputField extends StatefulWidget {
  const CityInputField({Key? key}) : super(key: key);

  @override
  State<CityInputField> createState() => _CityInputFieldState();
}

class _CityInputFieldState extends State<CityInputField> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = '';
  }

  @override
  void dispose() {
    textEditingController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: textEditingController,
        onSubmitted: (value) =>
            submitCityName(context, textEditingController.text),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Enter a city",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }

  void submitCityName(BuildContext context, String cityName) {
    final weatherStore = Provider.of<WeatherStore>(context, listen: false);
    weatherStore.getWeather(cityName);
  }
}
