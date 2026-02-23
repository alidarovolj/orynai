package kz.orynai.app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setLocale("ru_RU")
    MapKitFactory.setApiKey("ec23256b-90b2-48da-842f-3c4cf0b6767f")
  }
}
