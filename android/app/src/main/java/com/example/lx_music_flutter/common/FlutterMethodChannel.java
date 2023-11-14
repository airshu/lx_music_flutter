package com.example.lx_music_flutter.common;

import android.app.Activity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public abstract class FlutterMethodChannel {
    protected String CHANNEL;
    protected String LOGTAG;
    protected MethodChannel methodChannel;
    protected Activity activity;
    protected FlutterEngine flutterEngine;

    public FlutterMethodChannel(Activity a, FlutterEngine engine, String channel) {
        activity = a;
        flutterEngine = engine;
        CHANNEL = channel;
        LOGTAG = "methodChannel:" + CHANNEL;
        this.initChannel();
    }

    private void initChannel() {
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler(new FlutterMethodHandler(this));
    }
}
