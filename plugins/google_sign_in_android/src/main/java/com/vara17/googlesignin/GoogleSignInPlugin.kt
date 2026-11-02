package com.vara17.googlesignin

import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

// Muestra el selector de cuentas de Google y devuelve a Godot el ID token,
// que luego se canjea por una sesión de Firebase desde GDScript.
class GoogleSignInPlugin(godot: Godot) : GodotPlugin(godot) {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun getPluginName() = "GoogleSignIn"

    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo(SIGNED_IN, String::class.java),
        SignalInfo(FAILED, String::class.java),
    )

    @UsedByGodot
    fun signIn(webClientId: String) {
        val act = activity
        if (act == null) {
            emit(FAILED, "Sin actividad de Android")
            return
        }
        val option = GetSignInWithGoogleOption.Builder(webClientId).build()
        val request = GetCredentialRequest.Builder().addCredentialOption(option).build()
        scope.launch {
            try {
                val credential = CredentialManager.create(act).getCredential(act, request).credential
                if (credential is CustomCredential &&
                    credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
                ) {
                    emit(SIGNED_IN, GoogleIdTokenCredential.createFrom(credential.data).idToken)
                } else {
                    emit(FAILED, "Credencial inesperada: ${credential.type}")
                }
            } catch (e: GetCredentialCancellationException) {
                emit(FAILED, CANCELLED)
            } catch (e: GetCredentialException) {
                emit(FAILED, e.message ?: e.type)
            } catch (e: Exception) {
                emit(FAILED, e.message ?: e.javaClass.simpleName)
            }
        }
    }

    @UsedByGodot
    fun signOut() {
        val act = activity ?: return
        scope.launch {
            try {
                CredentialManager.create(act).clearCredentialState(ClearCredentialStateRequest())
            } catch (_: Exception) {
            }
        }
    }

    private fun emit(signal: String, value: String) {
        runOnRenderThread { emitSignal(signal, value) }
    }

    companion object {
        const val SIGNED_IN = "sign_in_succeeded"
        const val FAILED = "sign_in_failed"
        const val CANCELLED = "cancelled"
    }
}
