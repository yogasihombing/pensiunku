package com.pensiunku.services



import com.google.firebase.messaging.FirebaseMessagingService

import com.google.firebase.messaging.RemoteMessage

import android.util.Log



class MyFirebaseMessagingService : FirebaseMessagingService() {



    companion object {

        private const val TAG = "MyFirebaseMsgService"

    }



    override fun onMessageReceived(remoteMessage: RemoteMessage) {

        super.onMessageReceived(remoteMessage)

        

        Log.d(TAG, "From: ${remoteMessage.from}")

        

        // Check if message contains a data payload

        if (remoteMessage.data.isNotEmpty()) {

            Log.d(TAG, "Message data payload: ${remoteMessage.data}")

        }



        // Check if message contains a notification payload

        remoteMessage.notification?.let {

            Log.d(TAG, "Message Notification Body: ${it.body}")

        }



        // Handle the message here if needed

        // Note: Flutter akan handle sebagian besar logic melalui onMessage listener

    }



    override fun onNewToken(token: String) {

        Log.d(TAG, "Refreshed token: $token")

        

        // Send token to your app server here if needed

        sendRegistrationToServer(token)

    }



    private fun sendRegistrationToServer(token: String?) {

        Log.d(TAG, "sendRegistrationTokenToServer($token)")

        // Implement sending token to your server here

        // Atau biarkan Flutter yang handle melalui onTokenRefresh listener

    }

}