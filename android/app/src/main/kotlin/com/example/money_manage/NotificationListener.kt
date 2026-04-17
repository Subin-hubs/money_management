package com.example.money_manage

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {

    private val CHANNEL = "noti_channel"

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        val extras = sbn.notification.extras

        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        if (text == null) return

        val lowerText = text.lowercase()

        val isFinance =
            lowerText.contains("debited") ||
                    lowerText.contains("credited") ||
                    lowerText.contains("rs") ||
                    lowerText.contains("balance")

        if (!isFinance) return

        Log.d("NOTI_LISTENER", "FINANCE: $title | $text")

        val amountRegex = Regex("(rs|inr|₹)\\s?([0-9,]+)")
        val match = amountRegex.find(text)

        val amount = match?.groups?.get(2)?.value ?: "0"

        Log.d("NOTI_LISTENER", "AMOUNT: $amount")

        val engine = MainActivity.flutterEngineInstance

        if (engine != null) {
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                CHANNEL
            ).invokeMethod(
                "onNotification",
                mapOf(
                    "title" to title,
                    "text" to text,
                    "amount" to amount
                )
            )
        }
    }
}