package com.andew.ailocal.model

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.DocumentsContract
import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.andew.ailocal.R
import com.andew.ailocal.ai.LlamaCliEngine
import com.andew.ailocal.ai.ModelProfile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class ModelBrowserActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ModelBrowserAdapter
    private val modelStore: ModelStore by lazy { ModelStore(this) }
    private val engine: LlamaCliEngine by lazy { LlamaCliEngine() }

    // File picker for importing models
    private val pickFileLauncher = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
        if (uri != null) {
            copyModelToInternalStorage(uri)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_model_browser)

        setupToolbar()
        setupRecyclerView()
        loadModels()
    }

    private fun setupToolbar() {
        supportActionBar?.title = "Model Browser"
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
    }

    private fun setupRecyclerView() {
        recyclerView = findViewById(R.id.modelRecyclerView)
        recyclerView.layoutManager = LinearLayoutManager(this)
        adapter = ModelBrowserAdapter(this, modelStore.getAllModels(), engine) { model, action ->
            when (action) {
                ModelBrowserAdapter.Action.SELECT -> selectModel(model)
                ModelBrowserAdapter.Action.DELETE -> deleteModel(model)
                ModelBrowserAdapter.Action.IMPORT -> importModel()
            }
        }
        recyclerView.adapter = adapter
    }

    private fun loadModels() {
        val models = modelStore.getAllModels()
        adapter.updateModels(models)
    }

    private fun selectModel(model: ModelProfile) {
        // Save selected model and switch engine
        lifecycleScope.launch(Dispatchers.IO) {
            modelStore.setActiveModel(model)
            withContext(Dispatchers.Main) {
                engine.loadModel(model)
                Toast.makeText(this@ModelBrowserActivity, "Model switched: ${model.name}", Toast.LENGTH_SHORT).show()
                setResult(Activity.RESULT_OK)
                finish()
            }
        }
    }

    private fun deleteModel(model: ModelProfile) {
        lifecycleScope.launch(Dispatchers.IO) {
            modelStore.deleteModel(model)
            withContext(Dispatchers.Main) {
                loadModels()
                Toast.makeText(this@ModelBrowserActivity, "Model deleted", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun importModel() {
        pickFileLauncher.launch(arrayOf("application/octet-stream"))
    }

    private fun copyModelToInternalStorage(uri: Uri) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val inputStream: InputStream = contentResolver.openInputStream(uri)!!
                val fileName = getFileNameFromUri(uri)
                val destFile = File(filesDir, "models/$fileName")
                destFile.parentFile?.mkdirs()

                val outputStream = FileOutputStream(destFile)
                inputStream.copyTo(outputStream)
                outputStream.close()
                inputStream.close()

                withContext(Dispatchers.Main) {
                    val newModel = ModelProfile(
                        name = fileName.replace(".gguf", ""),
                        context = 4096,
                        threads = 4,
                        temperature = 0.7f,
                        maxTokens = 2048
                    )
                    modelStore.addModel(newModel, destFile)
                    loadModels()
                    Toast.makeText(this@ModelBrowserActivity, "Model imported: $fileName", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Log.e("ModelBrowser", "Import failed", e)
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@ModelBrowserActivity, "Import failed: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun getFileNameFromUri(uri: Uri): String {
        return try {
            val cursor = contentResolver.query(uri, null, null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val nameIndex = it.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                    if (nameIndex >= 0) it.getString(nameIndex) else "model.gguf"
                } else "model.gguf"
            } ?: "model.gguf"
        } catch (e: Exception) {
            "model.gguf"
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}