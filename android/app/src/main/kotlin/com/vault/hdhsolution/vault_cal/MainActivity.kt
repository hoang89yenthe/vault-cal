package com.vault.hdhsolution.vault_cal

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "vault/app_icon"

    private val aliases = mapOf(
        "calc" to ".LauncherCalc",
        "weather" to ".LauncherWeather",
        "compass" to ".LauncherCompass"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val icon = call.argument<String>("icon") ?: "calc"
                        setLauncherIcon(icon)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Enables the chosen alias BEFORE disabling the others, so the app is
    // never left without a launcher component.
    private fun setLauncherIcon(icon: String) {
        val target = aliases[icon] ?: return
        val pm = packageManager

        pm.setComponentEnabledSetting(
            ComponentName(packageName, packageName + target),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
        for ((key, alias) in aliases) {
            if (key == icon) continue
            pm.setComponentEnabledSetting(
                ComponentName(packageName, packageName + alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
