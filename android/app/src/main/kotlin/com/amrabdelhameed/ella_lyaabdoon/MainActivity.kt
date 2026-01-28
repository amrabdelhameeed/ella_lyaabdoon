package com.amrabdelhameed.ella_lyaabdoon

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Remove the intent flags modification - let Flutter handle splash naturally
        super.onCreate(savedInstanceState)
    }
}