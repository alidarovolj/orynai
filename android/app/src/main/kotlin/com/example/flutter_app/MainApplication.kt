package com.example.flutter_app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setApiKey("c8be6d3f-5040-4607-8cb1-082ea246eb81")
  }
}
