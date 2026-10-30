package com.example.gestion_multidimensional

import android.content.res.Configuration
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "epn.recursos/configuracion"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "obtenerRecursos" -> {
                    try {
                        val recursos = resources

                        val mensaje = recursos.getString(
                            R.string.mensaje_principal
                        )

                        val colorTexto = recursos.getColor(
                            R.color.color_texto,
                            theme
                        )

                        val colorFondo = recursos.getColor(
                            R.color.color_fondo,
                            theme
                        )

                        result.success(
                            mapOf(
                                "texto" to mensaje,
                                "colorTexto" to colorTexto,
                                "colorFondo" to colorFondo
                            )
                        )

                    } catch (e: Exception) {
                        result.error(
                            "ERROR_RECURSOS",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onConfigurationChanged(
        newConfig: Configuration
    ) {
        super.onConfigurationChanged(newConfig)

        methodChannel?.invokeMethod(
            "configuracionCambiada",
            null
        )
    }
}
