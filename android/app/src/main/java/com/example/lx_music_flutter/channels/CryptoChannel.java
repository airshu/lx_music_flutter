package com.example.lx_music_flutter.channels;

import android.app.Activity;
import android.util.ArrayMap;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.example.lx_music_flutter.common.FlutterMethodChannel;
import com.example.lx_music_flutter.crypto.AES;
import com.example.lx_music_flutter.crypto.RSA;

import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CryptoChannel extends FlutterMethodChannel {

    public CryptoChannel(Activity a, FlutterEngine engine) {
        super(a, engine, "crypto_channel");
    }

    public void aesDecrypt(MethodCall call, @NonNull MethodChannel.Result result) {
        String text = call.argument("text");
        String key = call.argument("key");
        String iv = call.argument("iv");
        String mode = call.argument("mode");
        String data = AES.decrypt(text, key, iv, mode);
        result.success(data);
    }

    public void aesEncrypt(MethodCall call, @NonNull MethodChannel.Result result) {
        String text = call.argument("text");
        String key = call.argument("key");
        String iv = call.argument("iv");
        String mode = call.argument("mode");
        String data = AES.encrypt(text, key, iv, mode);
        result.success(data);
    }

    public void rsaDecrypt(MethodCall call, @NonNull MethodChannel.Result result) {
        String text = call.argument("text");
        String key = call.argument("key");
        String padding = call.argument("padding");
        String data = RSA.decryptRSAToString(text, key, padding);
        result.success(data);
    }

    public void rsaEncrypt(MethodCall call, @NonNull MethodChannel.Result result) {
        String text = call.argument("text");
        String key = call.argument("key");
        String padding = call.argument("padding");
        String data = RSA.encryptRSAToString(text, key, padding);
        result.success(data);
    }

    public void generateRsaKey(MethodCall call, @NonNull MethodChannel.Result result) {
        KeyPair kp = RSA.getKeyPair();
        String publicKeyBytesBase64 = new String(Base64.encode(kp.getPublic().getEncoded(), Base64.DEFAULT));

        KeyFactory keyFac;
        try {
            keyFac = KeyFactory.getInstance("RSA");
        } catch (NoSuchAlgorithmException e) {
            result.error("-1", e.getMessage(), e.toString());
            return;
        }
        KeySpec keySpec = new PKCS8EncodedKeySpec(kp.getPrivate().getEncoded());
        Key key;
        try {
            key = keyFac.generatePrivate(keySpec);
        } catch (InvalidKeySpecException e) {
            result.error("-1", e.getMessage(), e.toString());
            return;
        }
        String privateKeyBytesBase64 = new String(Base64.encode(key.getEncoded(), Base64.DEFAULT));
        Map params = new ArrayMap();
        params.put("publicKey", publicKeyBytesBase64);
        params.put("privateKey", privateKeyBytesBase64);
        result.success(params);
    }

}
