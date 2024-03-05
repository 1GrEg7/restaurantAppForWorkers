package com.example.restaurant.ui.slideshow

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
import com.example.restaurant.databinding.FragmentSlideshowBinding
import java.sql.Date
import java.text.SimpleDateFormat

class SlideshowFragment : Fragment() {

    fun screening(str: String): String{
        val removedString = str.replace(Regex("[\\s'\\$()<>;:?/\\\\|^%@!&*]"), "")
        return removedString
    }

    private var _binding: FragmentSlideshowBinding? = null
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


    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {

        _binding = FragmentSlideshowBinding.inflate(inflater, container, false)
        val root: View = binding.root
        listViewMenu = binding.listViewMenu
        listViewMenu.visibility = View.INVISIBLE
        button = binding.show


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
            var a= cuisine_type.valueOf("итальянская")//= "итальянская" as cuisine_type
            var list = DatabaseConnectionTask.dishes()
            try {
                DatabaseConnectionTask.addDish("Блюдо999",90,"помидор, салат, огурец, масло",120,"Виктор", a )
            }catch (e:Exception){
                Log.i("<<<<<","<<<<<<<<<")
                e.printStackTrace()
                Log.i("<<<<<","<<<<<<<<<")
            }

            if (!list.isEmpty()){
                if (listViewMenu.visibility == View.INVISIBLE) {

                    if (firstClick){
                        listViewMenu.visibility = View.VISIBLE

                        Log.i("09",list.toString())
                        val adapter = CustomAdapter(requireContext(), android.R.layout.simple_list_item_2, list)
                        listViewMenu.setAdapter(adapter)
                        firstClick= false
                        button.setText("Скрыть список блюд")
                    }else{
                        listViewMenu.visibility =View.VISIBLE
                        button.setText("Скрыть список блюд")
                    }

                } else {
                    Log.i("90909","pppppppaaaaa")
                    listViewMenu.visibility = View.INVISIBLE
                    button.setText("Показать список блюд")
                }
            }else{
                Toast.makeText(requireContext(),"Нет права просмотра блюд", Toast.LENGTH_SHORT).show()
            }
        }



        buttonOpenProductAdd.setOnClickListener {
            listLayout.visibility = View.GONE
            editLayout.visibility = View.VISIBLE

        }

        buttonAddProduct.setOnClickListener {
            editLayout.visibility = View.GONE
            val name: String =screening( binding.editTextName.text.toString())
            val mas: Int = screening( binding.editTextMas.text.toString()).toInt()
            val composition =screening(  binding.editTextDate.text.toString())
            val callories = screening( binding.editTextDuration.text.toString()).toInt()
            val restaurantName = screening( binding.editTextRestuarant.text.toString())
            val cuisine = cuisine_type.valueOf(screening( binding.editTextCuisine.text.toString()))


            var flag = DatabaseConnectionTask.addDish(name,mas,composition,callories,restaurantName,cuisine)

            if (flag){
                Toast.makeText(requireContext(),"Блюдо добавлено",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на добавление блюда",Toast.LENGTH_SHORT).show()
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
            val name: String =screening(  binding.editTextNameDeleteProduct.text.toString())
            var flag = DatabaseConnectionTask.deleteDish(name)
            if (flag){
                Toast.makeText(requireContext(),"Блюдо удалено",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на удаление блюда",Toast.LENGTH_SHORT).show()
            }
            listLayout.visibility = View.VISIBLE
        }

        buttonGoBackFromDeleteProduct.setOnClickListener {
            delitLayout.visibility = View.GONE
            listLayout.visibility = View.VISIBLE
        }





        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}