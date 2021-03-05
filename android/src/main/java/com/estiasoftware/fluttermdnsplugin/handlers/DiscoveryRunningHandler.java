package com.estiasoftware.fluttermdnsplugin.handlers;

import android.os.Handler;
import io.flutter.plugin.common.EventChannel;

public class DiscoveryRunningHandler implements EventChannel.StreamHandler {
    final private Handler mainHandler = new Handler();

    EventChannel.EventSink sink;
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        sink = eventSink;
    }

    @Override
    public void onCancel(Object o) {

    }

    public void onDiscoveryStopped(){
      mainHandler.post(new Runnable() {
        @Override
        public void run() {
          sink.success(false);
        }
      });
    }

    public void onDiscoveryStarted(){
      mainHandler.post(new Runnable() {
        @Override
        public void run() {
          sink.success(true);
        }
      });
    }
}
