package com.estiasoftware.fluttermdnsplugin.handlers;

import android.os.Handler;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class ServiceDiscoveredHandler implements EventChannel.StreamHandler {
    final private Handler mainHandler = new Handler();

    EventChannel.EventSink sink;
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      sink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
    }

    public void onServiceDiscovered(final Map<String, Object> serviceInfoMap){
      mainHandler.post(new Runnable() {
        @Override
        public void run() {
          sink.success(serviceInfoMap);
        }
      });
    }
}
