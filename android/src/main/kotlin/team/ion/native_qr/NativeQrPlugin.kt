package team.ion.native_qr

import com.google.android.gms.tasks.Task
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.*

import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString

/** NativeQrPlugin */
class NativeQrPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : android.content.Context
  private lateinit var scanner : GmsBarcodeScanner

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_qr")
    channel.setMethodCallHandler(this)
    getClient()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      "getQrCode" -> {
        scanner.startScan().addOnSuccessListener { qrcode ->
          // Task completed successfully
          result.success(qrcode.rawValue)
        }
        .addOnCanceledListener {
          // Task canceled
          result.error("canceled", null, null)
        }
        .addOnFailureListener { e ->
          // Task failed with an exception
          result.error("canceled", null, e)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getClient() {
    val options = GmsBarcodeScannerOptions.Builder()
    .setBarcodeFormats(
        Barcode.FORMAT_QR_CODE
        )
    .build()
    scanner = GmsBarcodeScanning.getClient(context, options)
  }

  private fun startScan(): Task<Barcode> {
    return scanner.startScan()
  }
}
