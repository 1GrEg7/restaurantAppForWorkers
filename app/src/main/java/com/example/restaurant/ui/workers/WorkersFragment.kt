package com.example.restaurant.ui.workers

import androidx.fragment.app.Fragment;
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
import com.example.restaurant.DatabaseConnectionTask
import com.example.restaurant.databinding.FragmentWorkersBinding
import java.sql.Date
import java.text.SimpleDateFormat

class WorkersFragment:Fragment() {

    fun screening(str: String): String{
        val removedString = str.replace(Regex("[\\s'\\$()<>;:?/\\\\|^%@!&*]"), "")
        return removedString
    }

    private var _binding: FragmentWorkersBinding? = null



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

        _binding = FragmentWorkersBinding.inflate(inflater, container, false)
        val root: View = binding.root
        listViewMenu = binding.listViewMenu
        listViewMenu.visibility = View.INVISIBLE
        button = binding.button3

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
            var list = DatabaseConnectionTask.workers()
            if (!list.isEmpty()){
                if (listViewMenu.visibility == View.INVISIBLE) {

                    if (firstClick){
                        listViewMenu.visibility = View.VISIBLE

                        Log.i("09",list.toString())
                        val adapter = CustomAdapter(requireContext(), android.R.layout.simple_list_item_2, list)
                        listViewMenu.setAdapter(adapter)
                        firstClick= false
                        button.setText("Скрыть список работников")
                    }else{
                        listViewMenu.visibility = View.VISIBLE
                        button.setText("Скрыть список работников")
                    }

                } else {
                    Log.i("90909","pppppppaaaaa")
                    listViewMenu.visibility = View.INVISIBLE
                    button.setText("Показать список работников")
                }
            }else{
                Toast.makeText(requireContext(),"Нет прав просмотра работников", Toast.LENGTH_SHORT).show()
            }
        }


        buttonOpenProductAdd.setOnClickListener {
            listLayout.visibility = View.GONE
            editLayout.visibility = View.VISIBLE

        }

        buttonAddProduct.setOnClickListener {
            editLayout.visibility = View.GONE
            val name: String =screening( binding.editTextName.text.toString())
            val ID: Int = screening(binding.editTextMas.text.toString()).toInt()
            val surname = screening(binding.editTextDate.text.toString())
            val lastname = screening(binding.editTextDuration.text.toString())
            val sex = screening(binding.editTextRestuarant.text.toString())
            val phone = screening(binding.editTextCuisine2.text.toString())
            val waste_hours= screening(binding.editTextCuisine3.text.toString()).toInt()
            val premium= screening(binding.editTextCuisine4.text.toString()).toInt()
            val post = screening(binding.editTextCuisine6.text.toString())
            val restaurantName = screening(binding.editTextCuisine5.text.toString())


            val birth_data = screening(binding.editTextCuisine.text.toString())
            val dateFormat = SimpleDateFormat("yyyy-MM-dd")
            val parsedDate = dateFormat.parse(birth_data)
            val finalDate = Date(parsedDate.time)



            var flag = DatabaseConnectionTask.addWorker(ID, name, surname, lastname, sex, finalDate,phone,waste_hours, premium,post,restaurantName)

            if (flag){
                Toast.makeText(requireContext(),"Работник добавлен",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет прав на добавление работников",Toast.LENGTH_SHORT).show()
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
            val ID: Int =screening( binding.editTextNameDeleteProduct.text.toString()).toInt()
            var flag = DatabaseConnectionTask.deleteWorker(ID)
            if (flag){
                Toast.makeText(requireContext(),"Работник удален",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет прав на удаление работника",Toast.LENGTH_SHORT).show()
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