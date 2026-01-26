package com.geovoy.geovoy_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import android.graphics.drawable.GradientDrawable

class ETAForegroundService : Service() {
    
    companion object {
        private const val CHANNEL_ID = "bus_eta_channel"
        private const val CHANNEL_NAME = "Bus ETA"
        private const val NOTIFICATION_ID = 1001
        
        var isRunning = false
            private set
        
        fun start(context: Context, tripId: String, routeName: String, eta: Int, status: String) {
            val intent = Intent(context, ETAForegroundService::class.java).apply {
                action = "START"
                putExtra("tripId", tripId)
                putExtra("routeName", routeName)
                putExtra("eta", eta)
                putExtra("status", status)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun update(context: Context, eta: Int, status: String) {
            val intent = Intent(context, ETAForegroundService::class.java).apply {
                action = "UPDATE"
                putExtra("eta", eta)
                putExtra("status", status)
            }
            context.startService(intent)
        }
        
        fun stop(context: Context) {
            val intent = Intent(context, ETAForegroundService::class.java).apply {
                action = "STOP"
            }
            context.startService(intent)
        }
    }
    
    private var windowManager: WindowManager? = null
    private var floatingView: View? = null
    private var currentRouteName: String = ""
    private var currentETA: Int = 0
    private var currentStatus: String = ""
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }
    
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        android.util.Log.d("ETAService", "🤖 App killed by user (swiped away)")
        removeFloatingPill()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        isRunning = false
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                currentRouteName = intent.getStringExtra("routeName") ?: ""
                currentETA = intent.getIntExtra("eta", 0)
                currentStatus = intent.getStringExtra("status") ?: ""
                
                startForeground(NOTIFICATION_ID, buildNotification())
                showFloatingPill()
                isRunning = true
            }
            "UPDATE" -> {
                currentETA = intent.getIntExtra("eta", currentETA)
                currentStatus = intent.getStringExtra("status") ?: currentStatus
                
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(NOTIFICATION_ID, buildNotification())
                updateFloatingPill()
            }
            "STOP" -> {
                removeFloatingPill()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                isRunning = false
            }
        }
        return START_STICKY
    }
    
    private fun showFloatingPill() {
        if (!Settings.canDrawOverlays(this)) return
        if (floatingView != null) return

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
            else 
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = 20 // Margin from top
        }

        floatingView = createPillView()
        floatingView?.setOnClickListener {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            launchIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(launchIntent)
        }
        
        try {
            windowManager?.addView(floatingView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createPillView(): View {
        val container = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(30, 15, 30, 15)
            
            val background = GradientDrawable().apply {
                setColor(Color.parseColor("#1A1A1A")) // Dark background
                cornerRadius = 100f // Pill shape
                setStroke(2, Color.parseColor("#FF9800")) // Orange border
            }
            setBackground(background)
            elevation = 10f
        }

        val busIcon = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_directions)
            setColorFilter(Color.parseColor("#FF9800"))
            layoutParams = android.widget.LinearLayout.LayoutParams(40, 40).apply {
                marginEnd = 15
            }
        }

        val textLayout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
        }

        val routeText = TextView(this).apply {
            text = currentRouteName
            setTextColor(Color.WHITE)
            textSize = 10f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
        }

        val etaText = TextView(this).apply {
            tag = "eta_text"
            text = "$currentETA min"
            setTextColor(Color.parseColor("#FF9800"))
            textSize = 12f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }

        textLayout.addView(routeText)
        textLayout.addView(etaText)
        
        container.addView(busIcon)
        container.addView(textLayout)
        
        return container
    }

    private fun updateFloatingPill() {
        floatingView?.let { view ->
            val etaTextView = view.findViewWithTag<TextView>("eta_text") ?: run {
                // Find by index if ID/Tag logic is tricky in dynamic views
                ((view as android.view.ViewGroup).getChildAt(1) as android.view.ViewGroup).getChildAt(1) as TextView
            }
            etaTextView.text = "$currentETA min"
        }
    }

    private fun removeFloatingPill() {
        floatingView?.let {
            windowManager?.removeView(it)
            floatingView = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "Muestra el tiempo estimado de llegada del autobús"
                setShowBadge(false)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun buildNotification(): android.app.Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(currentRouteName)
            .setContentText("ETA: $currentETA minutos")
            .setSmallIcon(android.R.drawable.ic_menu_directions)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_NAVIGATION)
            .build()
    }
    
    override fun onBind(intent: Intent?) = null
    override fun onDestroy() {
        removeFloatingPill()
        super.onDestroy()
    }
}
