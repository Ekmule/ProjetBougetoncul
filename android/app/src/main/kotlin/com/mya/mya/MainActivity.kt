package com.mya.mya

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // OAuth deep link : relayer l'intent quand l'app est déjà ouverte (singleTop).
        setIntent(intent)
    }
}
