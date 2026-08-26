package com.andew.ailocal.model

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.andew.ailocal.R
import com.andew.ailocal.ai.LlamaCliEngine
import com.andew.ailocal.ai.ModelProfile

class ModelBrowserAdapter(
    private val activity: ModelBrowserActivity,
    private var models: List<ModelProfile>,
    private val engine: LlamaCliEngine,
    private val onModelAction: (ModelProfile, Action) -> Unit
) : RecyclerView.Adapter<ModelBrowserAdapter.ModelViewHolder>() {

    enum class Action { SELECT, DELETE, IMPORT }

    class ModelViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val nameText: TextView = view.findViewById(R.id.modelNameText)
        val statusText: TextView = view.findViewById(R.id.modelStatusText)
        val selectBtn: View = view.findViewById(R.id.selectBtn)
        val deleteBtn: View = view.findViewById(R.id.deleteBtn)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ModelViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_model, parent, false)
        return ModelViewHolder(view)
    }

    override fun onBindViewHolder(holder: ModelViewHolder, position: Int) {
        val model = models[position]
        holder.nameText.text = model.name
        
        // Check if this is the active model
        val activeModel = engine.getActiveModel()
        val isActive = activeModel != null && activeModel.name == model.name
        holder.statusText.text = if (isActive) "ACTIVE" else "Available"
        holder.statusText.setTextColor(
            if (isActive) 0xFF4CAF50.toInt() else 0xFF9E9E9E.toInt()
        )

        holder.selectBtn.setOnClickListener { onModelAction(model, Action.SELECT) }
        holder.deleteBtn.setOnClickListener { onModelAction(model, Action.DELETE) }
        holder.itemView.setOnClickListener { onModelAction(model, Action.SELECT) }
    }

    override fun getItemCount(): Int = models.size

    fun updateModels(newModels: List<ModelProfile>) {
        models = newModels
        notifyDataSetChanged()
    }
}