package com.example.money_manage

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class NotificationListener : NotificationListenerService() {

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
                    lowerText.contains("npr") ||
                    lowerText.contains("₹")

        if (!isFinance) return

        Log.d("NOTI", "RAW TEXT: $text")

        val cleanedText = text.replace(",", "")

        var amount = "0"

        val regex = Regex("(?i)(rs\\.?|inr|npr|₹)\\s*([0-9]+)")
        val match = regex.find(cleanedText)

        if (match != null) {
            amount = match.groupValues[2]
        } else {
            val fallback = Regex("\\d+").find(cleanedText)
            amount = fallback?.value ?: "0"
        }

        Log.d("NOTI", "FINAL AMOUNT: $amount")

        // ✅ SEND TO FLUTTER USING NEW CHANNEL
        MainActivity.channel?.invokeMethod(
            "onNotification",
            mapOf(
                "title" to title,
                "text" to text,
                "amount" to amount
            )
        )
    }
}