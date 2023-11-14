package com.example.lx_music_flutter.common;

import androidx.annotation.NonNull;


import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterMethodHandler implements MethodChannel.MethodCallHandler {
    FlutterMethodChannel channel;

    public FlutterMethodHandler(FlutterMethodChannel channel) {
        this.channel = channel;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Class clz = channel.getClass();
        try {
            Method method = clz.getMethod(call.method, MethodCall.class, MethodChannel.Result.class);
            method.invoke(channel, call, result);
        } catch (NoSuchMethodException e) {
            result.notImplemented();
        } catch (IllegalAccessException | InvocationTargetException e) {
        }
    }
}
