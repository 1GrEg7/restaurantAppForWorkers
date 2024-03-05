package com.example.restaurant.ui.gallery

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentTransaction
import com.example.restaurant.DatabaseConnectionTask
import com.example.restaurant.R
import com.example.restaurant.databinding.AddProductBinding
import com.example.restaurant.databinding.FragmentGalleryBinding
import com.example.restaurant.databinding.RegistrationFormBinding
import java.sql.Date
import java.text.SimpleDateFormat

class EditProducts:  Fragment() {

    private var _binding: AddProductBinding? = null

    private val binding get() = _binding!!



    private lateinit var buttonAdd: Button
    private lateinit var buttonBack: Button

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {

        _binding = AddProductBinding.inflate(inflater, container, false)
        val root: View = binding.root


        buttonAdd = binding.button6
        var firstClick = true



    buttonAdd.setOnClickListener {
//        val name: String = binding.editTextName.text.toString()
//        val mas: Double = binding.editTextMas.text.toString().toDouble()
//        val keep_count = binding.editTextDuration.text.toString().toInt()
//        val restaurantName = binding.editTextRestuarant.text.toString()
//        val dateFormat = SimpleDateFormat("yyyy-MM-dd")
//        val create_data = binding.editTextDate.text.toString()
//        val parsedDate = dateFormat.parse(create_data)
//        val finalDate = Date(parsedDate.time)
//        DatabaseConnectionTask.addProduct(name,mas,finalDate,keep_count,restaurantName)
//        GalleryFragment.turnOnGalaryVisible()
//        Toast.makeText(requireContext(),"Ура",Toast.LENGTH_SHORT).show()
//        root.visibility = View.GONE
//        GalleryFragment.
    }


//        buttonBack.setOnClickListener {
//            getActivity()?.getSupportFragmentManager()?.popBackStack()
//
//        }




        return root
    }
















}