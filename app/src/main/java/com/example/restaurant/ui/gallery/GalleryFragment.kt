package com.example.restaurant.ui.gallery

import CustomAdapter
import android.R
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
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import com.example.restaurant.DatabaseConnectionTask
import com.example.restaurant.databinding.FragmentGalleryBinding
import java.sql.Date
import java.text.SimpleDateFormat


class GalleryFragment : Fragment() {

    fun screening(str: String): String{
        val removedString = str.replace(Regex("[\\s'\\$()<>;:?/\\\\|^%@!&*]"), "")
        return removedString
    }


    private var _binding: FragmentGalleryBinding? = null



    //val editProducts = EditProducts()



    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    private lateinit var button: Button

    private lateinit var listViewMenu: ListView

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

        _binding = FragmentGalleryBinding.inflate(inflater, container, false)
        val root: View = binding.root
        listViewMenu = binding.listViewMenu
        listViewMenu.visibility = View.INVISIBLE
        button = binding.button2



        buttonOpenDeleteProduct = binding.button5
        buttonDeleteProduct = binding.buttonDelete
        buttonGoBackFromDeleteProduct = binding.buttonCancelDelete

        editLayout = binding.addBlock
        listLayout = binding.listBlock
        delitLayout = binding.deleteBlock

        buttonOpenProductAdd = binding.button4
        buttonAddProduct = binding.button6
        goBackFromAddProduct = binding.button7






        var firstClick = true
        button.setOnClickListener {
           // DatabaseConnectionTask.addProduct("Продукт999", "190.0","2023-11-18","14","Виктор")
            Log.i("878","lllllllllllllll")
            var list = DatabaseConnectionTask.products()
            if (!list.isEmpty()){
                if (listViewMenu.visibility == View.INVISIBLE) {

                    if (firstClick){
                        listViewMenu.visibility = View.VISIBLE

                        Log.i("09",list.toString())
                        val adapter = CustomAdapter(requireContext(), android.R.layout.simple_list_item_2, list)
                        listViewMenu.setAdapter(adapter)
                        firstClick= false
                        button.setText("Скрыть список продуктов")
                    }else{
                        listViewMenu.visibility =View.VISIBLE
                        button.setText("Скрыть список продуктов")
                    }

                } else {
                    Log.i("90909","pppppppaaaaa")
                    listViewMenu.visibility = View.INVISIBLE
                    button.setText("Показать список продуктов")
                }
            }else{
                Toast.makeText(requireContext(),"Нет права просмотра продуктов",Toast.LENGTH_SHORT).show()
            }


        }


//        val inflater1 = LayoutInflater.from(requireContext())
//        myLayout = inflater1.inflate(R.id)


        buttonOpenProductAdd.setOnClickListener {
            listLayout.visibility = View.GONE
            editLayout.visibility = View.VISIBLE

        }

        buttonAddProduct.setOnClickListener {
            editLayout.visibility = View.GONE
            val name: String = screening(binding.editTextName.text.toString())
            val mas: Double =screening( binding.editTextMas.text.toString()).toDouble()
            val keep_count = screening(binding.editTextDuration.text.toString()).toInt()
            val restaurantName = screening(binding.editTextRestuarant.text.toString())
            val dateFormat = SimpleDateFormat("yyyy-MM-dd")
            val create_data =screening( binding.editTextDate.text.toString())
            val parsedDate = dateFormat.parse(create_data)
            val finalDate = Date(parsedDate.time)

            var flag = DatabaseConnectionTask.addProduct(name,mas,finalDate,keep_count,restaurantName)

            if (flag){
                Toast.makeText(requireContext(),"Продукт добавлен",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на добавление продукта",Toast.LENGTH_SHORT).show()
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
            var flag = DatabaseConnectionTask.deleteProduct(name)
            if (flag){
                Toast.makeText(requireContext(),"Продукт удален",Toast.LENGTH_SHORT).show()
            }else{
                Toast.makeText(requireContext(),"Нет права на удаление продукта",Toast.LENGTH_SHORT).show()
            }
            listLayout.visibility = View.VISIBLE
        }

        buttonGoBackFromDeleteProduct.setOnClickListener {
            delitLayout.visibility = View.GONE
            listLayout.visibility = View.VISIBLE
        }








        return root
    }

//    fun addProduct(view: View){
//        val transaction: FragmentTransaction = requireFragmentManager().beginTransaction()
//        transaction.replace(this.id, editProducts);
//        transaction.addToBackStack(null);
//        // Применяем изменения
//        transaction.commit();
//    }


//    fun showProducts(view: View){
//        try {
//            if (listViewMenu.visibility == View.INVISIBLE) {
//                listViewMenu.visibility = View.VISIBLE
//                var list = DatabaseConnectionTask.products()
//                val adapter =
//                    ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, list)
//                listViewMenu.setAdapter(adapter)
//
//
//            } else {
//                listViewMenu.visibility = View.INVISIBLE
//            }
//        }catch (e:Exception){
//            Toast.makeText(requireContext(),"Нет права просмотра продуктов",Toast.LENGTH_SHORT).show()
//        }
//
//    }
//    fun showHide(view:View) {
//        view.visibility = if (view.visibility == View.VISIBLE){
//            View.INVISIBLE
//        } else{
//            View.VISIBLE
//        }
//    }





    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
