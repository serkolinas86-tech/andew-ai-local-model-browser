package com.andew.ailocal

import android.app.Application
import androidx.lifecycle.ProcessLifecycleOwner

class AndewAIApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ProcessLifecycleOwner.get().lifecycle.addObserver(AppLifecycleObserver())
    }
}

class AppLifecycleObserver : androidx.lifecycle.DefaultLifecycleObserver {
    override fun onStart(owner: androidx.lifecycle.LifecycleOwner) {
        // App came to foreground
    }

    override fun onStop(owner: androidx.lifecycle.LifecycleOwner) {
        // App went to background
    }
}