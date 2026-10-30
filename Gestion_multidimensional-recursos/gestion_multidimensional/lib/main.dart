import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() =>
      _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with WidgetsBindingObserver {

  static const MethodChannel _canal =
  MethodChannel('epn.recursos/configuracion');

  String _texto = 'Cargando recursos...';

  Color _colorTexto = Colors.black;
  Color _colorFondo = Colors.white;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _canal.setMethodCallHandler(_manejarMensajeNativo);

    _obtenerRecursos();
  }

  Future<void> _obtenerRecursos() async {
    try {
      final Map<dynamic, dynamic>? datos =
      await _canal.invokeMapMethod<dynamic, dynamic>(
        'obtenerRecursos',
      );

      if (!mounted || datos == null) return;

      setState(() {
        _texto = datos['texto'] as String;

        _colorTexto = Color(
          (datos['colorTexto'] as num).toInt(),
        );

        _colorFondo = Color(
          (datos['colorFondo'] as num).toInt(),
        );
      });
    } on PlatformException catch (e) {
      debugPrint('Error al obtener recursos: ${e.message}');
    } on MissingPluginException catch (e) {
      debugPrint('MethodChannel no disponible: $e');
    }
  }

  Future<void> _manejarMensajeNativo(
      MethodCall llamada) async {
    if (llamada.method == 'configuracionCambiada') {
      await _obtenerRecursos();
    }
  }

  @override
  void didChangeMetrics() {
    _obtenerRecursos();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _obtenerRecursos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _canal.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: _colorTexto,
            ),
          ),
        ),
      ),
    );
  }
}