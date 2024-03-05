package com.example.restaurant.ui.Drinks

import CustomAdapter
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ListView
import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.fragment.app.Fragment
import com.example.restaurant.DatabaseConnectionTask
import com.example.restaurant.databinding.DrinksFragmentBinding
import com.example.restaurant.databinding.FragmentGalleryBinding

class Drinks: Fragment() {

    fun screening(str: String): String{
        val removedString = str.replace(Regex("[\\s'\\$()<>;:?/\\\\|^%@!&*]"), "")
        return removedString
    }

    private var _binding:DrinksFragmentBinding? = null



    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!
    private lateinit var listViewMenu: ListView
    private lateinit var button: Button

    private lateinit var buttonOpenProductAdd: Button
    private lateinit var buttonAddProduct: Button
    private lateinit var goBackFromAddProduct: Button

    private lateinit var buttonOpenDeleteProduct: Button
    private lateinit var buttonGoBackFromDeleteProduct: Button
    private lateinit var buttonDeleteProduct: Button
    private lateinit var editLayout: ConstraintLayout
    private lateinit var listLayout: ConstraintLayout
    private lateinit var delitLayout: ConstraintLayout



    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {

        _binding = DrinksFragmentBinding.inflate(inflater, container, false)
        val root: View = binding.root
        listViewMenu = binding.listViewMenu
        listViewMenu.visibility = View.INVISIBLE
        button = binding.button2

        buttonOpenDeleteProduct = binding.delete
        buttonDeleteProduct = binding.buttonDelete
        buttonGoBackFromDeleteProduct = binding.buttonCancelDelete

        editLayout = binding.addBlock
        listLayout = binding.listBlock
        delitLayout = binding.deleteBlock

        buttonOpenProductAdd = binding.add
        buttonAddProduct = binding.button6
        goBackFromAddProduct = binding.button7

        var firstClick = true
        button.setOnClickListener {
            Log.i("878","lllllllllllllll")
            var list = DatabaseConnectionTask.drinks()
            if (!list.isEmpty()){
                if (listViewMenu.visibility == View.INVISIBLE) {

                    if (firstClick){
                        listViewMenu.visibility = View.VISIBLE

                        Log.i("09",list.toString())
                        val adapter = CustomAdapter(requireContext(), android.R.layout.simple_list_item_2, list)
                        listViewMenu.setAdapter(adapter)
                        firstClick= false
                        button.setText("Скрыть список напитков")
                    }else{
                        listViewMenu.visibility = View.VISIBLE
                        button.setText("Скрыть список напитков")
                    }

                } else {
                    Log.i("90909","pppppppaaaaa")
                    listViewMenu.visibility = View.INVISIBLE
                    button.setText("Показать список напитков")
                }
            }else{
                Toast.makeText(requireContext(),"Нет права просмотра напитков", Toast.LENGTH_SHORT).show()
            }
        }



        buttonOpenProductAdd.setOnClickListener {
            listLayout.visibility = View.GONE
            editLayout.visibility = View.VISIBLE

        }

        buttonAddProduct.setOnClickListener {
            editLayout.visibility = View.GONE
            val name: String =screening( binding.editTextName.text.toString())
            val volume: Int = screening(binding.editTextMas.text.toString()).toInt()
            val composition = screening(binding.editTextDate.text.toString())
            val alcohol = screening(binding.editTextDuration.text.toString()).toInt()
            val restaurantName = screening(binding.editTextRestuarant.text.toString())



            var flag = DatabaseConnectionTask.addDrink(name,volume,composition,alcohol,restaurantName)

            if (flag){
                Toast.makeText(requireContext(),"Напитое добавлен",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на добавление напитка",Toast.LENGTH_SHORT).show()
            }

            listLayout.visibility = View.VISIBLE


        }
        goBackFromAddProduct.setOnClickListener {
            editLayout.visibility = View.GONE
            listLayout.visibility = View.VISIBLE
        }

        buttonOpenDeleteProduct.setOnClickListener {
            listLayout.visibility = View.GONE
            delitLayout.visibility = View.VISIBLE
        }

        buttonDeleteProduct.setOnClickListener {
            delitLayout.visibility = View.GONE
            val name: String = screening(binding.editTextNameDeleteProduct.text.toString())
            var flag = DatabaseConnectionTask.deleteDrink(name)
            if (flag){
                Toast.makeText(requireContext(),"Напиток удален",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на удаление напитка",Toast.LENGTH_SHORT).show()
            }
            listLayout.visibility = View.VISIBLE
        }

        buttonGoBackFromDeleteProduct.setOnClickListener {
            delitLayout.visibility = View.GONE
            listLayout.visibility = View.VISIBLE
        }




        return root
    }

}